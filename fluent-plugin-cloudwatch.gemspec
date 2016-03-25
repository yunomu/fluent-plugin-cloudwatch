# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |gem|
  gem.name          = "fluent-plugin-cloudwatch"
  gem.version       = "1.2.13"
  gem.authors       = ["Yusuke Nomura", "kenjiskywalker", "FUJIWARA Shunichiro"]
  gem.email         = ["yunomu@gmail.com", "git@kenjiskywalker.org", "fujiwara.shunichiro@gmail.com"]
  gem.description   = %q{Input plugin for AWS CloudWatch.}
  gem.homepage      = "https://github.com/yunomu/fluent-plugin-cloudwatch"
  gem.summary       = gem.description
  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.add_dependency "fluentd", ">= 0.10.30"
  gem.add_dependency "aws-sdk-v1", "~> 1.59.1"
  gem.add_development_dependency "rake", ">= 0.9.2"
  gem.add_development_dependency "test-unit", ">= 3.1.0"
  gem.license = 'MIT'
end
