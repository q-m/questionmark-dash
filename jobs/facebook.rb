require 'open-uri'
require 'json'

pages = ['questionmarkfoundation']
urls  = ['http://www.thequestionmark.org/']

SCHEDULER.every '1m', :first_in => 0 do |job|
  open 'https://graph.facebook.com/?ids=' + (pages+urls).join(',') do |f|
    result = JSON.parse(f.read)

    %w(shares talking_abount_count likes).each do |what|
      value = result.map{|url, data| data[what]}.compact.reduce(&:+)
      send_event("facebook-#{what}", {current: value})
    end
  end
end
