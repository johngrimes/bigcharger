require 'rspec/core/rake_task'
require 'thor/rake_compat'

class Eway < Thor
  include Thor::RakeCompat

  RSpec::Core::RakeTask.new(:spec) do |t|
    t.rspec_opts = ['--options', '.rspec']
    t.pattern = 'spec/**/*_spec.rb'
  end 
end
