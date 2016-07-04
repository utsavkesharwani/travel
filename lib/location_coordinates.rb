class Location

  attr_accessor :coordinates

  def initialize(latitude, longitude)
    @coordinates = { latitude: latitude, longitude: longitude }
  end

  def get_location_params_for_google_maps_api
    return "#{self.coordinates[:latitude]},#{self.coordinates[:longitude]}"
  end
end