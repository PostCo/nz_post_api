# frozen_string_literal: true

RSpec.describe NzPostApi::Resources::ParcelAddress do
  let(:client_id) { "client_id" }
  let(:access_token) { "access_token" }
  let(:client) { NzPostApi::Client.new(client_id, access_token) }

  let(:parcel_address) { described_class.new(client) }

  describe "#search" do
    let(:query) { "Damson" }
    let(:count) { 10 }
    let(:url) { "https://api.uat.nzpost.co.nz/parceladdress/2.0/domestic/addresses" }
    let(:response_body) do
      {
        "success" => true,
        "addresses" => [
          {
            "full_address" => "1 Damson Place, Bucklands Beach, Auckland 2012",
            "address_id" => "71841",
            "dpid" => "281685"
          }
        ],
        "message_id" => "b5015012-3a45-4a51-bed8-9edd2aecfb7e"
      }.to_json
    end

    before do
      stub_request(:get, url)
        .with(
          query: {
            q: query,
            count: count
          },
          headers: {
            "client_id" => client_id,
            "Authorization" => "Bearer #{access_token}"
          }
        )
        .to_return(status: 200, body: response_body, headers: { "Content-Type" => "application/json" })
    end

    it "searches for addresses" do
      result = parcel_address.search(q: query, count: count)
      expect(result.first).to be_a(NzPostApi::Objects::Address)
      expect(result.first.full_address).to eq("1 Damson Place, Bucklands Beach, Auckland 2012")
    end

    context "when API call fails" do
      before do
        stub_request(:get, url)
          .with(query: { q: query, count: count })
          .to_return(status: 500, body: "Internal Server Error")
      end

      it "raises an error" do
        expect {
          parcel_address.search(q: query, count: count)
        }.to raise_error(NzPostApi::Error) { |error|
          expect(error.message).to match(/500/)
          expect(error.response_http_code).to eq(500)
          expect(error.response_body).to eq("Internal Server Error")
        }
      end
    end
  end
end
