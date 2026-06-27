import 'package:manytype_core/manytype_core.dart' show validateMnemonic;

/// Collapses whitespace and lowercases a pasted recovery phrase so that
/// line breaks / double spaces / stray capitals don't fail validation.
String normalizeMnemonic(String raw) {
  final words = raw.trim().toLowerCase().split(RegExp(r'\s+'));
  return words.where((w) => w.isNotEmpty).join(' ');
}

/// Friendly validation error for an imported phrase, or null when the
/// (normalized) input is a valid BIP-39 mnemonic.
String? mnemonicInputError(String raw) {
  final normalized = normalizeMnemonic(raw);
  if (normalized.isEmpty) {
    return 'Enter your recovery phrase.';
  }
  final wordCount = normalized.split(' ').length;
  if (wordCount != 12 && wordCount != 24) {
    return 'A recovery phrase has 12 or 24 words (got $wordCount).';
  }
  if (!validateMnemonic(normalized)) {
    return 'That is not a valid recovery phrase. Check for typos.';
  }
  return null;
}
