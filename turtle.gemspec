# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'turtle/version'

Gem::Specification.new do |spec|
  spec.name          = 'turtle'
  spec.version       = Turtle::VERSION
  spec.authors       = ['linqueta']
  spec.email         = ['tecnologia@petlove.com.br']

  spec.licenses      = ['MIT']
  spec.summary       = 'A helper to use workers and topics with Ruby on Rails'
  spec.description   = 'A helper to use workers and topics with Ruby on Rails'
  spec.homepage      = 'https://github.com/petlove/turtle'

  spec.files         = Dir['{lib}/**/*', 'CHANGELOG.md', 'MIT-LICENSE', 'README.md']
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.5.1'

  spec.add_dependency 'aws-sns-configurator', '~> 0.2.0'
  spec.add_dependency 'aws-sqs-configurator', '~> 0.2.0'
  spec.add_dependency 'honeybadger', '~> 4.0'

  spec.add_development_dependency 'bundler', '~> 2.2.4'
  spec.add_development_dependency 'rake', '~> 10.0'
end
