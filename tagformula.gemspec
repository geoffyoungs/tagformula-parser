# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tagformula/version'

Gem::Specification.new do |spec|
  spec.name          = "tagformula"
  spec.version       = Tagformula::VERSION
  spec.authors       = ["Geoff Youngs\n\n\n"]
  spec.email         = ["git@intersect-uk.co.uk"]
  spec.summary       = %q{Simple formula parser & matcher}
  spec.description   = %q{Match tag formulas with simple boolean operations against lists of strings.  e.g. the formula "foo & ! bar" would match ['foo'], but not ['foo', 'bar'] }
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 2.14.1"
end
