#!/usr/bin/env ruby
require 'nokogiri'

wsdl_document = Nokogiri::XML(File.open('./managedpayment.wsdl'))
results = wsdl_document.xpath('//s:schema')

schema_node = results.first
schema_node.attribute_nodes.each(&:remove)
schema_node.set_attribute('xmlns:s', 'http://www.w3.org/2001/XMLSchema')
schema_document = Nokogiri::XML::Document.new
schema_document.root = schema_node

schema_document.remove_namespaces!
schema_document.xpath('//*').each do |node|
  node.name = "s:#{node.name}"
end

xml = schema_document.serialize(:encoding => 'UTF-8') do |config|
  config.format.as_xml
end
xml.gsub!(/tns:/, '')
File.open('./managedpayment-schema.xsd', 'w') do |file|
  file.write(xml)
end
