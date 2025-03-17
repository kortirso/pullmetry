# frozen_string_literal: true

require_relative 'lib/authkeeper/version'

Gem::Specification.new do |spec|
  spec.name        = 'authkeeper'
  spec.version     = Authkeeper::VERSION
  spec.authors     = ['Bogdanov Anton']
  spec.email       = ['kortirso@gmail.com']
  spec.homepage    = 'https://github.com/kortirso/authkeeper'
  spec.summary     = 'Authentication engine.'
  spec.description = 'Authentication engine for Ruby on Rails projects.'
  spec.license     = 'MIT'

  spec.required_ruby_version = '>= 3.2' # rubocop: disable Gemspec/RequiredRubyVersion

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = 'https://github.com/kortirso/authkeeper/blob/master/CHANGELOG.md'

  spec.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  spec.add_dependency 'rails', '>= 7.1.3.4'
end
