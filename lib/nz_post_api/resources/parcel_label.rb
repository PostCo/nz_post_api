# frozen_string_literal: true

module NzPostApi
  module Resources
    class ParcelLabel
      BASE_URL = "https://api.uat.nzpost.co.nz/parcellabel/v3/labels"

      def initialize(client)
        @client = client
      end

      def create(payload)
        response = @client.connection.post(BASE_URL, payload)
        handle_response(response)
      end

      def status(consignment_id)
        response = @client.connection.get("#{BASE_URL}/#{consignment_id}/status")
        handle_response(response)
      end

      def download(consignment_id, format: "PDF")
        response = @client.connection.get("#{BASE_URL}/#{consignment_id}", { format: format })
        if response.success?
          response.body
        else
          raise NzPostApi::Error, "Failed to download label: #{response.status} - #{response.body}"
        end
      end

      private

      def handle_response(response)
        if response.success?
          Objects::Label.new(response.body)
        else
          raise NzPostApi::Error, "Failed to create/get label: #{response.status} - #{response.body}"
        end
      end
    end
  end
end
