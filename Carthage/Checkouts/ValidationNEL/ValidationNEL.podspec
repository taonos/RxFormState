Pod::Spec.new do |spec|
  spec.name = "ValidationNEL"
  spec.version = "0.2.0"
  spec.summary = "A Swift implementation of ValidationNEL: accumulating more than one failure."
  spec.homepage = "https://github.com/Hxucaa/ValidationNEL"
  spec.license = { type: 'MIT', file: 'LICENSE' }
  spec.authors = { "Lance Zhu" => 'lancezhu77@gmail.com' }

  spec.ios.deployment_target = "8.0"
  spec.osx.deployment_target = "10.9"
  spec.tvos.deployment_target = "9.1"
  spec.watchos.deployment_target = "2.1"
  spec.requires_arc = true

  spec.source = { git: "https://github.com/Hxucaa/ValidationNEL.git", tag: "v#{spec.version}", submodules: true }
  spec.source_files = "Sources/**/*.{h,swift}"

  spec.dependency "Swiftz", "~> 0.5.0"
end
