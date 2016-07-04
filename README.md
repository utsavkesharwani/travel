#Setup

###Ruby Setup
-  Install rvm - ```curl -L https://get.rvm.io | bash```
-  Install ruby 2.0.0p648 - ```rvm install 2.0.0p648```
-  Set default ruby to 2.0.0p648 - ```rvm use 2.0.0p648```

###Initial Setup
- Install Homebrew (http://brew.sh)
- Install redis - ```brew install redis```
- Update redis.conf to notify about keys expiring: ```vim /usr/local/etc/redis.conf``` and add ```notify-keyspace-events Ex```
- Start redis server - ```redis-server /usr/local/etc/redis.conf```
- Install bundler - ```gem install bundler```
- Install required gems - ```cd travel``` and ```bundle install```
- ```cp config/keys.sample.json config/keys.json``` and update API keys for Google & Uber

###To run server:
- ruby server.rb
