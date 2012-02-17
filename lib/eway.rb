require 'bundler'
Bundler.setup(:default)

require File.dirname(__FILE__) + '/customer'

module Eway
  class << self
    attr_accessor :credentials
    attr_accessor :test_mode
    attr_accessor :logger
  end

  def Eway.config
    @config ||= YAML::load(File.open(File.expand_path('../../config/eway.yml', __FILE__)))
  end

  Eway.logger = Logger.new('/dev/null')
end  
