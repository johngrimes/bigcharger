require 'nokogiri'
require 'curb'
require 'logger'

module Eway
  module TokenPayments
    class Client
      attr_reader :config
      attr_accessor :logger

      def initialize(customer_id, username, password, test_mode = false)
        @config = YAML::load(File.open('config/client.yml'))
        @credentials = { 
          :customer_id => customer_id,
          :username => username,
          :password => password
        }
        @endpoint = test_mode ? @config['soap']['test_endpoint'] : @config['soap']['endpoint']
        @client = Curl::Easy.new
        set_request_defaults
      end

      def create_customer(customer_fields = {})
        envelope = wrap_in_envelope do |xml|
          xml['man'].CreateCustomer {
            @config['fields']['create_customer'].each do |field|
              xml['man'].send(field, customer_fields[field]) if customer_fields[field]
            end
          }
        end
        response = post(envelope, 'CreateCustomer')
        result = response.xpath('//man:CreateCustomerResult', { 'man' => @config['soap']['service_namespace'] }).first
        return result ? result.text : false
      end

      def process_payment
      end

      def process_payment_with_cvn
      end

      def query_customer(managed_customer_id)
        envelope = wrap_in_envelope do |xml|
          xml['man'].QueryCustomer {
            xml['man'].managedCustomerID managed_customer_id
          }
        end
        response = post(envelope, 'QueryCustomer')
        result = response.xpath('//man:QueryCustomerResult', { 'man' => @config['soap']['service_namespace'] }).first
        return result ? node_to_hash(result) : false
      end

      def query_customer_by_reference
      end

      def query_payment
      end

      def update_customer
      end

      private

      def set_request_defaults
        @client.verbose = false
        @client.url = @endpoint
        @client.headers['Content-Type'] = 'text/xml'
      end

      def wrap_in_envelope(&block)
        envelope = Nokogiri::XML::Builder.new do |xml|
          xml.Envelope('xmlns:soap' => @config['soap']['soap_namespace'],
              'xmlns:man' => @config['soap']['service_namespace']) {
            xml.parent.namespace = xml.parent.namespace_definitions.find { |ns| ns.prefix == 'soap' }
            xml['soap'].Header {
              xml['man'].eWAYHeader {
                xml['man'].eWAYCustomerID @credentials[:customer_id]
                xml['man'].Username @credentials[:username]
                xml['man'].Password @credentials[:password]
              }
            }
            xml['soap'].Body {
              yield xml
            }
          }
        end
      end

      def post(envelope, action_name)
        @client.headers['SOAPAction'] = "#{@config['soap']['service_namespace']}/#{action_name}"
        record_request(@client, envelope.to_xml)
        @client.http_post @last_request[:body]
        log_last_request
        record_response(@client)
        log_last_response
        check_last_response_for_faults
        check_last_response_for_errors
        return @last_response[:body_document]
      end

      def record_request(request, body)
        @last_request = {}
        @last_request[:headers] = request.headers.clone
        @last_request[:body] = body
      end

      def record_response(response)
        @last_response = {}
        @last_response[:header_string] = response.header_str.clone
        @last_response[:body] = response.body_str.clone
        @last_response[:body_document] = Nokogiri::XML(response.body_str)
      end

      def log_last_request
        if @logger
          header_output = @last_request[:headers].map { |k,v| "#{k}: #{v}" }.join("\n")
          log_string = "Eway::TokenPayments::Client - Request sent\n"
          log_string << "#{header_output}\n#{@last_request[:body]}"
          @logger.info log_string
        end
      end

      def log_last_response
        if @logger
          body_output = @last_response[:body_document].serialize(:encoding => 'UTF-8') do |config|
            config.format.as_xml
          end
          log_string = "Eway::TokenPayments::Client - Response received\n"
          log_string << "#{@last_response[:header_string]}\n#{body_output}"
          @logger.info log_string
        end
      end

      def check_last_response_for_faults
        faults = @last_response[:body_document].xpath('//soap:Fault', { 'soap' => @config['soap']['soap_namespace'] })
        unless faults.empty?
          fault = faults.first
          fault_code = fault.xpath('faultcode').first.text
          fault_message = fault.xpath('faultstring').first.text
          raise Error, "eWAY server responded with \"#{fault_message}\" (#{fault_code})"
        end
      end

      def check_last_response_for_errors
        status_info = @last_response[:header_string].match(/HTTP\/[\d\.]+ (\d{3}) ([\w\s]+)[\r\n]/)
        status_code, status_reason = status_info[1].strip, status_info[2].strip
        unless ['200', '100'].include? status_code
          raise Error, "eWAY server responded with \"#{status_reason}\" (#{status_code})"
        end
      end

      def node_to_hash(node)
        hash = {}
        node.children.each do |node|
          hash[node.name] = node.text.empty? ? nil : node.text
        end
        return hash
      end
    end

    class Error < Exception; end
  end
end
