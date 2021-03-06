=begin

require 'gibbon'

apikey = ENV['MAILCHIMP_API_KEY']

if apikey
  SCHEDULER.every '5m', first_in: 0 do |job|
    gibbon = Gibbon::Request.new(api_key: apikey)
    newsletter = gibbon.lists('82ab0c48d1').retrieve
    send_event('mailchimp', {
      current: newsletter['stats']['member_count']
    })
  end
end

=end


require 'gibbon'

SCHEDULER.every '5m', first_in: 0 do |job|
  gibbon = Gibbon::API.new
  gibbon.api_key = ENV['MAILCHIMP_API_KEY']
  newsletter = gibbon.lists.list
  send_event('mailchimp', {
    current: newsletter['data'][19]['stats']['member_count']
  })
end
