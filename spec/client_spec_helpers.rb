module ClientSpecHelpers
  def register_eway_uri(response_message)
    FakeWeb.register_uri(
      :post, 
      'https://www.eway.com.au/gateway/ManagedPaymentService/managedCreditCardPayment.asmx', 
      :body => message(response_message)
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
