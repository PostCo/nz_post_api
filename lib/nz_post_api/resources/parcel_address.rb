# frozen_string_literal: true

module NzPostApi
  module Resources
    class ParcelAddress
      BASE_URL = "https://api.uat.nzpost.co.nz/parceladdress/2.0/domestic/addresses"

      def initialize(client)
        @client = client
      end

      def search(q:, count: 10)
        response = @client.connection.get(BASE_URL, { q: q, count: count })

        if response.success?
          response.body["addresses"].map { |addr| Objects::Address.new(addr) }
        else
          raise NzPostApi::Error, "Failed to search addresses: #{response.status} - #{response.body}"
        end
      end
    end
  end
end
