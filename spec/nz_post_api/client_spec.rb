# frozen_string_literal: true

RSpec.describe NzPostApi::Client do
  let(:client_id) { "client_id" }
  let(:access_token) { "access_token" }

  describe "#initialize" do
    it "accepts client_id and access_token" do
      client = described_class.new(client_id, access_token)
      expect(client.connection.headers["client_id"]).to eq(client_id)
      expect(client.connection.headers["Authorization"]).to eq("Bearer #{access_token}")
    end

    it "defaults to UAT base_url when prod is false" do
      client = described_class.new(client_id, access_token, prod: false)
      expect(client.base_url).to eq("https://api.uat.nzpost.co.nz")
    end

    it "uses production base_url when prod is true" do
      client = described_class.new(client_id, access_token, prod: true)
      expect(client.base_url).to eq("https://api.nzpost.co.nz")
    end
  end

  describe "#connection" do
    let(:client) { described_class.new(client_id, access_token) }

    it "returns a Faraday connection" do
      expect(client.connection).to be_a(Faraday::Connection)
    end

    it "sets the correct headers" do
      connection = client.connection
      expect(connection.headers["client_id"]).to eq(client_id)
      expect(connection.headers["Authorization"]).to eq("Bearer #{access_token}")
      expect(connection.headers["Content-Type"]).to eq("application/json")
    end
  end

  describe "#parcel_address" do
    let(:client) { described_class.new(client_id, access_token) }

    it "returns a ParcelAddress instance" do
      expect(client.parcel_address).to be_a(NzPostApi::Resources::ParcelAddress)
    end
  end

  describe "#parcel_label" do
    let(:client) { described_class.new(client_id, access_token) }

    it "returns a ParcelLabel instance" do
      expect(client.parcel_label).to be_a(NzPostApi::Resources::ParcelLabel)
    end
  end

  describe "#shipping_options" do
    let(:client) { described_class.new(client_id, access_token) }

    it "returns a ShippingOption instance" do
      expect(client.shipping_options).to be_a(NzPostApi::Resources::ShippingOption)
    end
  end

  describe "#parcel_track" do
    let(:client) { described_class.new(client_id, access_token) }

    it "returns a ParcelTrack instance" do
      expect(client.parcel_track).to be_a(NzPostApi::Resources::ParcelTrack)
    end
  end
end
