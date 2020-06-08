# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vagrant-goodhosts/version'

Gem::Specification.new do |spec|
  spec.name          = 'vagrant-goodhosts'
  spec.version       = VagrantPlugins::GoodHosts::VERSION
  spec.authors       = ['Daniele Scasciafratte']
  spec.email         = ['mte90net@gmail.com']
  spec.description   = %q{Enables Vagrant to update hosts file on the host machine with goodhosts}
  spec.summary       = spec.description
  spec.homepage      = 'https://github.com/goodhosts/vagrant'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.files     += Dir.glob("lib/vagrant-goodhosts/bundle/*")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
end
