require 'redis'

class RedisUtils

  def self.add_booking_query(booking_id, email, source_coordinates, destination_coordinates, time_required, arrival_time)
    REDIS_CLIENT.hset('bookings', booking_id, { email: email, source: source_coordinates, destination: destination_coordinates }.to_json)

    recheck_time = arrival_time.to_i - (time_required + MAX_TIME_DEVIATION) - Time.now.to_i
    REDIS_CLIENT.setex(booking_id, recheck_time, 1)
  end
end