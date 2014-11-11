require 'spec_helper'

describe "Attachments" do
  before :each do
    @channel = FactoryGirl.create(:channel)
    #@attachment = FactoryGirl.create(:attachment)
  end

  describe "GET /attachments" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      #get channel_attachment_path(1,1)
      #get channel_attachments_path(1,1)?
      get channel_attachments_path(@channel)
      response.status.should be(200)
    end
  end
end
