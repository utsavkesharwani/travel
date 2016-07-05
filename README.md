#Setup

###Ruby Setup
-  Install rvm - ```curl -L https://get.rvm.io | bash```
-  Install ruby 2.0.0p648 - ```rvm install 2.0.0p648```
-  Set default ruby to 2.0.0p648 - ```rvm use 2.0.0p648```

###Redis Setup
- Install Homebrew (http://brew.sh)
- redis 3.0.5 or latest (since we use its [Keyspace Notifications])
  - `brew install redis`
  - `vim /usr/local/etc/redis.conf` and add `notify-keyspace-events "Ex"`
- Start redis server - ```redis-server /usr/local/etc/redis.conf```

###Server Setup
- Install bundler - ```gem install bundler```
- Install required gems
  - ```cd travel``` and ```bundle install```
- ```cp config/keys.sample.json config/keys.json``` and update API keys for Google & Uber

###To run server:
- ruby server.rb

###To run redis-suscriber:
- ruby scripts/pubsib.rb

###Assumptions:
- API calls take 0 seconds to respond
- At any point of time, an Uber GO is available with finite eta

[Keyspace Notifications]: <http://redis.io/topics/notifications>
