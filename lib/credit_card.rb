require 'credit_card_validator'

module Eway
  class CreditCard
    attr_accessor :name
    attr_reader :number, :expiry_month, :expiry_year

    def initialize(attributes)
      @name = attributes[:name]
      number=(attributes[:number])
      expiry_month=(attributes[:expiry_month].to_i)
      expiry_year=(attributes[:expiry_year].to_i)
    end

    def expired?
      current_month, current_year = Time.now.utc.month, Time.now.utc.year
      if current_year > @expiry_year ||
          (current_year == @expiry_year && current_month > @expiry_month)
        return false
      else
        return true
      end
    end

    def number=(new_number)
      CreditCard.validate_number(new_number)
      @number = new_number
    end

    def expiry_month=(new_expiry_month)
      CreditCard.validate_expiry_month(new_expiry_month)
      @expiry_month = new_expiry_month
    end

    def expiry_year=(new_expiry_year)
      CreditCard.validate_expiry_year(new_expiry_year)
      @expiry_year = new_expiry_year
    end

    def to_hash
      { 
        :name => @name,
        :number = @number,
        :expiry_month => @expiry_month,
        :expiry_year => @expiry_year
      }
    end

    def to_s
      to_hash.inspect
    end

    private

    def CreditCard.validate_number(number)
      unless CreditCardValidator::Validator.valid?(number)
        raise CreditCardValidationError, 'Credit card number is invalid'
      end
    end

    def CreditCard.validate_expiry_month(expiry_month)
      unless expiry_month.class == Integer && 
          expiry_month > 0 && expiry_month < 13
        raise CreditCardValidationError, 'Credit card expiry month is invalid'
      end
    end

    def CreditCard.validate_expiry_year(expiry_year)
      unless expiry_year.class == Integer && 
          expiry_year > 1970 && expiry_year < 10000
        raise CreditCardValidationError, 'Credit card expiry year is invalid'
      end
    end
  end

  class CreditCardValidationError < Exception; end
  class CreditCardExpiredError < Exception; end
end
