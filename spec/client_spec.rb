require 'rubygems'
require './spec/client_spec_helpers.rb'
require './lib/client.rb'
require 'bundler'
Bundler.setup(:default, :test)

require 'fakeweb'
require 'equivalent-xml'
require 'ruby-debug'
require 'pry'
require 'ruby-debug/pry'

describe Eway::TokenPayments::Client do
  include ClientSpecHelpers

  before(:all) do
    FakeWeb.allow_net_connect = false
    @customer_id = '87654321'
    @username = 'test@eway.com.au'
    @password = 'test123'
    @test_customer_id = '9876543211000'
    @namespaces = { 'man' => Eway::TokenPayments::Client::NAMESPACE }
    @client = Eway::TokenPayments::Client.new(@customer_id, @username, @password)
  end

  describe '#create_customer' do
    describe 'success scenario' do
      before(:all) do
        register_valid_response(:create_customer)
        @response = @client.create_customer({
          'CustomerRef' => 'Test 123',
          'CustomerTitle' => 'Mr.',
          'CustomerFirstName' => 'Jo',
          'CustomerLastName' => 'Smith',
          'Company' => 'company',
          'CustomerJobDesc' => 'Analyst',
          'CustomerEmail' => 'test@eway.com.au',
          'CustomerAddress' => '15 Dundas Court',
          'CustomerSuburb' => 'phillip',
          'CustomerState' => 'act',
          'CustomerPostCode' => '2606',
          'CustomerCountry' => 'au',
          'CustomerPhone1' => '02111111111',
          'CustomerPhone2' => '04111111111',
          'CustomerFax' => '111122222',
          'CustomerURL' => 'http://eway.com.au',
          'CustomerComments' => 'Comments',
          'CCName' => 'Jo Smith',
          'CCNumber' => '444433XXXXXX1111',
          'CCExpiryMonth' => '08',
          'CCExpiryYear' => '15'
        })
        @request = FakeWeb.last_request
      end

      after(:all) { FakeWeb.clean_registry }

      it 'should make a request to the eWAY endpoint' do
        @request.should_not be_nil
      end

      it 'should pass the correct content within the request' do
        request_document.should be_equivalent_to(spec_document(:create_customer_request))
      end

      it 'should return the correct ID' do
        @response.should == @test_customer_id
      end
    end

    describe 'failure scenarios' do
      it 'should raise an error when a fault is returned' do
        register_fault_response
        expect {
          @response = @client.create_customer
        }.to raise_error(Eway::TokenPayments::Error, 'Login failed.')
      end

      it 'should raise an error when the server returns a failure response code' do
        register_blank_response(400, 'Bad Request')
        expect {
          @response = @client.create_customer
        }.to raise_error(Eway::TokenPayments::Error, 'eWAY server responded with "" (400)')
      end
    end
  end

  describe '#query_customer' do
    describe 'success scenarios' do
      before(:all) do
        register_valid_response(:query_customer)
        @response = @client.query_customer(@test_customer_id)
        @request = FakeWeb.last_request
      end

      after(:all) { FakeWeb.clean_registry }

      it 'should make a request to the eWAY endpoint' do
        @request.should_not be_nil
      end

      it 'should pass the correct content within the request' do
        request_document.should be_equivalent_to(spec_document(:query_customer_request))
      end

      it 'should return the correct response' do
        # Check that customer object contains the same information
        # as the fake response
        @response[:managed_customer_id].should == '9876543211000'
        @response[:customer_ref].should == 'Test 123'
        @response[:customer_title].should == 'Mr.'
        @response[:customer_first_name].should == 'Jo'
        @response[:customer_last_name].should == 'Smith'
        @response[:customer_company].should == 'company'
        @response[:customer_job_desc].should be_nil
        @response[:customer_email].should == 'test@eway.com.au'
        @response[:customer_address].should == '15 Dundas Court'
        @response[:customer_suburb].should == 'phillip'
        @response[:customer_state].should == 'act'
        @response[:customer_post_code].should == '2606'
        @response[:customer_country].should == 'au'
        @response[:customer_phone1].should == '02111111111'
        @response[:customer_phone2].should == '04111111111'
        @response[:customer_fax].should == '111122222'
        @response[:customer_url].should == 'http://eway.com.au'
        @response[:customer_comments].should == 'Comments'
        @response[:cc_name].should == 'Jo Smith'
        @response[:cc_number].should == '444433XXXXXX1111'
        @response[:cc_expiry_month].should == '08'
        @response[:cc_expiry_year].should == '15'
      end
    end

    describe 'failure scenarios' do
      it 'should raise an error when a fault is returned' do
        register_fault_response
        expect {
          @response = @client.query_customer(@test_customer_id)
        }.to raise_error(Eway::TokenPayments::Error, 'Login failed.')
      end

      it 'should raise an error when the server returns a failure response code' do
        register_blank_response(400, 'Bad Request')
        expect {
          @response = @client.query_customer(@test_customer_id)
        }.to raise_error(Eway::TokenPayments::Error, 'eWAY server responded with "" (400)')
      end
    end
  end
end
