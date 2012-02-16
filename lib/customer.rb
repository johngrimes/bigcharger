require File.dirname(__FILE__) + '/client'
require File.dirname(__FILE__) + '/credit_card'

module Eway
  class << self
    attr_accessor :credentials
    attr_accessor :test_mode
  end

  module TokenPayments
    class Customer
      CUSTOMER_ATTRIBUTE_MAP = {
        :managed_customer_id => :id,
        :customer_ref => :reference,
        :customer_title => :title,
        :customer_first_name => :first_name,
        :customer_last_name => :last_name,
        :customer_company => :company,
        :customer_job_desc => :job_description,
        :customer_email => :email,
        :customer_address => :address,
        :customer_suburb => :suburb,
        :customer_state => :state,
        :customer_post_code => :post_code,
        :customer_country => :country,
        :customer_phone1 => :phone_1,
        :customer_phone2 => :phone_2,
        :customer_fax => :fax,
        :customer_url => :url,
        :customer_comments => :comments
      }
      CREDIT_CARD_PREFIX = 'cc_'
      CREDIT_CARD_ATTRIBUTE_MAP = {
        :cc_name => :name,
        :cc_number => :number,
        :cc_expiry_month => :expiry_month,
        :cc_expiry_year => :expiry_year
      }

      def initialize(attributes)
        @credit_card = CreditCard.new(attributes[:credit_card])
        @attributes = attributes.reject { |k,v| k = :credit_card }
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

      def to_s
        return to_hash.inspect
      end

      private

      def Customer.client
        @@client ||= Client.new(Eway.credentials[:customer_id], Eway.credentials[:username], Eway.credentials[:password], Eway.test_mode ? true : false)
      end

      def Customer.response_to_customer(response)
        attributes = {}
        attributes[:credit_card] = {}
        response.each do |key, value|
          if key.to_s.start_with?(CREDIT_CARD_PREFIX)
            attributes[:credit_card][CREDIT_CARD_ATTRIBUTE_MAP[key]] = value
          else
            attributes[CUSTOMER_ATTRIBUTE_MAP[key]] = value
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
