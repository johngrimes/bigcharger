require 'rubygems'
require 'bundler'
Bundler.setup(:default, :development)

require 'webmock/rspec'

# DEBUG
require 'pry'

WebMock.disable_net_connect!

module ClientSpecHelpers
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
