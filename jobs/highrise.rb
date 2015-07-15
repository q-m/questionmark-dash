require 'highrise'

Highrise::Base.site = "https://#{ENV['HIGHRISE_SUBDOMAIN']}.highrisehq.com"
Highrise::Base.user = ENV['HIGHRISE_API_KEY']
Highrise::Base.format = :xml

if Highrise::Base.user
  SCHEDULER.every '1h', first_in: 0 do |job|
    value = Highrise::Deal.find(:all, :params => { :status => "won" }).map(&:price).inject(:+)
    send_event('highrise-won-deals', {current: value})
  end
end
