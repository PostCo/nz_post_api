# frozen_string_literal: true

RSpec.describe NzPostApi::Configuration do
  describe "#base_url" do
    it "defaults to UAT URL" do
      config = described_class.new
      expect(config.base_url).to eq("https://api.uat.nzpost.co.nz")
    end

    it "returns production URL when prod is true" do
      config = described_class.new
      config.prod = true
      expect(config.base_url).to eq("https://api.nzpost.co.nz")
    end
  end
end

RSpec.describe NzPostApi do
  describe ".configure" do
    it "allows setting configuration" do
      NzPostApi.configure do |config|
        config.prod = true
      end

      expect(NzPostApi.configuration.prod).to be true
      expect(NzPostApi.configuration.base_url).to eq("https://api.nzpost.co.nz")
    end

    after do
      # Reset configuration after test
      NzPostApi.configure do |config|
        config.prod = false
      end
    end
  end
end

RSpec.describe "Resources integration with configuration" do
  let(:client) { instance_double(NzPostApi::Client) }

  before do
    NzPostApi.configure do |config|
      config.prod = true
    end
  end

  after do
    NzPostApi.configure do |config|
      config.prod = false
    end
  end

  it "uses production URL for ParcelLabel" do
    resource = NzPostApi::Resources::ParcelLabel.new(client)
    expect(resource.base_url).to include("https://api.nzpost.co.nz")
  end

  it "uses production URL for ParcelTrack" do
    resource = NzPostApi::Resources::ParcelTrack.new(client)
    expect(resource.base_url).to include("https://api.nzpost.co.nz")
  end
end
