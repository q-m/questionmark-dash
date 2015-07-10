require 'gibbon'

apikey = ENV['MAILCHIMP_API_KEY']

if apikey
  SCHEDULER.every '5m', first_in: 0 do |job|
    gibbon = Gibbon::API.new
    gibbon.api_key = apikey
    newsletter = gibbon.lists.list({:id => "48437"})
    send_event('mailchimp', {
      current: newsletter['data'][19]['stats']['member_count']
    })
  end
end
