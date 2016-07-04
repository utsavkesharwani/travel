require "redis"
require "json"

REDIS_CLIENT = Redis.new(:host => 'localhost', :port => 6379)

MAX_TIME_DEVIATION = 3600

KEYS = JSON.parse(File.read("./config/keys.json"))