class BigCharger
  SOAP_NAMESPACE = 'http://schemas.xmlsoap.org/soap/envelope/'
  SERVICE_NAMESPACE = 'https://www.eway.com.au/gateway/managedpayment'
  ENDPOINT = 'https://www.eway.com.au/gateway/ManagedPaymentService/managedCreditCardPayment.asmx'
  TEST_ENDPOINT = 'https://www.eway.com.au/gateway/ManagedPaymentService/test/managedCreditCardPayment.asmx'

  # List of fields (with significant ordering as per WSDL) for customer 
  # requests
  CUSTOMER_REQUEST_FIELDS = [
    'Title',
    'FirstName',
    'LastName',
    'Address',
    'Suburb',
    'State',
    'Company',
    'PostCode',
    'Country',
    'Email',
    'Fax',
    'Phone',
    'Mobile',
    'CustomerRef',
    'JobDesc',
    'Comments',
    'URL',
    'CCNumber',
    'CCNameOnCard',
    'CCExpiryMonth',
    'CCExpiryYear'
  ]
end
