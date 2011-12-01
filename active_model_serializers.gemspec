# -*- encoding: utf-8 -*-
Gem::Specification.new do |gem|
  gem.authors       = ["José Valim"]
  gem.email         = ["jose.valim@gmail.com"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "active_model_serializers"
  gem.require_paths = ["lib"]
  gem.version       = "0.0.1"

  gem.add_dependency 'activemodel', '~> 3.0'

  gem.add_development_dependency "rails", "~> 3.0"
end
