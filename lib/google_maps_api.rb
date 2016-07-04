require 'rest-client'
require 'json'

class GoogleMapsApi

  API_TOKEN    = KEYS['google_api_token']
  TRAVEL_MODE  = "driving"
  API_BASE_URL = "https://maps.googleapis.com/maps/api/directions/json"

  attr_accessor :source, :destination, :arrival_time

  def initialize(source, destination, arrival_time)
    @source       = source
    @destination  = destination
    @arrival_time = arrival_time
  end

  # curl -vvv "https://maps.googleapis.com/maps/api/directions/json?origin=12.927880,77.627600&mode=driving&destination=13.035542,77.597100&arrival_time=1467441000"
  def get_eta
    return 3007
    api_params = {
      origin:       self.source.get_location_params_for_google_maps_api,
      destination:  self.destination.get_location_params_for_google_maps_api,
      arrival_time: self.arrival_time,
      mode:         TRAVEL_MODE,
      key:          API_TOKEN
    }

    response = RestClient.get API_BASE_URL, { params: api_params }

    if response.code.to_i == 200
      get_estimated_travel_time(response)
    else
      raise "GoogleMaps Api returned non-200 response"
    end
  end

  private

  def get_estimated_travel_time(response)
    JSON.parse(response.body)["routes"].first["legs"].first['duration']["value"]
  end
end
