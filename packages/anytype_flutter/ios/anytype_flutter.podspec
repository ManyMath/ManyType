#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint anytype_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'anytype_flutter'
  s.version          = '0.0.2'
  s.summary          = 'Flutter integration for the anytype SDK.'
  s.description      = <<-DESC
Builds the manytype_quic_ffi QUIC bridge via cargokit and links it into the
anytype_flutter plugin for use over FFI.
                       DESC
  s.homepage         = 'https://github.com/ManyMath/ManyType'
  s.license          = { :file => '../LICENSE' }
  s.author           = 'ManyMath LLC'

  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'

  # Build the `manytype_quic_ffi` Rust crate in ../rust (static lib) via cargokit and
  # force-link it into the plugin framework.
  s.script_phase = {
    :name => 'Build manytype_quic_ffi',
    :script => 'sh "$PODS_TARGET_SRCROOT/../cargokit/build_pod.sh" ../rust manytype_quic_ffi',
    :execution_position => :before_compile,
    :input_files => ['${BUILT_PRODUCTS_DIR}/cargokit_phony'],
    :output_files => ['${BUILT_PRODUCTS_DIR}/libmanytype_quic_ffi.a'],
  }

  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
    'OTHER_LDFLAGS' => '-force_load ${BUILT_PRODUCTS_DIR}/libmanytype_quic_ffi.a',
  }
  s.swift_version = '5.0'
end
