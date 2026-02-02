# frozen_string_literal: true

RSpec.describe NzPostApi::Resources::ParcelTrack do
  let(:client_id) { "client_id" }
  let(:access_token) { "access_token" }
  let(:client) { NzPostApi::Client.new(client_id: client_id, access_token: access_token) }
  let(:resource) { described_class.new(client) }

  describe "#track" do
    let(:tracking_reference) { "12345" }
    let(:url) { "https://api.uat.nzpost.co.nz/parceltrack/3.0/parcels/#{tracking_reference}" }

    context "when successful" do
      let(:response_body) do
        {
          "success" => true,
          "results" => {
            "tracking_reference" => tracking_reference,
            "tracking_events" => [
              {
                "event_description" => "Picked up"
              }
            ]
          }
        }.to_json
      end

      before do
        stub_request(:get, url)
          .with(headers: { "Authorization" => "Bearer #{access_token}", "client_id" => client_id })
          .to_return(status: 200, body: response_body, headers: { "Content-Type" => "application/json" })
      end

      it "returns a ParcelTrack object" do
        result = resource.track(tracking_reference)
        expect(result).to be_a(NzPostApi::Objects::ParcelTrack)
        expect(result.tracking_reference).to eq(tracking_reference)
        expect(result.tracking_events.first.event_description).to eq("Picked up")
      end
    end

    context "when failed" do
      before do
        stub_request(:get, url)
          .to_return(status: 404, body: '{"success": false, "message": "Not Found"}', headers: { "Content-Type" => "application/json" })
      end

      it "raises an error" do
        expect { resource.track(tracking_reference) }.to raise_error(NzPostApi::Error, /Failed to track parcel/)
      end
    end
  end

  describe "#subscribe" do
    let(:tracking_reference) { "00794210309523954849" }
    let(:notification_endpoint) { "https://my.endpoint.com/nz_post_tracking" }
    let(:url) { "https://api.uat.nzpost.co.nz/parceltrack/3.0/subscription/webhook/" }

    context "when successful" do
      let(:response_body) do
        {
          "success" => true,
          "message_id" => "644294e0-001e-11f1-84ee-0231adeb35eb",
          "subscription_guid" => "E6D6E09A-6567-4AA5-B91C-055ED703592D"
        }.to_json
      end

      before do
        stub_request(:post, url)
          .with(
            headers: { "Authorization" => "Bearer #{access_token}", "client_id" => client_id },
            body: { tracking_reference: tracking_reference, notification_endpoint: notification_endpoint }.to_json
          )
          .to_return(status: 200, body: response_body, headers: { "Content-Type" => "application/json" })
      end

      it "returns a ParcelTrackSubscription object" do
        request = resource.subscribe(tracking_reference: tracking_reference, notification_endpoint: notification_endpoint)
        expect(request).to be_a(NzPostApi::Objects::ParcelTrackSubscription)
        expect(request.subscription_guid).to eq("E6D6E09A-6567-4AA5-B91C-055ED703592D")
      end
    end

    context "when failed" do
      before do
        stub_request(:post, url)
          .to_return(status: 400, body: '{"success": false, "message": "Bad Request"}', headers: { "Content-Type" => "application/json" })
      end

      it "raises an error" do
        expect {
          resource.subscribe(tracking_reference: tracking_reference, notification_endpoint: notification_endpoint)
        }.to raise_error(NzPostApi::Error, /Failed to subscribe to parcel/)
      end
    end
  end

  describe "#unsubscribe" do
    let(:subscription_guid) { "E6D6E09A-6567-4AA5-B91C-055ED703592D" }
    let(:url) { "https://api.uat.nzpost.co.nz/parceltrack/3.0/subscription/webhook/#{subscription_guid}" }

    context "when successful" do
      before do
        stub_request(:delete, url)
          .with(headers: { "Authorization" => "Bearer #{access_token}", "client_id" => client_id })
          .to_return(status: 200, body: '{"success": true}', headers: { "Content-Type" => "application/json" })
      end

      it "returns true" do
        expect(resource.unsubscribe(subscription_guid: subscription_guid)).to be(true)
      end
    end

    context "when failed" do
      before do
        stub_request(:delete, url)
          .to_return(status: 400, body: '{"success": false, "errors": [{"message": "Bad Request"}]}', headers: { "Content-Type" => "application/json" })
      end

      it "raises an error" do
        expect { resource.unsubscribe(subscription_guid: subscription_guid) }.to raise_error(NzPostApi::Error, /Failed to unsubscribe from parcel/)
      end
    end
  end
end
