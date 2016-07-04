require 'rubygems'
require 'redis'
require "time"
require "./constants"
require "./lib/booking"

REDIS_SUBSCRIBER = Redis.new(:host => 'localhost', :port => 6379)

trap(:INT) { puts; exit }

def recalculate_eta(booking_id)
  params = JSON.parse(REDIS_CLIENT.hget('bookings', booking_id))
  Booking.create_or_update(booking_id, params)
end

begin
  REDIS_SUBSCRIBER.subscribe('__keyevent@0__:expired') do |on|
    on.subscribe do |channel, subscriptions|
      puts "Subscribed to ##{channel} (#{subscriptions} subscriptions)"
    end

    on.message do |channel, message|
      puts "##{channel}: #{message}"
      REDIS_SUBSCRIBER.unsubscribe if message == "exit"

      recalculate_eta(message)
    end

    on.unsubscribe do |channel, subscriptions|
      puts "Unsubscribed from ##{channel} (#{subscriptions} subscriptions)"
    end
  end
rescue Redis::BaseConnectionError => error
  puts "#{error}, retrying in 1s"
  sleep 1
  retry
end
