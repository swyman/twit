require 'spec_helper'

describe "Twits" do

  describe "Home page" do

    it "has Welcome to Twit content" do
      visit '/twits/home'
      expect(page).to have_content('Welcome to Twit')
    end

  end
end
