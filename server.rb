require "sinatra"
require "time"
require "./constants"
Dir["./lib/*.rb"].each {|file| require file }
use Rack::Logger
require 'digest/sha1'

helpers do
  def logger
    request.logger
  end
end


get "/" do
  erb :index
end

post "/book-uber" do
  logger.info "params - #{params.inspect}"
  booking_id = Digest::SHA1.hexdigest("#{params['email']}-#{Time.now.to_i}")

  source_coordinates = params['source'].split(',').map(&:strip)
  source = Location.new(*source_coordinates)

  destination_coordinates = params['destination'].split(',').map(&:strip)
  destination = Location.new(*destination_coordinates)

  arrival_time = Time.parse(params['time'])

  email = params['email']

  time_required = UberApi.new(source).get_eta + GoogleMapsApi.new(source, destination, arrival_time.to_i).get_eta
  logger.info("Time reqd = #{time_required}")

  RedisUtils.add_booking_query(booking_id, email, source_coordinates, destination_coordinates, time_required, arrival_time)
  redirect "/"
end