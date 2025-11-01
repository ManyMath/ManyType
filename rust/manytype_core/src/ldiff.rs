use std::collections::HashMap;

use anyhow::{Result, anyhow};
use blake3::Hasher as Blake3Hasher;
use manytype_proto::spacesync::DiffType;
use xxhash_rust::xxh64::xxh64;

/// (new_on_remote, missing_on_remote, changed, removed)
pub type DiffResult = (Vec<String>, Vec<String>, Vec<String>, Vec<String>);

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct Element {
    pub id: String,
    pub head: String,
}

#[derive(Clone, Copy, Debug, Eq, PartialEq)]
pub struct Range {
    pub from: u64,
    pub to: u64,
    pub elements: bool,
    pub limit: usize,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct RangeResult {
    pub hash: Vec<u8>,
    pub elements: Vec<Element>,
    pub count: usize,
}

pub trait Remote {
    fn ranges(&self, ranges: &[Range]) -> Result<Vec<RangeResult>>;
}

impl Remote for Diff {
    fn ranges(&self, ranges: &[Range]) -> Result<Vec<RangeResult>> {
        Ok(self.ranges(ranges))
    }
}

#[derive(Clone, Debug)]
pub struct Hasher(Blake3Hasher);

impl Hasher {
    pub fn new() -> Self {
        Self(Blake3Hasher::new())
    }

    pub fn hash_id(&mut self, id: &str) -> String {
        self.0.reset();
        self.0.update(id.as_bytes());
        hex::encode(self.0.finalize().as_bytes())
    }
}

impl Default for Hasher {
    fn default() -> Self {
        Self::new()
    }
}

#[derive(Clone, Debug)]
struct InternalElement {
    element: Element,
    hash: u64,
}

#[derive(Clone, Copy, Debug, Eq, Hash, PartialEq)]
struct RangeTuple {
    from: u64,
    to: u64,
}

#[derive(Clone, Debug)]
struct RangeNode {
    hash: Vec<u8>,
    count: usize,
}

pub struct Diff {
    divide_factor: usize,
    compare_threshold: usize,
    diff_type: DiffType,
    elements: HashMap<String, Element>,
    sorted: Vec<InternalElement>,
    ranges: HashMap<RangeTuple, RangeNode>,
    root_hash: Vec<u8>,
}

impl Diff {
    pub fn new(divide_factor: usize, compare_threshold: usize) -> Self {
        Self::new_with_type(divide_factor, compare_threshold, DiffType::V3)
    }

    pub fn new_with_type(
        divide_factor: usize,
        compare_threshold: usize,
        diff_type: DiffType,
    ) -> Self {
        let mut diff = Self {
            divide_factor: divide_factor.max(2),
            compare_threshold: compare_threshold.max(1),
            diff_type,
            elements: HashMap::new(),
            sorted: Vec::new(),
            ranges: HashMap::new(),
            root_hash: Vec::new(),
        };
        diff.rebuild();
        diff
    }

    pub fn set(&mut self, elements: impl IntoIterator<Item = Element>) {
        for element in elements {
            self.elements.insert(element.id.clone(), element);
        }
        self.rebuild();
    }

    pub fn remove_id(&mut self, id: &str) -> Result<()> {
        self.elements
            .remove(id)
            .ok_or_else(|| anyhow!("ldiff: element not found"))?;
        self.rebuild();
        Ok(())
    }

    pub fn element(&self, id: &str) -> Result<Element> {
        self.elements
            .get(id)
            .cloned()
            .ok_or_else(|| anyhow!("ldiff: element not found"))
    }

    pub fn elements(&self) -> Vec<Element> {
        self.sorted
            .iter()
            .map(|item| item.element.clone())
            .collect()
    }

    pub fn ids(&self) -> Vec<String> {
        self.sorted
            .iter()
            .map(|item| item.element.id.clone())
            .collect()
    }

    pub fn len(&self) -> usize {
        self.sorted.len()
    }

    pub fn is_empty(&self) -> bool {
        self.sorted.is_empty()
    }

    pub fn hash_hex(&self) -> String {
        hex::encode(&self.root_hash)
    }

    pub fn diff_type(&self) -> DiffType {
        self.diff_type
    }

    pub fn ranges(&self, ranges: &[Range]) -> Vec<RangeResult> {
        ranges.iter().map(|range| self.get_range(*range)).collect()
    }

