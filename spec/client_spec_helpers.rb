module ClientSpecHelpers
  def register_valid_response(response)
    FakeWeb.register_uri(
      :post, 
      'https://www.eway.com.au/gateway/ManagedPaymentService/managedCreditCardPayment.asmx', 
      :body => message("#{response}_response".to_sym)
    )
  end

  def register_fault_response
    FakeWeb.register_uri(
      :post, 
      'https://www.eway.com.au/gateway/ManagedPaymentService/managedCreditCardPayment.asmx', 
      :body => message(:fault_response),
      :status => ['500', 'Internal Server Error']
    )
  end

  def register_blank_response(code, message = '')
    FakeWeb.register_uri(
      :post, 
      'https://www.eway.com.au/gateway/ManagedPaymentService/managedCreditCardPayment.asmx', 
      :status => [code.to_s, message]
    )
  end

  def message(name)
    file = File.open(File.join(File.dirname(__FILE__), "./messages/#{name.to_s}.xml"), 'rb')
    return file.read
  end

  def request_document
    Nokogiri::XML(@request.body)
  end

  def spec_document(name)
    Nokogiri::XML(message(name))
  end
end
