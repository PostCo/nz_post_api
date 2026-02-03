# NzPostApi

A Ruby gem wrapper for the NZ Post API.

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add nz_post_api
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install nz_post_api
```

## Usage

### Authentication

First, you need to obtain an access token using your client credentials.

```ruby
token_response = NzPostApi::Auth.fetch_token("YOUR_CLIENT_ID", "YOUR_CLIENT_SECRET")
access_token = token_response["access_token"]
expires_in = token_response["expires_in"]
```

> [!IMPORTANT]
> The access token expires after a certain period (indicated by `expires_in`). It is highly recommended to cache the `access_token` and reuse it until it expires to avoid unnecessary API calls and potential rate limiting.

Then, configure the gem and initialize the client.

```ruby
NzPostApi.configure do |config|
  config.client_id = "YOUR_CLIENT_ID"
  config.access_token = access_token
  config.prod = true # set to true for production, defaults to false (UAT)
end

client = NzPostApi::Client.new
```

### Configuration

By default, the gem uses the UAT environment. Configuration options:

- `client_id` – Your NZ Post API client ID (required for API calls)
- `access_token` – Bearer token from `NzPostApi::Auth.fetch_token` (required for API calls)
- `prod` – Set to `true` for production, `false` for UAT (default)

### Parcel Address

#### Search

Search for an address using a query string.

```ruby
address_client = client.parcel_address
response = address_client.search(q: "Damson", count: 10)

response.each do |address|
  puts address.full_address
  puts address.dpid
end
```

### Parcel Label

#### Create Label

Create a new parcel label.

- **NZ Post rates**: To use your own NZ Post rates, include `account_number` and `site_code` in the payload.
- **Notification endpoint**: The `notification_endpoint` is a webhook URL. NZ Post will send HTTP requests to this endpoint when the parcel label status is updated.
- **Service codes** (in `parcel_details`): `CPOLP` is Overnight Returns (supports pickup); `EROLE` is Economy Returns (only drop off, the pickup address street must have the prefix "PO Box" or "Private Bag" followed by digits).

```ruby
label_client = client.parcel_label

payload = {
  "carrier" => "COURIERPOST",
  "orientation" => "LANDSCAPE",
  "format" => "PDF",
  "logo_id_" => "B8D51C2B-5606-4B30-B2CD-2EAA9F4DD29F",
  "notification_endpoint" => "http://my.endpoint.com/status",
  "sender_reference_1" => "Order123",
  "sender_reference_2" => "CC 52",
  "label_dimensions" => "174x100",
  "sender_details" => {
    "name" => "Joe Sender",
    "phone" => "6490000001",
    "email" => "joe.sender@nzpost.co.nz",
    "company_name" => "Sender ltd",
    "site_code" => 44111
  },
  "pickup_address" => {
    "company_name" => "Sender ltd",
    "building_name" => "Sender Building",
    "unit_type" => "Unit",
    "unit_value" => "5",
    "floor" => "3",
    "street_number" => "151",
    "street" => "Victoria Street West",
    "suburb" => "Auckland Central",
    "city" => "Auckland",
    "country_code": "NZ",
    "postcode" => "1010"
  },
  "receiver_details" => {
    "name" => "Joe Receiver",
    "phone" => "6490000002",
    "email" => "joe.receiver@nzpost.co.nz"
  },
  "delivery_address" => {
    "is_collection" => false,
    "company_name" => "Receiver ltd",
    "building_name" => "Receiver Building",
    "unit_type" => "Suite",
    "unit_value" => "4",
    "floor" => "L2",
    "street_number" => "42C",
    "street" => "Tawa Drive",
    "suburb" => "Albany",
    "city" => "Auckland",
    "country_code" => "NZ",
    "postcode" => "0632",
    "instructions" => "Ring the doorbell"
  },
  "parcel_details" => [
    {
      "service_code" => "CPOLP",
      "return_indicator" => "RETURN",
      "description" => "MEDIUM",
      "dimensions" => {
        "length_cm" => 5.5,
        "width_cm" => 10.4,
        "height_cm" => 15,
        "weight_kg" => 5
      }
    }
  ]
}

label = label_client.create(payload)
puts label.consignment_id
```

#### Check Status

Check the status of a label generation.

```ruby
status = label_client.status("CONSIGNMENT_ID")
puts status.consignment_status
```

#### Download Label

Download a generated label in PDF format using `Tempfile`.

```ruby
require "tempfile"

pdf_content = label_client.download("CONSIGNMENT_ID", format: "PDF")

# Write to a temporary file
file = Tempfile.new(["label", ".pdf"])
file.binmode
file.write(pdf_content)
file.rewind

puts "Label saved to #{file.path}"

# Do something with the file...

file.close
file.unlink # deletes the temp file
```

### Shipping Options

#### List Options

List available shipping options based on package details.

````ruby
shipping_client = client.shipping_options

params = {
  weight: 10,
  length: 10,
  width: 10,
  height: 10,
  pickup_address_id: "990003",
  delivery_dpid: "2727895"
}

response = shipping_client.list(params)
response.services.each do |service|
  puts service.service_code
  puts service.service_code
  puts service.description
end

### Parcel Track

#### Track Parcel

Retrieve tracking events for a parcel.

```ruby
track_client = client.parcel_track
tracking = track_client.track("TRACKING_NUMBER")

puts tracking.tracking_reference
tracking.tracking_events.each do |event|
  puts "#{event.event_datetime}: #{event.event_description}"
end
```

#### Subscribe to Updates

Subscribe to tracking updates for a parcel via webhook.

```ruby
track_client = client.parcel_track
subscription = track_client.subscribe(
  tracking_reference: "TRACKING_NUMBER",
  notification_endpoint: "https://my.endpoint.com/nz_post_tracking"
)

puts subscription.subscription_guid
```

#### Unsubscribe

Unsubscribe from tracking updates.

```ruby
track_client = client.parcel_track
success = track_client.unsubscribe(subscription_guid: "SUBSCRIPTION_GUID")

if success
  puts "Unsubscribed successfully"
else
  puts "Failed to unsubscribe"
end
````

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/nz_post_api. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/nz_post_api/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the NzPostApi project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/nz_post_api/blob/main/CODE_OF_CONDUCT.md).

```

```
