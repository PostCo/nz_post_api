# frozen_string_literal: true

module NzPostApi
  module Resources
    class ParcelLabel
      def base_url
        "#{NzPostApi.configuration.base_url}/parcellabel/v3/labels"
      end

      def initialize(client)
        @client = client
      end

      def create(payload)
        response = @client.connection.post(base_url, payload)
        handle_response(response)
      end

      def status(consignment_id)
        response = @client.connection.get("#{base_url}/#{consignment_id}/status")
        handle_response(response)
      end

      def download(consignment_id, format: "PDF")
        response = @client.connection.get("#{base_url}/#{consignment_id}", { format: format })
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
