# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Yusuke Nomura"]
  gem.email         = ["yunomu@gmail.com"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{Output filter plugin}
  gem.homepage      = "https://github.com/yunomu"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "fluent-plugin-cloudwatch"
  gem.require_paths = ["lib"]
  gem.version       = "0.0.1"

  gem.add_development_dependency "fluentd"
  gem.add_runtime_dependency "fluentd"
end
