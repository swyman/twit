require 'spec_helper'

describe User do

  it "is invalid without a twitter" do
    Person.create({})
  end
end
