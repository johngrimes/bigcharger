Gem::Specification.new do |s|
  s.name = 'bigcharger'
  s.version = '0.1.0'
  s.description = 'A lightweight Ruby library for interfacing with the eWAY Token Payments API.'
  s.summary = s.description
  s.authors = ['John Grimes']
  s.email = 'john@smallspark.com.au'
  s.homepage = 'http://github.com/johngrimes/bigcharger'
  s.require_paths = ['lib']
  s.extra_rdoc_files = [
    'LICENSE',
    'README.markdown'
  ]
  s.files = Dir['{lib,spec,tasks}/**/*']
  s.test_files = Dir['{spec}/**/*']
  s.required_rubygems_version = Gem::Requirement.new('>= 1.3.6') if s.respond_to? :required_rubygems_version=

  s.add_dependency 'createsend', '~> 0.2'

  s.add_development_dependency 'bundler', '~> 1'
  s.add_development_dependency 'rspec-rails', '~> 2'
  s.add_development_dependency 'mocha', '~> 0.9'
  s.add_development_dependency 'cucumber-rails', '~> 0.3'
  s.add_development_dependency 'webrat', '~> 0.7'
  s.add_development_dependency 'nokogiri', '~> 1.4.3'
end
