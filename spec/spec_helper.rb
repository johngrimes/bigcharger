require 'rubygems'
require 'bundler'
Bundler.setup(:default, :development)

require 'webmock/rspec'
require 'simplecov'

WebMock.disable_net_connect!
SimpleCov.start

module BigChargerSpecHelpers
  def message(name)
    file = File.open(File.join(File.dirname(__FILE__), "./messages/#{name.to_s}.xml"), 'rb')
    return file.read
  end

  def request_document
    Nokogiri::XML(@request.body)
  end

  def spec_document(name)
    Nokogiri::XML(message(name))
  end
end