    pub fn diff<R: Remote>(&self, remote: &R) -> Result<(Vec<String>, Vec<String>, Vec<String>)> {
        let mut ctx = DiffContext::default();
        ctx.to_send.push(Range {
            from: 0,
            to: u64::MAX,
            elements: false,
            limit: 0,
        });

        while !ctx.to_send.is_empty() {
            let other_results = remote.ranges(&ctx.to_send)?;
            let my_results = self.ranges(&ctx.to_send);
            if other_results.len() != ctx.to_send.len() || my_results.len() != ctx.to_send.len() {
                return Err(anyhow!("ldiff: query and results mismatched"));
            }
            let to_send = ctx.to_send.clone();
            for (index, range) in to_send.into_iter().enumerate() {
                self.compare_results(
                    &mut ctx,
                    range,
                    &my_results[index],
                    &other_results[index],
                    CompareMode::Equal,
                );
            }
            std::mem::swap(&mut ctx.to_send, &mut ctx.prepare);
            ctx.prepare.clear();
        }

        Ok((ctx.new_ids, ctx.changed_ids, ctx.removed_ids))
    }

    pub fn compare_diff<R: Remote>(&self, remote: &R) -> Result<DiffResult> {
        let mut ctx = DiffContext::default();
        ctx.to_send.push(Range {
            from: 0,
            to: u64::MAX,
            elements: false,
            limit: 0,
        });

        while !ctx.to_send.is_empty() {
            let other_results = remote.ranges(&ctx.to_send)?;
            let my_results = self.ranges(&ctx.to_send);
            if other_results.len() != ctx.to_send.len() || my_results.len() != ctx.to_send.len() {
                return Err(anyhow!("ldiff: query and results mismatched"));
            }
            let to_send = ctx.to_send.clone();
            for (index, range) in to_send.into_iter().enumerate() {
                self.compare_results(
                    &mut ctx,
                    range,
                    &my_results[index],
                    &other_results[index],
                    CompareMode::Greater,
                );
            }
            std::mem::swap(&mut ctx.to_send, &mut ctx.prepare);
            ctx.prepare.clear();
        }

        Ok((
            ctx.new_ids,
            ctx.changed_ids,
            ctx.their_changed_ids,
            ctx.removed_ids,
        ))
    }

    fn compare_results(
        &self,
        ctx: &mut DiffContext,
        range: Range,
        my_result: &RangeResult,
        other_result: &RangeResult,
        mode: CompareMode,
    ) {
        if my_result.hash == other_result.hash {
            return;
        }

        if other_result.elements.len() == other_result.count {
            let my_elements = if my_result.elements.len() == my_result.count {
                my_result.elements.clone()
            } else {
                let mut expanded = range;
                expanded.elements = true;
                self.get_range(expanded).elements
            };
            match mode {
                CompareMode::Equal => {
                    compare_elements_equal(ctx, &my_elements, &other_result.elements)
                }
                CompareMode::Greater => {
                    compare_elements_greater(ctx, &my_elements, &other_result.elements)
                }
            }
            return;
        }

        if (other_result.count <= self.compare_threshold && other_result.elements.is_empty())
            || my_result.elements.len() == my_result.count
        {
            let mut expanded = range;
            expanded.elements = true;
            ctx.prepare.push(expanded);
            return;
        }

        for tuple in gen_tuple_ranges(range.from, range.to, self.divide_factor) {
            ctx.prepare.push(Range {
                from: tuple.from,
                to: tuple.to,
                elements: false,
                limit: 0,
            });
        }
    }

    fn get_range(&self, range: Range) -> RangeResult {
        let maybe_node = self.ranges.get(&RangeTuple {
            from: range.from,
            to: range.to,
        });
        let mut result = RangeResult {
            hash: maybe_node.map(|node| node.hash.clone()).unwrap_or_default(),
            elements: Vec::new(),
            count: maybe_node.map(|node| node.count).unwrap_or_default(),
        };

        if !range.elements {
            if maybe_node.is_some() {
                return result;
            }
            result.count = self.scan_elements(range.from, range.to, range.limit).len();
            return result;
        }

        result.elements = self.scan_elements(range.from, range.to, range.limit);
        result.count = result.elements.len();
        result
    }

