require 'spec_helper'

class Product < ActiveResource::Base
  extend Argos::OauthSupport

  self.site = 'http://192.168.1.1:3001'
  self.oauth_identifier = '761e2621'
  self.oauth_secret = '8740dbce820d968fe4c98a15cf1dd309'  
end

def expected_error_message_for_field(field)
  "You need to specify the parameters: #{field} in the Product class"
end

describe Argos::OauthSupport do

  let(:json_product) do
    {"amount"=>2, "created_at"=>"2012-03-07T16:11:56Z", "id"=>1, "name"=>"Product 1", "updated_at"=>"2012-03-07T16:11:56Z"}.to_json
  end

  let(:user) do
    user = double('user')
    user.stub!(:uid) { "1" }
  end

  describe "Alert for required parameters not defined" do
    
    before do 
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get "/product/1.json", {}, json_product
      end
      Product.requesting_user = user
      Product.oauth_identifier = '761e2621'
      Product.oauth_secret = '8740dbce820d968fe4c98a15cf1dd309'  
    end

    
    context "when the requesting_user is not set" do
      before { Product.requesting_user = nil }
      it "should raise the error '#{expected_error_message_for_field('requesting_user')}'"  do
        expect { Product.find(1) }.to raise_error(expected_error_message_for_field('requesting_user') )
      end
    end

    context "when the oauth_identifier is not set" do
      before { Product.oauth_identifier = nil }
      
      it "should raise the error '#{expected_error_message_for_field('oauth_identifier')}'" do
        expect { Product.find(1) }.to raise_error(expected_error_message_for_field('oauth_identifier'))
      end
    end

    context 'when the oauth_secret is not set' do 
      before { Product.oauth_secret = nil }
      it "should raise the error '#{expected_error_message_for_field('oauth_secret')}'" do
        expect { Product.find(1) }.to raise_error(expected_error_message_for_field('oauth_secret'))
      end
    end

  end

end


