# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'preserves/version'

Gem::Specification.new do |spec|
  spec.name          = "preserves"
  spec.version       = Preserves::VERSION
  spec.authors       = ["Craig Buchek"]
  spec.email         = ["craig@boochtek.com"]
  spec.summary       = %q{Minimalist ORM, using the Data Mapper pattern}
  spec.description   = %q{Experimental, opinionated, minimalist ORM (object-relational mapper) for Ruby, using the Data Mapper pattern.}
  spec.homepage      = "https://github.com/boochtek/ruby_preserves"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3.0.0.rc1"
  spec.add_development_dependency "rubygems-tasks"
end
