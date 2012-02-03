require 'spec_helper'
require 'rest_resource'
#require File.expand_path("#{Rails.root}/lib/oauth_sign_parser")
#
class RestProduct < RestResource
  provider 'inventario'

  attr_accessor :id, :name, :amount
end

class RestProductBad < RestResource
  attr_accessor :id, :name, :amount
end

class RestOffer < RestResource
end

describe RestResource do

  let(:response_all_products) do 
    response = mock
    response.stub(:body) do
      5.times.map do |n|
        { 'id' => n, 'name' => "Product #{n}", 'amount' => 10 + n, 'department_id' => 2 + n }
      end.to_json
    end
    response
  end

  let(:response_product) do
    response = mock
    response.stub(:body).and_return( { 'id' => 1, 'name' => 'Product 1', 'amount' => 12, 'department_id' => 2 }.to_json )
    response
  end

  before(:each) do 
    credential = Oauth::Applications::Credential.new('inventario', 'xxxxxxxx', '12345678901234567890123456789012', 'http://inventario.com')
    Oauth::Applications.stub!(:by_name).with('inventario').and_return(credential)
  end

  describe "#provider" do
    context "when create a class without set provider" do
      it 'should raise an exception' do
        expect { RestProductBad.find(1) }.should raise_error("You must specify the provider in the class #{RestProductBad.name}")
      end
    end
    context "when create a class with provider 'inventario' and config/service.yml have this provider" do
      subject { RestProduct.provider }
      its(:url) { should == 'http://inventario.com' }
      its(:identifier) { should == 'xxxxxxxx' }
      its(:secret) { should == '12345678901234567890123456789012' }
    end
  end

  describe "#resource_url" do

    let(:url) { 'http://192.169.1.1:4000/sales' }

    before(:each) do
      RestProduct.resource_url(url)
    end
    context "when set resource_url with 'http://192.168.1.1:4000/sales'" do 
      context "and then invoke resource_url without parameters" do
        subject { RestProduct }
        its(:resource_url) { should == url }
      end
            
      context "and set provider url with #{RestProduct.provider.url}, the invoked url" do
        before(:each) { RestClient.stub(:send).and_return(response_all_products) }
        it "should be 'http://192.168.1.1:4000/sales'" do
          RestClient.should_receive(:send).with(:get, url, :accept => :json) 
          RestProduct.all
        end
      end
    end

  end

  describe "#resource_name" do

    context "when you have the class RestProduct when and set resource_name with a singular name like product" do
      before { RestProduct.resource_name('product') }
      subject { RestProduct }
      its(:resource_name) { should == 'products' }
    end

    context "when you have the class RestOffer and not set resource_name" do
      subject { RestOffer }
      its(:resource_name) { should == 'rest_offers' }
    end

  end

  describe "#find" do
    before(:each) { RestClient.stub(:get).and_return(response_product) }

    context "when use RestProduct.find(1)" do
      subject { RestProduct.find(1) } 
      its(:id) { should == 1 }
      its(:name) { should == 'Product 1' }
      its(:amount) { should == 12 }
      it { should_not respond_to :department_id }
    end
  end

  describe "#all" do
    before(:each) { RestClient.stub(:get).and_return(response_all_products) }
    context 'when use RestProduct.all' do
      subject { RestProduct.all }
      it { should be_an_instance_of Array }
      it { should have(5).things }
    end
  end
end
