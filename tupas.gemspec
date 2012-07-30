# -*- encoding: utf-8 -*-
require File.expand_path('../lib/tupas/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Jaakko Suutarla", "Jaakko Juutila"]
  gem.email         = ["jaakko@suutarla.com", "jaakko.juutila@gmail.com"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "tupas"
  gem.require_paths = ["lib"]
  gem.version       = Tupas::VERSION

  gem.add_runtime_dependency 'rack'
  gem.add_runtime_dependency 'multi_json'
  gem.add_runtime_dependency 'oj'

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'bundler'
  gem.add_development_dependency 'guard'
  gem.add_development_dependency 'guard-bundler'
  gem.add_development_dependency 'guard-minitest'
  gem.add_development_dependency 'minitest', '~> 2.9.1'
  gem.add_development_dependency 'minitest-matchers'
  gem.add_development_dependency 'purdytest'
  gem.add_development_dependency 'pry'
  gem.add_development_dependency 'pry-doc'
  gem.add_development_dependency 'pry-git'
  gem.add_development_dependency 'fakeweb'
  gem.add_development_dependency 'mocha'
  gem.add_development_dependency 'differ'
  gem.add_development_dependency 'timecop'
end
