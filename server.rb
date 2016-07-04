require "sinatra"
require "./constants"
# Dir["./lib/*.rb"].each {|file| require file }
require "./lib/booking"
use Rack::Logger
require 'digest/sha1'

helpers do
  def logger
    request.logger
  end
end

def standardise_params(params)
  target_params = {}

  ['source', 'destination'].each do |coordinates|
    target_params[coordinates] = params[coordinates].split(',').map(&:strip)
  end

  target_params['email'] = params['email']
  target_params['arrival_time']  = Time.parse(params['arrival_time']).to_i

  target_params
end

get "/" do
  erb :index
end

post "/book-uber" do
  logger.info "params - #{params.inspect}"
  booking_id = Digest::SHA1.hexdigest("#{params['email']}-#{Time.now.to_i}")

  target_params = standardise_params(params)

  Booking.create_or_update(booking_id, target_params)
  redirect "/"
end