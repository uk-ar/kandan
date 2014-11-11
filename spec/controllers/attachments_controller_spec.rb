require 'spec_helper'

describe AttachmentsController do
  include Devise::TestHelpers

  before(:all) do
    @channel = FactoryGirl.create(:channel, :id => 2)
    #@admin = FactoryGirl.create(:admin)
    @user = FactoryGirl.create(:user)
  end

  context 'a user' do
    before(:each) do
      sign_in @user
    end

    describe "GET index" do
      before do
        get :index, {:channel_id => @channel.id}
      end

      it "should return list of channels in JSON" do
        expect(response.status).to eq(401)
        expect(response.body).to eq(nil)
      end
    end
  end
end
