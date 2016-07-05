require "redis"
require "time"
require_relative "uber_api"
require_relative "google_maps_api"
require_relative "user_notifier"

class Booking

  def self.create_or_update(booking_id, target_params)
    time_required = calculate_required_time(target_params)

    if its_time_to_notify_user?(time_required, target_params['arrival_time'])
      notifier = UserNotifier.new(target_params['email'])
      notifier.inform_user_to_book_uber
      return
    end

    if target_params['time_required']
      trust_factor = similar_or_lesser_eta_as_last_check?(target_params['time_required'], time_required) ? 1 : -1
    else
      trust_factor = 0
    end

    recheck_time = get_time_to_recheck_eta(time_required, target_params['arrival_time'], trust_factor)
    target_params.merge!({ 'time_required' => time_required })
    REDIS_CLIENT.hset('bookings', booking_id, target_params.to_json)
    REDIS_CLIENT.setex(booking_id, recheck_time, 1)
  end

  private

  def self.calculate_required_time(target_params)
    uber_time     = UberApi.new(target_params['source']).get_eta
    create_api_call_log("Uber", target_params['email'])

    travel_time   = GoogleMapsApi.new(target_params['source'], target_params['destination'], target_params['arrival_time']).get_eta
    create_api_call_log("Maps", target_params['email'])

    time_required = uber_time.to_i + travel_time.to_i
  end

  def self.similar_or_lesser_eta_as_last_check?(old_eta, current_eta)
    current_eta < old_eta + 60  ## Assuming +60 seconds as same eta
  end

  def self.get_time_to_recheck_eta(time_required, arrival_time, trust_factor)
    current_time = Time.now.to_i
    arrival_time = arrival_time.to_i

    if trust_factor < 1
      return 60 ## Check eta again in a minute, if eta is changing frequently.
    else
      current_difference = (arrival_time - time_required - current_time)
      if current_difference > MAX_TIME_DEVIATION
        return current_difference - MAX_TIME_DEVIATION

      elsif current_difference > 45*60
        return current_difference - 45*60

      elsif current_difference > 30*60
        return current_difference - 30*60
        
      elsif current_difference > 20*60
        return current_difference - 20*60

      elsif current_difference > 15*60
        return current_difference - 15*60

      elsif current_difference > 10*60
        return current_difference - 10*60

      else
        return (60 - (current_difference%60)) ## Check eta again every minute, if time to leave is less than 10 mins.
      end
    end
  end

  def self.its_time_to_notify_user?(time_required, arrival_time)
    puts "#{Time.now.to_i} + #{time_required} >= #{arrival_time.to_i}"
    Time.now.to_i + time_required >= arrival_time.to_i
  end

  def self.create_api_call_log(api_client, user_email)
    REDIS_CLIENT.rpush("api-calls", "#{Time.now} - Requested #{api_client} API for [#{user_email}]")
  end
end