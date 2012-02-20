# eWAY SOAP Client - Token Payments API

**Caution, watch your step - this is a work in progress.**

The idea of this project is to build a lightweight Ruby library for
interfacing with the [eWAY Token Payments
API](http://www.eway.com.au/Developer/eway-api/token-payments.aspx).

The only other Ruby library out there for this (that I know of) consists
of a [fork of the ActiveMerchant
library](https://github.com/madpilot/active_merchant) that does not seem
to be actively maintained. It also does not support all of the
operations within the API.

## Setup

```ruby
Eway.credentials = {
  :customer_id => '87654321',
  :username => 'test@eway.com.au',
  :password => 'test123'
}
```

## Create a new customer

```ruby
customer = Eway::TokenPayments::Customer.create(
  :reference => 'XYZ123',
  :title => 'Mr',
  :first_name => 'John',
  :last_name => 'Doe',
  :company => 'Small Spark',
  :job_description => 'Software Developer',
  :email => 'johndoe@smallspark.com.au',
  :address => '15 Dundas Court',
  :suburb => 'Phillip',
  :state => 'ACT',
  :post_code => '2606',
  :country => 'Australia',
  :phone_1 => '+61 2 1234 5678',
  :phone_2 => '+61 4 1234 5678',
  :fax => '+61 2 1234 5679',
  :url => 'http://www.smallspark.com.au',
  :comments => 'Our best customer!',
  :credit_card => {
    :name => 'John Doe',
    :number => '1234567890123456',
    :expiry_month => '02',
    :expiry_year => '2012'
  }
)
```

## Process a payment

```ruby
customer.process_payment(
  :amount => 1050,  # Amount in cents
  :invoice_reference => 'INV-80251',
  :invoice_description => 'Pants alteration'
)

# Add CVN for extra security
customer.process_payment(
  :amount => 1050,  # Amount in cents
  :invoice_reference => 'INV-80251',
  :invoice_description => 'Pants alteration',
  :cvn => '123'
)
```

## Find a customer

```ruby
# Find a customer using the managed customer ID
customer = Eway::TokenPayments::Customer.find(12345)

# Find a customer using the reference you supplied when you created the
# customer
customer = Eway::TokenPayments::Customer.find_by_reference('67890')
```

## Get list of payments for a customer

```ruby
payments = customer.payments
```

## Update a customer

```ruby
customer.update(
  :credit_card => {
    :name => 'John Doe',
    :number => '0987654321098765',
    :expiry_month => '02',
    :expiry_year => '2018'
  }
)
```

Suggestions and criticisms are welcome, please feel free to send me a
message.
