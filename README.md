# BigCharger - eWAY Token Payments Client

The idea of this project is to build a lightweight Ruby library for
interfacing with the [eWAY Token Payments
API](http://www.eway.com.au/Developer/eway-api/token-payments.aspx).

Documentation: 
http://www.rubydoc.info/gems/bigcharger

## Installation

```ruby
gem install bigcharger
```

## Setup

```ruby
client = BigCharger.new(
  '87654321', 
  'test@eway.com.au', 
  'test123'
)
```

## Create a new customer

```ruby
client.create_customer({
  'CustomerRef' => 'Test 123',
  'Title' => 'Mr.',
  'FirstName' => 'Jo',
  'LastName' => 'Smith',
  'Company' => 'company',
  'JobDesc' => 'Analyst',
  'Email' => 'test@eway.com.au',
  'Address' => '15 Dundas Court',
  'Suburb' => 'phillip',
  'State' => 'act',
  'PostCode' => '2606',
  'Country' => 'au',
  'Phone' => '02111111111',
  'Mobile' => '04111111111',
  'Fax' => '111122222',
  'URL' => 'http://eway.com.au',
  'Comments' => 'Comments',
  'CCNameOnCard' => 'Jo Smith',
  'CCNumber' => '444433XXXXXX1111',
  'CCExpiryMonth' => '08',
  'CCExpiryYear' => '15'
})
# => "9876543211000" (managedCustomerID of new customer)
```

## Process a payment

```ruby
client.process_payment(
  9876543211000,
  1000,
  'INV-80251',
  'Pants alteration'
)
# => {
#   'ewayTrxnError' => '00,Transaction Approved(Test Gateway)', 
#   'ewayTrxnStatus' => 'True', 
#   'ewayTrxnNumber' => '10498', 
#   'ewayReturnAmount' => '1000', 
#   'ewayAuthCode' => '123456'
# }

# Alternatively, improve security by requiring a CVN/CVV
client.process_payment_with_cvn(
  9876543211000,
  1000,
  '123',
  'INV-80251',
  'Pants alteration'
)
```

## Find a customer

```ruby
# Find a customer using the managed customer ID
client.query_customer(9876543211000)
# => {
#   'ManagedCustomerID' => '9876543211000', 
#   'CustomerRef' => 'Test 123', 
#   'CustomerTitle' => 'Mr.', 
#   'CustomerFirstName' => 'Jo', 
#   'CustomerLastName' => 'Smith', 
#   'CustomerCompany' => 'company', 
#   'CustomerJobDesc' => nil, 
#   'CustomerEmail' => 'test@eway.com.au', 
#   'CustomerAddress' => '15 Dundas Court', 
#   'CustomerSuburb' => 'phillip', 
#   'CustomerState' => 'act', 
#   'CustomerPostCode' => '2606', 
#   'CustomerCountry' => 'au', 
#   'CustomerPhone1' => '02111111111', 
#   'CustomerPhone2' => '04111111111', 
#   'CustomerFax' => '111122222', 
#   'CustomerURL' => 'http://eway.com.au', 
#   'CustomerComments' => 'Comments', 
#   'CCName' => 'Jo Smith', 
#   'CCNumber' => '444433XXXXXX1111', 
#   'CCExpiryMonth' => '08', 
#   'CCExpiryYear' => '15'
# }

# Find a customer using the reference you supplied when you created the
# customer
client.query_customer_by_reference('Test 123')
```

## Get list of payments for a customer

```ruby
client.query_payment(9876543211000)
# => [
#   {
#     'TotalAmount' => '1000', 
#     'Result' => '1', 
#     'ResponseText' => 'Approved', 
#     'TransactionDate' => '2012-02-20T00:00:00+11:00', 
#     'ewayTrxnNumber' => '1'
#   }, 
#   {
#     'TotalAmount' => '1008', 
#     'Result' => '1', 
#     'ResponseText' => 'Approved', 
#     'TransactionDate' => '2012-02-20T00:00:00+11:00', 
#     'ewayTrxnNumber' => '2'
#   }
# ]
```

## Update a customer

```ruby
client.update_customer(
  9876543211000,
  {
    'CCNameOnCard' => 'Jo Smith',
    'CCNumber' => '444433XXXXXX2222',
    'CCExpiryMonth' => '06',
    'CCExpiryYear' => '22'
  }
)
# => true
```
