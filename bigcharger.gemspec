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

  s.add_dependency 'nokogiri', '~> 1.5.0'
  s.add_dependency 'curb', '~> 0.8.0'

  s.add_development_dependency 'rspec', '~> 2.7.0'
  s.add_development_dependency 'thor', '~> 0.14.6'
  s.add_development_dependency 'webmock', '~> 1.7.10'
  s.add_development_dependency 'simplecov', '~> 0.5.4'
  s.add_development_dependency 'yard', '~> 0.7.5'
  s.add_development_dependency 'redcarpet', '~> 2.1.0'
end
