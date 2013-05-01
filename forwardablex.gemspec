# -*- ruby -*-
# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'forwardablex/version'

Gem::Specification.new do |gem|
  gem.name          = "forwardablex"
  gem.version       = ForwardableX::VERSION
  gem.authors       = ["Keita Yamaguchi"]
  gem.email         = ["keita.yamaguchi@gmail.com"]
  gem.description   = "This is a library to extend Forwardable functions"
  gem.summary       = "Forwardable extension"
  gem.homepage      = "https://github.com/keita/forwardablex"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.add_development_dependency "rake"
  gem.add_development_dependency "bacon"
  gem.add_development_dependency "yard", "~> 0.8.5"
  gem.add_development_dependency "redcarpet"
end