    fn scan_elements(&self, from: u64, to: u64, limit: usize) -> Vec<Element> {
        let mut result = Vec::new();
        for item in &self.sorted {
            if item.hash < from {
                continue;
            }
            if item.hash > to {
                break;
            }
            result.push(item.element.clone());
            if limit > 0 && result.len() >= limit {
                break;
            }
        }
        result
    }

    fn rebuild(&mut self) {
        self.sorted = self
            .elements
            .values()
            .cloned()
            .map(|element| InternalElement {
                hash: xxh64(element.id.as_bytes(), 0),
                element,
            })
            .collect();
        self.sorted.sort_by(|left, right| {
            left.hash
                .cmp(&right.hash)
                .then_with(|| left.element.id.cmp(&right.element.id))
        });

        self.ranges.clear();
        let root = self.build_range(
            RangeTuple {
                from: 0,
                to: u64::MAX,
            },
            true,
        );
        self.root_hash = root.hash;
    }

    fn build_range(&mut self, tuple: RangeTuple, force_divide: bool) -> RangeNode {
        let elements = self.elements_in_range(tuple.from, tuple.to);
        let count = elements.len();
        let divided = force_divide || count > self.compare_threshold;

        let node = if divided {
            let child_hashes = gen_tuple_ranges(tuple.from, tuple.to, self.divide_factor)
                .into_iter()
                .map(|child| self.build_range(child, false).hash)
                .collect::<Vec<_>>();
            RangeNode {
                hash: hash_children(&child_hashes),
                count,
            }
        } else {
            let hash = hash_elements(&elements);
            RangeNode { hash, count }
        };

        self.ranges.insert(tuple, node.clone());
        node
    }

    fn elements_in_range(&self, from: u64, to: u64) -> Vec<&InternalElement> {
        self.sorted
            .iter()
            .filter(|item| item.hash >= from && item.hash <= to)
            .collect()
    }
}

#[derive(Default)]
struct DiffContext {
    new_ids: Vec<String>,
    changed_ids: Vec<String>,
    their_changed_ids: Vec<String>,
    removed_ids: Vec<String>,
    to_send: Vec<Range>,
    prepare: Vec<Range>,
}

enum CompareMode {
    Equal,
    Greater,
}

fn compare_elements_equal(ctx: &mut DiffContext, mine: &[Element], other: &[Element]) {
    let other_map: HashMap<&str, &str> = other
        .iter()
        .map(|element| (element.id.as_str(), element.head.as_str()))
        .collect();
    for element in mine {
        match other_map.get(element.id.as_str()) {
            None => ctx.removed_ids.push(element.id.clone()),
            Some(other_head) if *other_head != element.head => {
                ctx.changed_ids.push(element.id.clone())
            }
            Some(_) => {}
        }
    }

    let my_map: HashMap<&str, &str> = mine
        .iter()
        .map(|element| (element.id.as_str(), element.head.as_str()))
        .collect();
    for element in other {
        if !my_map.contains_key(element.id.as_str()) {
            ctx.new_ids.push(element.id.clone());
        }
    }
}

fn compare_elements_greater(ctx: &mut DiffContext, mine: &[Element], other: &[Element]) {
    let other_map: HashMap<&str, &str> = other
        .iter()
        .map(|element| (element.id.as_str(), element.head.as_str()))
        .collect();
    for element in mine {
        match other_map.get(element.id.as_str()) {
            None => ctx.removed_ids.push(element.id.clone()),
            Some(other_head) if *other_head == element.head => {}
            Some(other_head) if *other_head > element.head.as_str() => {
                ctx.their_changed_ids.push(element.id.clone())
            }
            Some(_) => ctx.changed_ids.push(element.id.clone()),
        }
    }

    let my_ids: HashMap<&str, ()> = mine
        .iter()
        .map(|element| (element.id.as_str(), ()))
        .collect();
    for element in other {
        if !my_ids.contains_key(element.id.as_str()) {
            ctx.new_ids.push(element.id.clone());
        }
    }
}

fn gen_tuple_ranges(from: u64, to: u64, divide_factor: usize) -> Vec<RangeTuple> {
    let divide_factor = divide_factor as u64;
    let mut per_range = (to - from) / divide_factor;
    let align = ((to - from) % divide_factor + 1) % divide_factor;
    if align == 0 {
        per_range += 1;
    }

    let mut current = from;
    let mut ranges = Vec::with_capacity(divide_factor as usize);
    for index in 0..divide_factor {
        let mut width = per_range;
        if index == divide_factor - 1 {
            width += align;
        }
        ranges.push(RangeTuple {
            from: current,
            to: current.wrapping_add(width).wrapping_sub(1),
        });
        current = current.wrapping_add(width);
    }
    ranges
}

fn hash_elements(elements: &[&InternalElement]) -> Vec<u8> {
    if elements.is_empty() {
        return Vec::new();
    }

    let mut hasher = Blake3Hasher::new();
    for element in elements {
        hasher.update(element.element.id.as_bytes());
        hasher.update(element.element.head.as_bytes());
    }
    hasher.finalize().as_bytes().to_vec()
}

fn hash_children(children: &[Vec<u8>]) -> Vec<u8> {
    let mut hasher = Blake3Hasher::new();
    for child in children {
        hasher.update(child);
    }
    hasher.finalize().as_bytes().to_vec()
}

#[cfg(test)]
mod tests {
    use super::*;

