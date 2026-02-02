# frozen_string_literal: true

module NzPostApi
  module Resources
    class ParcelTrack
      BASE_URL = "https://api.uat.nzpost.co.nz/parceltrack/3.0/parcels"

      def initialize(client)
        @client = client
      end

      def track(tracking_reference)
        response = @client.connection.get("#{BASE_URL}/#{tracking_reference}")

        if response.success?
          Objects::ParcelTrack.new(response.body["results"])
        else
          raise NzPostApi::Error, "Failed to track parcel: #{response.status} - #{response.body}"
        end
      end

      def subscribe(tracking_reference:, notification_endpoint:)
        payload = {
          tracking_reference: tracking_reference,
          notification_endpoint: notification_endpoint
        }
        response = @client.connection.post("#{BASE_URL.sub('parcels', 'subscription/webhook/')}", payload)

        if response.success?
          Objects::ParcelTrackSubscription.new(response.body)
        else
          raise NzPostApi::Error, "Failed to subscribe to parcel: #{response.status} - #{response.body}"
        end
      end

      def unsubscribe(subscription_guid:)
        response = @client.connection.delete("#{BASE_URL.sub('parcels', 'subscription/webhook')}/#{subscription_guid}")

        if response.success?
          true
        else
          raise NzPostApi::Error, "Failed to unsubscribe from parcel: #{response.status} - #{response.body}"
        end
      end
    end
  end
end
