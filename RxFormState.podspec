Pod::Spec.new do |spec|
  spec.name = "RxFormState"
  spec.version = "0.0.1"
  spec.summary = "Simple management for form states."
  spec.homepage = "https://github.com/Hxucaa/RxFormState"
  spec.license = { type: 'MIT', file: 'LICENSE' }
  spec.authors = { "Lance Zhu" => 'lancezhu77@gmail.com' }

  spec.platform = :ios, "8.2"
  spec.requires_arc = true
  spec.source = { git: "https://github.com/Hxucaa/RxFormState.git", tag: "v#{spec.version}", submodules: true }
  spec.source_files = "Sources/**/*.{h,swift}"

  spec.dependency "RxSwift", " ~> 2.0"
  spec.dependency "ValidationNEL", "~> 0.3.0"
end
