require 'open-uri'
require 'json'

pages = ['questionmarkfoundation']
urls  = ['http://www.thequestionmark.org/']

metrics = {
  'shares' => lambda {|d| d['share'] && d['share']['share_count']},
  'talking_about_count' => lambda {|d| d['talking_about_count']},
  'likes' => lambda {|d| d['likes']},
}

SCHEDULER.every '24h', :first_in => 0 do |job|
  open 'https://graph.facebook.com/?ids=' + (pages+urls).join(',') do |f|
    result = JSON.parse(f.read)

    metrics.each_pair do |what, getter|
      values = result.map{|url, data| getter.call(data)}
      value = values.to_a.compact.reduce(&:+)

      send_event("facebook-#{what}", {current: value})
    end
  end
end
