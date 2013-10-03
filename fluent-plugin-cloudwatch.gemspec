# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |gem|
  gem.name          = "fluent-plugin-cloudwatch"
  gem.version       = "1.2.5"
  gem.authors       = ["Yusuke Nomura", "kenjiskywalker"]
  gem.email         = ["yunomu@gmail.com", "git@kenjiskywalker.org"]
  gem.description   = %q{Input plugin for AWS CloudWatch.}
  gem.homepage      = "https://github.com/yunomu/fluent-plugin-cloudwatch"
  gem.summary       = gem.description
  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.add_dependency "fluentd", "~> 0.10.30"
  gem.add_dependency "aws-sdk", "= 1.8.3"
  gem.license = 'MIT'
end
