require 'rest-client'
require 'json'

class UberApi

  API_TOKEN      = KEYS['uber_api_token']
  API_BASE_URL   = "https://api.uber.com/v1/estimates/time"
  CAB_PRODUCT_ID = "db6779d6-d8da-479f-8ac7-8068f4dade6f"  # ProductID of UberGO

  attr_accessor :source

  def initialize(source)
    @source = source
  end


  # curl -H 'Authorization: Token -L1_CxEMZes8j_5J5bL9V61tVvTJrPGEFSC_pZ2j' 'https://api.uber.com/v1/products?latitude=12.927880&longitude=77.627600&product_id=db6779d6-d8da-479f-8ac7-8068f4dade6f'
  def get_eta
    return 180
    api_params = {
      start_latitude:  self.source.coordinates[:latitude],
      start_longitude: self.source.coordinates[:longitude],
      product_id: CAB_PRODUCT_ID
    }

    response = RestClient::Request.execute(method: :get, url: API_BASE_URL, headers: { 'Authorization' => "Token #{API_TOKEN}", params: api_params })

    if response.code.to_i == 200
      get_estimated_time_of_arrival(response)
    else
      raise "Uber Api returned non-200 response"
    end
  end

  private

  def get_estimated_time_of_arrival(response)
    JSON.parse(response.body)['times'].first['estimate']
  end
end