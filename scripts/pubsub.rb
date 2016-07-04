require 'rubygems'
require 'redis'

REDIS_CLIENT = Redis.new(:host => 'localhost', :port => 6379)

trap(:INT) { puts; exit }

begin
  REDIS_CLIENT.subscribe('__keyevent@0__:expired') do |on|
    on.subscribe do |channel, subscriptions|
      puts "Subscribed to ##{channel} (#{subscriptions} subscriptions)"
    end

    on.message do |channel, message|
      puts "##{channel}: #{message}"
      REDIS_CLIENT.unsubscribe if message == "exit"
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