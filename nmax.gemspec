require_relative "lib/nmax/version"

Gem::Specification.new do |s|
  s.name = "nmax"
  s.version = NMax::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ["epsylonix"]
  s.email = ["epsylonix@gmail.com"]
  s.homepage = "https://github.com/epsylonix/nmax"
  s.summary = "CLI tool to collect top N numbers from a text"
  s.description = "CLI tool to collect top N numbers from a text data through stadart input"
  s.files = Dir.glob("{bin,lib,tests}/**/*") + %w(README.md Rakefile)
  s.require_path = 'lib'
  s.executables = ["nmax"]
  s.required_ruby_version = ">= 1.9.3"
  s.license = 'MIT'
end

