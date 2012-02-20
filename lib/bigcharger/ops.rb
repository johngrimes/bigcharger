require 'nokogiri'
require 'curb'

class BigCharger
  def create_customer(customer_fields = {})
    log_operation(:create_customer, customer_fields)
    envelope = wrap_in_envelope do |xml|
      xml['man'].CreateCustomer {
        CUSTOMER_REQUEST_FIELDS.each do |field|
          xml['man'].send(field, customer_fields[field]) if customer_fields[field]
        end
      }
    end
    response = post(envelope, 'CreateCustomer')
    result = response.xpath('//man:CreateCustomerResult', { 'man' => SERVICE_NAMESPACE }).first
    return result ? result.text : false
  end

  def process_payment(managed_customer_id, amount, invoice_ref = nil, invoice_desc = nil)
    log_operation(:process_payment, managed_customer_id, amount, invoice_ref, invoice_desc)
    envelope = wrap_in_envelope do |xml|
      xml['man'].ProcessPayment {
        xml['man'].managedCustomerID managed_customer_id
        xml['man'].amount amount
        xml['man'].invoiceReference invoice_ref if invoice_ref
        xml['man'].invoiceDescription invoice_desc if invoice_desc
      }
    end
    response = post(envelope, 'ProcessPayment')
    result = response.xpath('//man:ProcessPaymentResponse/man:ewayResponse', { 'man' => SERVICE_NAMESPACE }).first
    return result ? node_to_hash(result) : false
  end

  def process_payment_with_cvn(managed_customer_id, amount, cvn = nil, invoice_ref = nil, invoice_desc = nil)
    log_operation(:process_payment_with_cvn, managed_customer_id, amount, cvn, invoice_ref, invoice_desc)
    envelope = wrap_in_envelope do |xml|
      xml['man'].ProcessPaymentWithCVN {
        xml['man'].managedCustomerID managed_customer_id
        xml['man'].amount amount
        xml['man'].invoiceReference invoice_ref if invoice_ref
        xml['man'].invoiceDescription invoice_desc if invoice_desc
        xml['man'].cvn cvn if cvn
      }
    end
    response = post(envelope, 'ProcessPaymentWithCVN')
    result = response.xpath('//man:ProcessPaymentWithCVNResponse/man:ewayResponse', { 'man' => SERVICE_NAMESPACE }).first
    return result ? node_to_hash(result) : false
  end

  def query_customer(managed_customer_id)
    log_operation(:query_customer, managed_customer_id)
    envelope = wrap_in_envelope do |xml|
      xml['man'].QueryCustomer {
        xml['man'].managedCustomerID managed_customer_id
      }
    end
    response = post(envelope, 'QueryCustomer')
    result = response.xpath('//man:QueryCustomerResult', { 'man' => SERVICE_NAMESPACE }).first
    return result ? node_to_hash(result) : false
  end

  def query_customer_by_reference(customer_ref)
    log_operation(:query_customer_by_reference, customer_ref)
    envelope = wrap_in_envelope do |xml|
      xml['man'].QueryCustomerByReference {
        xml['man'].CustomerReference customer_ref
      }
    end
    response = post(envelope, 'QueryCustomerByReference')
    result = response.xpath('//man:QueryCustomerByReferenceResult', { 'man' => SERVICE_NAMESPACE }).first
    return result ? node_to_hash(result) : false
  end

  def query_payment(managed_customer_id)
    log_operation(:query_payment, managed_customer_id)
    envelope = wrap_in_envelope do |xml|
      xml['man'].QueryPayment {
        xml['man'].managedCustomerID managed_customer_id
      }
    end
    response = post(envelope, 'QueryPayment')
    result = response.xpath('//man:QueryPaymentResult', { 'man' => SERVICE_NAMESPACE }).first
    return result ? node_collection_to_array(result) : false
  end

  def update_customer(managed_customer_id, customer_fields = {})
    log_operation(:update_customer, managed_customer_id, customer_fields)
    envelope = wrap_in_envelope do |xml|
      xml['man'].UpdateCustomer {
        xml['man'].managedCustomerID managed_customer_id
        CUSTOMER_REQUEST_FIELDS.each do |field|
          xml['man'].send(field, customer_fields[field]) if customer_fields[field]
        end
      }
    end
    response = post(envelope, 'UpdateCustomer')
    result = response.xpath('//man:UpdateCustomerResult', { 'man' => SERVICE_NAMESPACE }).first
    return result ? result.text == 'true' : false
  end
end
