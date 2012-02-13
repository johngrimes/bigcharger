require 'savon'

Savon.configure do |config|
  config.log = false
end
HTTPI.log = false

module Eway
  module TokenPayments
    class Client
      ENDPOINT = 'https://www.eway.com.au/gateway/ManagedPaymentService/managedCreditCardPayment.asmx'
      TEST_ENDPOINT = 'https://www.eway.com.au/gateway/ManagedPaymentService/test/managedCreditCardPayment.asmx'
      NAMESPACE = 'https://www.eway.com.au/gateway/managedpayment'

      def initialize(customer_id, username, password, test_mode = false)
        @credentials = { 
          'man:eWAYCustomerID' => customer_id,
          'man:Username' => username,
          'man:Password' => password
        }
        @client = Savon::Client.new do
          wsdl.endpoint = test_mode ? TEST_ENDPOINT : ENDPOINT
          wsdl.namespace = NAMESPACE
        end
      end

      def create_customer(customer = {})
        handle_failure do
          response = @client.request(:man, "CreateCustomer") do |soap, wsdl, http|
            http.headers['SOAPAction'] = "#{NAMESPACE}/CreateCustomer"
            soap.header = { 'man:eWAYHeader' => @credentials }
            soap.body = customer.inject({}) do |result, pair|
              result["man:#{pair[0]}"] = pair[1]
              result
            end
          end
          return response.to_hash[:create_customer_response][:create_customer_result]
        end
      end

      def process_payment
      end

      def process_payment_with_cvn
      end

      def query_customer(managed_customer_id)
        handle_failure do
          response = @client.request(:man, 'QueryCustomer') do |soap, wsdl, http|
            http.headers['SOAPAction'] = "#{NAMESPACE}/QueryCustomer"
            soap.header = { 'man:eWAYHeader' => @credentials }
            soap.body = { 'man:managedCustomerID' => managed_customer_id }
          end
          return response.to_hash[:query_customer_response][:query_customer_result]
        end
      end

      def query_customer_by_reference
      end

      def query_payment
      end

      def update_customer
      end

      private

      def handle_failure
        yield
      rescue Savon::HTTP::Error => e
        raise_failure_code_error(e)
      rescue Savon::SOAP::Fault => e
        raise_soap_error(e)
      end

      def raise_failure_code_error(e)
        raise Error, "eWAY server responded with \"#{e.message}\" (#{e.http.code})"
      end

      def raise_soap_error(e)
        raise Error, e.message.gsub('(soap:Client)', '').strip
      end
    end

    class Error < Exception; end
  end
end
