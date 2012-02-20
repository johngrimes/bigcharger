require File.dirname(__FILE__) + '/bigcharger/config'
require File.dirname(__FILE__) + '/bigcharger/utils'
require File.dirname(__FILE__) + '/bigcharger/ops'

class BigCharger
  attr_accessor :logger

  def initialize(customer_id, username, password, test_mode = false, logger = Logger.new('/dev/null'))
    @credentials = { 
      :customer_id => customer_id,
      :username => username,
      :password => password
    }
    @client = Curl::Easy.new
    @endpoint = test_mode ? TEST_ENDPOINT : ENDPOINT
    @logger = logger
    set_request_defaults
  end

  class Error < Exception; end
end
