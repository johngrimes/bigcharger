require 'logger'

class BigCharger
  private

  def set_request_defaults
    @client.verbose = false
    @client.url = @endpoint
    @client.headers['Content-Type'] = 'text/xml'
  end

  def wrap_in_envelope(&block)
    envelope = Nokogiri::XML::Builder.new do |xml|
      xml.Envelope('xmlns:soap' => SOAP_NAMESPACE,
          'xmlns:man' => SERVICE_NAMESPACE) {
        xml.parent.namespace = xml.parent.namespace_definitions.find { |ns| ns.prefix == 'soap' }
        xml['soap'].Header {
          xml['man'].eWAYHeader {
            xml['man'].eWAYCustomerID @credentials[:customer_id]
            xml['man'].Username @credentials[:username]
            xml['man'].Password @credentials[:password]
          }
        }
        xml['soap'].Body {
          yield xml
        }
      }
    end
  end

  def post(envelope, action_name)
    @client.headers['SOAPAction'] = "#{SERVICE_NAMESPACE}/#{action_name}"
    record_request(@client, envelope.to_xml)
    @client.http_post @last_request[:body]
    log_last_request
    record_response(@client)
    log_last_response
    check_last_response_for_faults
    check_last_response_for_errors
    return @last_response[:body_document]
  end

  def record_request(request, body)
    @last_request = {}
    @last_request[:headers] = request.headers.clone
    @last_request[:body] = body
  end

  def record_response(response)
    @last_response = {}
    @last_response[:header_string] = response.header_str.clone
    @last_response[:body] = response.body_str.clone
    @last_response[:body_document] = Nokogiri::XML(response.body_str)
  end

  def log_operation(name, *args)
    log_string = "BigCharger##{name} called with: "
    log_string << args.map { |x| x.inspect }.join(', ')
    @logger.debug log_string
  end

  def log_last_request
    header_output = @last_request[:headers].map { |k,v| "#{k}: #{v}" }.join("\n")
    log_string = "BigCharger - Request sent to eWAY server\n"
    log_string << "#{header_output}\n#{@last_request[:body]}"
    @logger.debug log_string
  end

  def log_last_response
    body_output = @last_response[:body_document].serialize(:encoding => 'UTF-8') do |config|
      config.format.as_xml
    end
    log_string = "BigCharger - Response received from eWAY server\n"
    log_string << "#{@last_response[:header_string]}\n#{body_output}"
    @logger.debug log_string
  end

  def check_last_response_for_faults
    faults = @last_response[:body_document].xpath('//soap:Fault', { 'soap' => SOAP_NAMESPACE })
    unless faults.empty?
      fault = faults.first
      fault_code = fault.xpath('faultcode').first.text
      fault_message = fault.xpath('faultstring').first.text
      raise Error, "eWAY server responded with \"#{fault_message}\" (#{fault_code})"
    end
  end

  def check_last_response_for_errors
    status_info = @last_response[:header_string].match(/HTTP\/[\d\.]+ (\d{3}) ([\w\s]+)[\r\n]/)
    status_code, status_reason = status_info[1].strip, status_info[2].strip
    unless ['200', '100'].include? status_code
      raise Error, "eWAY server responded with \"#{status_reason}\" (#{status_code})"
    end
  end

  def node_to_hash(node)
    hash = {}
    node.children.each do |node|
      if node.type == Nokogiri::XML::Node::ELEMENT_NODE
        hash[node.name] = node.text.empty? ? nil : node.text
      end
    end
    return hash
  end

  def node_collection_to_array(node)
    array = []
    node.children.each do |node|
      if node.type == Nokogiri::XML::Node::ELEMENT_NODE
        array << node_to_hash(node)
      end
    end
    return array
  end
end
