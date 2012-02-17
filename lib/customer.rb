require File.dirname(__FILE__) + '/client'
require File.dirname(__FILE__) + '/credit_card'

module Eway
  module TokenPayments
    class Customer
      def initialize(attributes)
        @credit_card = CreditCard.new(attributes[:credit_card])
        @attributes = attributes.reject { |k,v| k == :credit_card }
      end

      def save
        attributes = @attributes
        attributes[:credit_card] = @credit_card.to_hash
        update(attributes)
      end

      def update(attributes)
      end

      def process_payment(details)
      end

      def process_payment_with_cvn(details)
      end

      def Customer.find(id)
        response = Customer.client.query_customer(id)
        Customer.response_to_customer(response)
      end

      def Customer.find_by_reference(reference)
      end

      def Customer.create(attributes)
      end

      def to_hash
        hash = @attributes
        hash[:credit_card] = @credit_card.to_hash
        return hash
      end

      private

      def Customer.client
        @@client ||= Client.new(Eway.credentials[:customer_id], Eway.credentials[:username], Eway.credentials[:password], Eway.test_mode ? true : false)
      end

      def Customer.response_to_customer(response)
        attributes = {}
        attributes[:credit_card] = {}
        response.each do |key, value|
          friendly_name = Eway.config['response_fields']['query_customer'][key]
          cc_prefix = Eway.config['api']['credit_card_prefix']
          if friendly_name.start_with?(cc_prefix)
            new_key = friendly_name.gsub(cc_prefix, '').to_sym
            attributes[:credit_card][new_key] = value
          else
            attributes[friendly_name.to_sym] = value
          end
        end
        Customer.new(attributes)
      end

      def method_missing(name, *args)
        if name == :credit_card
          return @credit_card
        else
          return @attributes[:name]
        end
      end
    end
  end
end
