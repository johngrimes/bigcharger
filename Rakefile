require 'rspec/core/rake_task'

desc 'Run specs'
task :default => :spec

desc 'Run specs'
RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = ['--options', '.rspec']
  t.pattern = 'spec/**/*_spec.rb'
end