    fn element(id: &str, head: &str) -> Element {
        Element {
            id: id.to_string(),
            head: head.to_string(),
        }
    }

    #[test]
    fn empty_diff_has_stable_non_empty_root_hash() {
        let diff = Diff::new(4, 4);
        assert_eq!(
            diff.hash_hex(),
            "af1349b9f5f9a1a6a0404dea36dcc9499bcb25c9adc112b7cc9a93cae41f3262"
        );
    }

    #[test]
    fn range_hash_matches_ported_algorithm_vector() {
        let mut diff = Diff::new(4, 4);
        diff.set([
            element("1", "h1"),
            element("2", "h2"),
            element("3", "h3"),
            element("4", "h4"),
            element("5", "h5"),
        ]);

        let result = diff.ranges(&[Range {
            from: 0,
            to: u64::MAX,
            elements: false,
            limit: 0,
        }]);
        assert_eq!(result[0].count, 5);
        assert_eq!(
            hex::encode(&result[0].hash),
            "40e87194294172544506168240aaf40dddce460def5d7c282d585e206fc0b702"
        );
    }

    #[test]
    fn set_update_remove_and_lookup_work() {
        let mut diff = Diff::new(4, 4);
        diff.set([element("id1", "head1"), element("id2", "head2")]);
        assert_eq!(diff.len(), 2);
        assert_eq!(diff.element("id1").unwrap().head, "head1");

        diff.set([element("id1", "head3")]);
        assert_eq!(diff.element("id1").unwrap().head, "head3");

        diff.remove_id("id2").unwrap();
        assert_eq!(diff.len(), 1);
        assert!(diff.element("id2").is_err());
    }

    #[test]
    fn diff_detects_new_changed_and_removed_ids() {
        let mut mine = Diff::new(16, 16);
        let mut other = Diff::new(16, 16);
        for index in 0..100 {
            let id = index.to_string();
            let head = format!("h{index}");
            mine.set([element(&id, &head)]);
            other.set([element(&id, &head)]);
        }

        other.set([element("new", "new")]);
        other.set([element("1", "changed")]);
        other.remove_id("0").unwrap();

        let (new_ids, changed_ids, removed_ids) = mine.diff(&other).unwrap();
        assert_eq!(new_ids, vec!["new".to_string()]);
        assert_eq!(changed_ids, vec!["1".to_string()]);
        assert_eq!(removed_ids, vec!["0".to_string()]);
    }

    #[test]
    fn compare_diff_tracks_head_direction() {
        let mut mine = Diff::new(16, 16);
        let mut other = Diff::new(16, 16);
        mine.set([element("same", "b"), element("ours-newer", "z")]);
        other.set([
            element("same", "b"),
            element("ours-newer", "a"),
            element("theirs", "z"),
        ]);

        let (new_ids, changed_ids, their_changed_ids, removed_ids) =
            mine.compare_diff(&other).unwrap();
        assert_eq!(new_ids, vec!["theirs".to_string()]);
        assert_eq!(changed_ids, vec!["ours-newer".to_string()]);
        assert!(their_changed_ids.is_empty());
        assert!(removed_ids.is_empty());
    }
}
