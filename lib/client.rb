require 'savon'

Savon.configure do |config|
  config.log = false
end
HTTPI.log = false

module Eway
  module TokenPayments
    class Client
      def initialize(customer_id, username, password)
        @credentials = { 
          'man:eWAYCustomerID' => customer_id,
          'man:Username' => username,
          'man:Password' => password
        }
        @client = Savon::Client.new do
          wsdl.endpoint = 'https://www.eway.com.au/gateway/ManagedPaymentService/managedCreditCardPayment.asmx'
          wsdl.namespace = 'https://www.eway.com.au/gateway/managedpayment'
        end
      end

      def create_customer(customer)
        response = @client.request(:man, 'CreateCustomer') do |soap|
          soap.header = { 'man:eWAYHeader' => @credentials }
          soap.body = customer.inject({}) do |result, pair|
            result["man:#{pair[0]}"] = pair[1]
            result
          end
        end
        return response.to_hash[:create_customer_response][:create_customer_result]
      end

      def process_payment
      end

      def process_payment_with_cvn
      end

      def query_customer(managed_customer_id)
        response = @client.request(:man, 'QueryCustomer') do |soap|
          soap.header = { 'man:eWAYHeader' => @credentials }
          soap.body = { 'man:managedCustomerID' => 9876543211000 }
        end
        return response.to_hash[:query_customer_response][:query_customer_result]
      end

      def query_customer_by_reference
      end

      def query_payment
      end

      def update_customer
      end
    end
  end
end
