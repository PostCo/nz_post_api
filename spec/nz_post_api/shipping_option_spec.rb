# frozen_string_literal: true

RSpec.describe NzPostApi::Resources::ShippingOption do
  let(:client_id) { "client_id" }
  let(:access_token) { "access_token" }
  let(:client) { NzPostApi::Client.new(client_id: client_id, access_token: access_token) }
  let(:shipping_option) { described_class.new(client) }

  describe "#list" do
    let(:params) do
      {
        weight: 10,
        length: 10,
        width: 10,
        height: 10,
        pickup_address_id: 990003,
        delivery_dpid: 2727895
      }
    end
    let(:url) { "https://api.uat.nzpost.co.nz/shippingoptions/2.0/domestic" }
    let(:response_body) do
      {
        "success" => true,
        "services" => [
          {
            "carrier" => "CourierPost",
            "description" => "Courier Economy Parcel",
            "service_code" => "CPOLE",
            "price_excluding_gst" => 5,
            "addons" => [
              {
                "description" => "Courier Signature Required add-on",
                "addon_code" => "CPSR"
              }
            ]
          }
        ],
        "message_id" => "f072bbc0-000a-11f1-8459-02c60b84e957"
      }.to_json
    end

    before do
      stub_request(:get, url)
        .with(
          query: params,
          headers: {
            "client_id" => client_id,
            "Authorization" => "Bearer #{access_token}"
          }
        )
        .to_return(status: 200, body: response_body, headers: { "Content-Type" => "application/json" })
    end

    it "lists shipping options" do
      result = shipping_option.list(params)
      expect(result).to be_a(NzPostApi::Objects::ShippingOption)
      expect(result.success).to be(true)
      expect(result.services.first.service_code).to eq("CPOLE")
      expect(result.services.first.addons.first.addon_code).to eq("CPSR")
    end
  end
end
