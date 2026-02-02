# frozen_string_literal: true

RSpec.describe NzPostApi::Resources::ParcelLabel do
  let(:client_id) { "client_id" }
  let(:access_token) { "access_token" }
  let(:client) { NzPostApi::Client.new(client_id: client_id, access_token: access_token) }
  let(:parcel_label) { described_class.new(client) }
  let(:headers) do
    {
      "client_id" => client_id,
      "Authorization" => "Bearer #{access_token}",
      "Content-Type" => "application/json"
    }
  end

  describe "#create" do
    let(:payload) do
      {
        "carrier" => "COURIERPOST",
        "sender_details" => { "name" => "Joe Sender" }
      }
    end
    let(:url) { "https://api.uat.nzpost.co.nz/parcellabel/v3/labels" }
    let(:response_body) do
      {
        "consignment_id" => "JD8H7F",
        "message_id" => "ff60e850-000a-11f1-b4e0-0611928a334d",
        "success" => true
      }.to_json
    end

    before do
      stub_request(:post, url)
        .with(body: payload, headers: headers)
        .to_return(status: 200, body: response_body, headers: { "Content-Type" => "application/json" })
    end

    it "creates a label" do
      result = parcel_label.create(payload)
      expect(result).to be_a(NzPostApi::Objects::Label)
      expect(result.success).to be(true)
      expect(result.consignment_id).to eq("JD8H7F")
    end
  end

  describe "#status" do
    let(:consignment_id) { "JD8H7F" }
    let(:url) { "https://api.uat.nzpost.co.nz/parcellabel/v3/labels/#{consignment_id}/status" }

    context "when successful" do
      let(:response_body) do
        {
          "consignment_id" => "JKA6YW",
          "consignment_status" => "Complete",
          "success" => true
        }.to_json
      end

      before do
        stub_request(:get, url)
          .with(headers: headers.except("Content-Type"))
          .to_return(status: 200, body: response_body, headers: { "Content-Type" => "application/json" })
      end

      it "returns the status" do
        result = parcel_label.status(consignment_id)
        expect(result).to be_a(NzPostApi::Objects::Label)
        expect(result.success).to be(true)
        expect(result.consignment_status).to eq("Complete")
      end
    end

    context "when failed" do
      let(:response_body) do
        {
          "consignment_id" => "JD8H7F",
          "consignment_status" => "Failed",
          "success" => false,
          "errors" => [{ "code" => 400002, "message" => "Invalid Address" }]
        }.to_json
      end

      before do
        stub_request(:get, url)
          .with(headers: headers.except("Content-Type"))
          .to_return(status: 200, body: response_body, headers: { "Content-Type" => "application/json" })
      end

      it "returns the failed status details" do
        result = parcel_label.status(consignment_id)
        expect(result.success).to be(false)
        expect(result.consignment_status).to eq("Failed")
        expect(result.errors.first.message).to eq("Invalid Address")
      end
    end
  end

  describe "#download" do
    let(:consignment_id) { "JKA6YW" }
    let(:url) { "https://api.uat.nzpost.co.nz/parcellabel/v3/labels/#{consignment_id}?format=PDF" }
    let(:pdf_content) { "%PDF-1.7..." }

    before do
      stub_request(:get, url)
        .with(headers: headers.except("Content-Type"))
        .to_return(status: 200, body: pdf_content, headers: { "Content-Type" => "application/pdf" })
    end

    it "downloads the label" do
      result = parcel_label.download(consignment_id)
      expect(result).to eq(pdf_content)
    end
  end
end
