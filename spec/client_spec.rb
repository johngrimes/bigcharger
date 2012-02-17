require File.dirname(__FILE__) + '/spec_helper'
require File.dirname(__FILE__) + '/../lib/eway'

require 'logger'

describe Eway::TokenPayments::Client do
  include ClientSpecHelpers

  before(:all) do
    @customer_id = '87654321'
    @username = 'test@eway.com.au'
    @password = 'test123'
    @test_customer_id = '9876543211000'
    @test_customer_ref = 'Test 123'
    @client = Eway::TokenPayments::Client.new(@customer_id, @username, @password)
    @endpoint = Eway.config['client']['endpoint']
    @namespace = Eway.config['client']['service_namespace']
    
    # DEBUG
    # @client.logger = Logger.new(STDOUT)
  end

  describe '#create_customer' do
    before(:all) do
      @customer = {
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
      }
    end

    describe 'success scenario' do
      after(:all) { WebMock.reset! }

      it 'should make a request to the eWAY endpoint' do
        stub_request(:post, @endpoint)
            .to_return(
              :status => 200,
              :body => message(:create_customer_response)
            )
        @client.create_customer(@customer)
      end

      it 'should use the correct headers' do
        stub_request(:post, @endpoint)
            .with(:headers => { 
              'SOAPAction' => "#{@namespace}/CreateCustomer",
              'Content-Type' => 'text/xml'
            })
        @client.create_customer(@customer)
      end

      it 'should pass the correct content within the request' do
        stub_request(:post, @endpoint)
            .with(:body => message(:create_customer_request))
        @client.create_customer(@customer)
      end

      it 'should return the correct ID' do
        stub_request(:post, @endpoint)
            .to_return(
              :status => 200,
              :body => message(:create_customer_response)
            )
        response = @client.create_customer(@customer)
        response.should == @test_customer_id
      end
    end

    describe 'failure scenarios' do
      it 'should raise an error when a fault is returned' do
        stub_request(:post, @endpoint)
            .to_return(
              :status => [500, 'Internal Server Error'],
              :body => message(:fault_response)
            )
        expect {
          @client.create_customer(@customer)
        }.to raise_error(Eway::TokenPayments::Error, 'eWAY server responded with "Login failed." (soap:Client)')
      end

      it 'should raise an error when the server returns a failure response code' do
        stub_request(:post, @endpoint)
            .to_return(
              :status => [400, 'Bad Request']
            )
        expect {
          @client.create_customer(@customer)
        }.to raise_error(Eway::TokenPayments::Error, 'eWAY server responded with "Bad Request" (400)')
      end
    end
  end

  describe '#process_payment' do
    before(:all) do
      @amount = 1000
      @invoice_ref = 'INV-80123'
      @invoice_desc = 'Payment for services rendered'
    end

    describe 'success scenario' do
      after(:all) { WebMock.reset! }

      it 'should make a request to the eWAY endpoint' do
        stub_request(:post, @endpoint)
            .to_return(
              :status => 200,
              :body => message(:process_payment_response)
            )
        @client.process_payment(@test_customer_id, @amount, @invoice_ref, @invoice_desc)
      end

      it 'should use the correct headers' do
        stub_request(:post, @endpoint)
            .with(:headers => { 
              'SOAPAction' => "#{@namespace}/ProcessPayment",
              'Content-Type' => 'text/xml'
            })
        @client.process_payment(@test_customer_id, @amount, @invoice_ref, @invoice_desc)
      end

      it 'should pass the correct content within the request' do
        stub_request(:post, @endpoint)
            .with(:body => message(:process_payment_request))
        @client.process_payment(@test_customer_id, @amount, @invoice_ref, @invoice_desc)
      end

      it 'should return the correct response' do
        stub_request(:post, @endpoint)
            .to_return(
              :status => 200,
              :body => message(:process_payment_response)
            )
        response = @client.process_payment(@test_customer_id, @amount, @invoice_ref, @invoice_desc)

        response['ewayTrxnError'].should == '00,Transaction Approved(Test Gateway)'
        response['ewayTrxnStatus'].should == 'True'
        response['ewayTrxnNumber'].should == '1011634'
        response['ewayReturnAmount'].should == '1000'
        response['ewayAuthCode'].should == '123456'
      end
    end

    describe 'failure scenarios' do
      it 'should raise an error when a fault is returned' do
        stub_request(:post, @endpoint)
            .to_return(
              :status => [500, 'Internal Server Error'],
              :body => message(:fault_response)
            )
        expect {
          @client.process_payment(@test_customer_id, @amount, @invoice_ref, @invoice_desc)
        }.to raise_error(Eway::TokenPayments::Error, 'eWAY server responded with "Login failed." (soap:Client)')
      end

      it 'should raise an error when the server returns a failure response code' do
        stub_request(:post, @endpoint)
            .to_return(
              :status => [400, 'Bad Request']
            )
        expect {
          @client.process_payment(@test_customer_id, @amount, @invoice_ref, @invoice_desc)
        }.to raise_error(Eway::TokenPayments::Error, 'eWAY server responded with "Bad Request" (400)')
      end
    end
  end

  describe '#process_payment_with_cvn' do
    before(:all) do
      @amount = 1000
      @cvn = '123'
      @invoice_ref = 'INV-80123'
      @invoice_desc = 'Payment for services rendered'
    end

    describe 'success scenario' do
      after(:all) { WebMock.reset! }

      it 'should make a request to the eWAY endpoint' do
        stub_request(:post, @endpoint)
            .to_return(
              :status => 200,
              :body => message(:process_payment_with_cvn_response)
            )
        @client.process_payment_with_cvn(@test_customer_id, @amount, @cvn, @invoice_ref, @invoice_desc)
      end

      it 'should use the correct headers' do
        stub_request(:post, @endpoint)
            .with(:headers => { 
              'SOAPAction' => "#{@namespace}/ProcessPaymentWithCVN",
              'Content-Type' => 'text/xml'
            })
        @client.process_payment_with_cvn(@test_customer_id, @amount, @cvn, @invoice_ref, @invoice_desc)
      end

      it 'should pass the correct content within the request' do
        stub_request(:post, @endpoint)
            .with(:body => message(:process_payment_with_cvn_request))
        @client.process_payment_with_cvn(@test_customer_id, @amount, @cvn, @invoice_ref, @invoice_desc)
      end

      it 'should return the correct response' do
        stub_request(:post, @endpoint)
            .to_return(
              :status => 200,
              :body => message(:process_payment_with_cvn_response)
            )
        response = @client.process_payment_with_cvn(@test_customer_id, @amount, @cvn, @invoice_ref, @invoice_desc)

        response['ewayTrxnError'].should == '00,Transaction Approved(Test CVN Gateway)'
        response['ewayTrxnStatus'].should == 'True'
        response['ewayTrxnNumber'].should == '21803'
        response['ewayReturnAmount'].should == '1000'
        response['ewayAuthCode'].should == '123456'
      end
    end

    describe 'failure scenarios' do
      it 'should raise an error when a fault is returned' do
        stub_request(:post, @endpoint)
            .to_return(
              :status => [500, 'Internal Server Error'],
              :body => message(:fault_response)
            )
        expect {
          @client.process_payment_with_cvn(@test_customer_id, @amount, @cvn, @invoice_ref, @invoice_desc)
        }.to raise_error(Eway::TokenPayments::Error, 'eWAY server responded with "Login failed." (soap:Client)')
      end

      it 'should raise an error when the server returns a failure response code' do
        stub_request(:post, @endpoint)
            .to_return(
              :status => [400, 'Bad Request']
            )
        expect {
          @client.process_payment_with_cvn(@test_customer_id, @amount, @cvn, @invoice_ref, @invoice_desc)
        }.to raise_error(Eway::TokenPayments::Error, 'eWAY server responded with "Bad Request" (400)')
      end
    end
  end

  describe '#query_customer' do
    describe 'success scenarios' do
      after(:all) { WebMock.reset! }

      it 'should make a request to the eWAY endpoint' do
        stub_request(:post, @endpoint)
            .to_return(
              :status => 200,
              :body => message(:query_customer_response)
            )
        @client.query_customer(@test_customer_id)
      end

      it 'should use the correct headers' do
        stub_request(:post, @endpoint)
            .with(:headers => { 
              'SOAPAction' => "#{@namespace}/QueryCustomer",
              'Content-Type' => 'text/xml'
            })
        @client.query_customer(@test_customer_id)
      end

      it 'should pass the correct content within the request' do
        stub_request(:post, @endpoint)
            .with(:body => message(:query_customer_request))
        @client.query_customer(@test_customer_id)
      end

      it 'should return the correct response' do
        stub_request(:post, @endpoint)
            .to_return(
              :status => 200,
              :body => message(:query_customer_response)
            )
        response = @client.query_customer(@test_customer_id)

        response['ManagedCustomerID'].should == '9876543211000'
        response['CustomerRef'].should == 'Test 123'
        response['CustomerTitle'].should == 'Mr.'
        response['CustomerFirstName'].should == 'Jo'
        response['CustomerLastName'].should == 'Smith'
        response['CustomerCompany'].should == 'company'
        response['CustomerJobDesc'].should be_nil
        response['CustomerEmail'].should == 'test@eway.com.au'
        response['CustomerAddress'].should == '15 Dundas Court'
        response['CustomerSuburb'].should == 'phillip'
        response['CustomerState'].should == 'act'
        response['CustomerPostCode'].should == '2606'
        response['CustomerCountry'].should == 'au'
        response['CustomerPhone1'].should == '02111111111'
        response['CustomerPhone2'].should == '04111111111'
        response['CustomerFax'].should == '111122222'
        response['CustomerURL'].should == 'http://eway.com.au'
        response['CustomerComments'].should == 'Comments'
        response['CCName'].should == 'Jo Smith'
        response['CCNumber'].should == '444433XXXXXX1111'
        response['CCExpiryMonth'].should == '08'
        response['CCExpiryYear'].should == '15'
      end
    end

    describe 'failure scenarios' do
      it 'should raise an error when a fault is returned' do
        stub_request(:post, @endpoint)
            .to_return(
              :status => [500, 'Internal Server Error'],
              :body => message(:fault_response)
            )
        expect {
          @client.query_customer(@test_customer_id)
        }.to raise_error(Eway::TokenPayments::Error, 'eWAY server responded with "Login failed." (soap:Client)')
      end

      it 'should raise an error when the server returns a failure response code' do
        stub_request(:post, @endpoint)
            .to_return(
              :status => [400, 'Bad Request']
            )
        expect {
          @client.query_customer(@test_customer_id)
        }.to raise_error(Eway::TokenPayments::Error, 'eWAY server responded with "Bad Request" (400)')
      end
    end
  end

  describe '#query_customer_by_reference' do
    describe 'success scenarios' do
      after(:all) { WebMock.reset! }

      it 'should make a request to the eWAY endpoint' do
        stub_request(:post, @endpoint)
            .to_return(
              :status => 200,
              :body => message(:query_customer_by_reference_response)
            )
        @client.query_customer_by_reference(@test_customer_ref)
      end

      it 'should use the correct headers' do
        stub_request(:post, @endpoint)
            .with(:headers => { 
              'SOAPAction' => "#{@namespace}/QueryCustomerByReference",
              'Content-Type' => 'text/xml'
            })
        @client.query_customer_by_reference(@test_customer_ref)
      end

      it 'should pass the correct content within the request' do
        stub_request(:post, @endpoint)
            .with(:body => message(:query_customer_by_reference_request))
        @client.query_customer_by_reference(@test_customer_ref)
      end

      it 'should return the correct response' do
        stub_request(:post, @endpoint)
            .to_return(
              :status => 200,
              :body => message(:query_customer_by_reference_response)
            )
        response = @client.query_customer_by_reference(@test_customer_ref)

        response['ManagedCustomerID'].should == '9876543211000'
        response['CustomerRef'].should == 'TEST 123'
        response['CustomerTitle'].should == 'Mr.'
        response['CustomerFirstName'].should == 'Jo'
        response['CustomerLastName'].should == 'Smith'
        response['CustomerCompany'].should == 'company'
        response['CustomerJobDesc'].should be_nil
        response['CustomerEmail'].should == 'test@eway.com.au'
        response['CustomerAddress'].should == '15 Dundas Court'
        response['CustomerSuburb'].should == 'phillip'
        response['CustomerState'].should == 'act'
        response['CustomerPostCode'].should == '2606'
        response['CustomerCountry'].should == 'au'
        response['CustomerPhone1'].should == '02111111111'
        response['CustomerPhone2'].should == '04111111111'
        response['CustomerFax'].should == '111122222'
        response['CustomerURL'].should == 'http://eway.com.au'
        response['CustomerComments'].should == 'Comments'
        response['CCName'].should == 'Jo Smith'
        response['CCNumber'].should == '444433XXXXXX1111'
        response['CCExpiryMonth'].should == '08'
        response['CCExpiryYear'].should == '15'
      end
    end

    describe 'failure scenarios' do
      it 'should raise an error when a fault is returned' do
        stub_request(:post, @endpoint)
            .to_return(
              :status => [500, 'Internal Server Error'],
              :body => message(:fault_response)
            )
        expect {
          @client.query_customer_by_reference(@test_customer_ref)
        }.to raise_error(Eway::TokenPayments::Error, 'eWAY server responded with "Login failed." (soap:Client)')
      end

      it 'should raise an error when the server returns a failure response code' do
        stub_request(:post, @endpoint)
            .to_return(
              :status => [400, 'Bad Request']
            )
        expect {
          @client.query_customer_by_reference(@test_customer_ref)
        }.to raise_error(Eway::TokenPayments::Error, 'eWAY server responded with "Bad Request" (400)')
      end
    end
  end

  describe '#query_payment' do
    describe 'success scenarios' do
      after(:all) { WebMock.reset! }

      it 'should make a request to the eWAY endpoint' do
        stub_request(:post, @endpoint)
            .to_return(
              :status => 200,
              :body => message(:query_payment_response)
            )
        @client.query_payment(@test_customer_id)
      end

      it 'should use the correct headers' do
        stub_request(:post, @endpoint)
            .with(:headers => { 
              'SOAPAction' => "#{@namespace}/QueryPayment",
              'Content-Type' => 'text/xml'
            })
        @client.query_payment(@test_customer_id)
      end

      it 'should pass the correct content within the request' do
        stub_request(:post, @endpoint)
            .with(:body => message(:query_payment_request))
        @client.query_payment(@test_customer_id)
      end

      it 'should return the correct response' do
        stub_request(:post, @endpoint)
            .to_return(
              :status => 200,
              :body => message(:query_payment_response)
            )
        response = @client.query_payment(@test_customer_id)

        response.size.should == 2
        response[0]['TotalAmount'].should == '1000'
        response[0]['Result'].should == '1'
        response[0]['ResponseText'].should == 'Approved'
        response[0]['TransactionDate'].should == '2012-02-16T00:00:00+11:00'
        response[0]['ewayTrxnNumber'].should == '1'
        response[1]['TotalAmount'].should == '1008'
        response[1]['Result'].should == '1'
        response[1]['ResponseText'].should == 'Approved'
        response[1]['TransactionDate'].should == '2012-02-16T00:00:00+11:00'
        response[1]['ewayTrxnNumber'].should == '2'
      end
    end

    describe 'failure scenarios' do
      it 'should raise an error when a fault is returned' do
        stub_request(:post, @endpoint)
            .to_return(
              :status => [500, 'Internal Server Error'],
              :body => message(:fault_response)
            )
        expect {
          @client.query_payment(@test_customer_id)
        }.to raise_error(Eway::TokenPayments::Error, 'eWAY server responded with "Login failed." (soap:Client)')
      end

      it 'should raise an error when the server returns a failure response code' do
        stub_request(:post, @endpoint)
            .to_return(
              :status => [400, 'Bad Request']
            )
        expect {
          @client.query_payment(@test_customer_id)
        }.to raise_error(Eway::TokenPayments::Error, 'eWAY server responded with "Bad Request" (400)')
      end
    end
  end

  describe '#update_customer' do
    before(:all) do
      @customer = {
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
      }
    end

    describe 'success scenario' do
      after(:all) { WebMock.reset! }

      it 'should make a request to the eWAY endpoint' do
        stub_request(:post, @endpoint)
            .to_return(
              :status => 200,
              :body => message(:update_customer_response)
            )
        @client.update_customer(@test_customer_id, @customer)
      end

      it 'should use the correct headers' do
        stub_request(:post, @endpoint)
            .with(:headers => { 
              'SOAPAction' => "#{@namespace}/UpdateCustomer",
              'Content-Type' => 'text/xml'
            })
        @client.update_customer(@test_customer_id, @customer)
      end

      it 'should pass the correct content within the request' do
        stub_request(:post, @endpoint)
            .with(:body => message(:update_customer_request))
        @client.update_customer(@test_customer_id, @customer)
      end

      it 'should return the correct response' do
        stub_request(:post, @endpoint)
            .to_return(
              :status => 200,
              :body => message(:update_customer_response)
            )
        response = @client.update_customer(@test_customer_id, @customer)
        response.should be_true
      end
    end

    describe 'failure scenarios' do
      it 'should raise an error when a fault is returned' do
        stub_request(:post, @endpoint)
            .to_return(
              :status => [500, 'Internal Server Error'],
              :body => message(:fault_response)
            )
        expect {
          @client.update_customer(@test_customer_id, @customer)
        }.to raise_error(Eway::TokenPayments::Error, 'eWAY server responded with "Login failed." (soap:Client)')
      end

      it 'should raise an error when the server returns a failure response code' do
        stub_request(:post, @endpoint)
            .to_return(
              :status => [400, 'Bad Request']
            )
        expect {
          @client.update_customer(@test_customer_id, @customer)
        }.to raise_error(Eway::TokenPayments::Error, 'eWAY server responded with "Bad Request" (400)')
      end
    end
  end
end
