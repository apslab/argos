require 'spec_helper'

describe ApplicationController do
  context 'when include Argos::Security' do
    it { ApplicationController.should be_include Argos::Security }
    it { should respond_to :login_required }
    it { should respond_to :current_user }
  end
end
