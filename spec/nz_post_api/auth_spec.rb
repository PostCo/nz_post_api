# frozen_string_literal: true

RSpec.describe NzPostApi::Auth do
  describe ".fetch_token" do
    let(:client_id) { "client_id" }
    let(:client_secret) { "client_secret" }
    let(:token_url) { "https://oauth.nzpost.co.nz/as/token.oauth2" }
    let(:response_body) do
      {
        "access_token" => "test_token",
        "token_type" => "Bearer",
        "expires_in" => 86399
      }.to_json
    end

    before do
      stub_request(:post, token_url)
        .with(
          body: {
            "client_id" => client_id,
            "client_secret" => client_secret,
            "grant_type" => "client_credentials"
          }
        )
        .to_return(status: 200, body: response_body, headers: { "Content-Type" => "application/json" })
    end

    it "fetches the access token" do
      result = described_class.fetch_token(client_id, client_secret)
      expect(result["access_token"]).to eq("test_token")
    end

    context "when the request fails" do
      before do
        stub_request(:post, token_url)
          .with(
            body: {
              "client_id" => client_id,
              "client_secret" => client_secret,
              "grant_type" => "client_credentials"
            }
          )
          .to_return(status: 401, body: "Unauthorized")
      end

      it "raises an error" do
        expect {
          described_class.fetch_token(client_id, client_secret)
        }.to raise_error(NzPostApi::Error, /401/)
      end
    end
  end
end
