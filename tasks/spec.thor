require 'rspec/core/rake_task'
require 'thor/rake_compat'

class Eway < Thor
  include Thor::RakeCompat

  RSpec::Core::RakeTask.new(:spec) do |t|
    t.rspec_opts = ['--options', 'spec/spec.opts']
    t.pattern = 'spec/**/*_spec.rb'
  end 
end
