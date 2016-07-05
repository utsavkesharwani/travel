require 'net/smtp'
require_relative '../constants'

class UserNotifier

  $message = <<EOF
From: SENDER <#{KEYS['mail_credentials']['user_name']}>
To: RECEIVER <replace_receiver>
Subject: Time to book an uber!
Time to book an uber!
EOF

  attr_accessor :user_email

  def initialize(user_email)
    @user_email = user_email
  end

  def inform_user_to_book_uber
    smtp = Net::SMTP.new KEYS['mail_credentials']['address'], KEYS['mail_credentials']['port']
    smtp.enable_starttls
    smtp.start(KEYS['mail_credentials']['domain'], KEYS['mail_credentials']['user_name'], KEYS['mail_credentials']['password'], :login)
    smtp.send_message $message.gsub('replace_receiver', self.user_email), KEYS['mail_credentials']['user_name'], self.user_email
    smtp.finish
  end
end