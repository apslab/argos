require 'spec_helper'

describe Argos::Oauth::Applications do

  let(:common_properties) do
    {
        'inventario' => { 
            'url' => 'http://inventario.test:3000',
            'identifier' => '761e2621',
            'secret' => '8740dbce820d968fe4c98a15cf1dd309'
        },
        'deposito' => {
          'url' => 'https://deposito.test:3002',
          'identifier' => 'i39x9mq1',
          'secret' => '1340dbce820ds68fe4c9xa15cf1dd3wp'
        }
    }    
  end

  let(:properties) do
    { 'test' => common_properties, 'development' => common_properties }
  end

  before { YAML.stub!(:load_file) { properties } }
  subject { Argos::Oauth::Applications }
  it { should respond_to :by_name }
  it { should respond_to :random_identifier }

  describe '.random_identifier' do
    subject { Argos::Oauth::Applications.random_identifier }
    it { should be_an_instance_of String }
    its(:length) { should == 8 }
    it 'should be different in any call' do
      Argos::Oauth::Applications.random_identifier.should_not == Argos::Oauth::Applications.random_identifier
    end
  end

  describe '.random_secure' do
    subject { Argos::Oauth::Applications.random_secure }
    it { should be_an_instance_of String }
    its(:length) { should == 32 }
    it 'should be different in any call' do
      Argos::Oauth::Applications.random_secure.should_not == Argos::Oauth::Applications.random_secure
    end
  end

  context 'when I invoke .reload' do
    it 'should re-read the config file' do
      #YAML.should_receive(:load_file)
      Argos::Oauth::Applications.should_receive(:load_properties).with(false).and_return(true)
      Argos::Oauth::Applications.reload
    end
  end
   
  context "when I have config/services.yml with 
    inventario:
      url: http://inventario.test:3000
      identifier: 761e2621 
      secret: 8740dbce820d968fe4c98a15cf1dd309" do     

    context "when I invoke by_name('inventario')" do
      subject { Argos::Oauth::Applications.by_name('inventario') }
      it { should_not be_nil }
      it { should be_an_instance_of Argos::Oauth::Applications::Credential }
      its(:url) { should == 'http://inventario.test:3000' }
      its(:app_name) { should == 'inventario' }
      its(:identifier) { should == '761e2621' }
      its(:secret) { should == '8740dbce820d968fe4c98a15cf1dd309' }
    end

    context "when I invoke by_name('test')" do
      subject { Argos::Oauth::Applications.by_name('test') } 
      it { should be_nil }
    end

    context "when I invoke by_identifier('761e2621')" do
      subject { Argos::Oauth::Applications.by_identifier('761e2621') }
      it { should_not be_nil }
      its(:app_name) { should == 'inventario' }
      its(:url) { should == 'http://inventario.test:3000' }
      its(:identifier) { should == '761e2621' }
    end
  end
end
