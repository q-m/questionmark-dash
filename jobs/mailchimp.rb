require 'gibbon'

apikey = ENV['MAILCHIMP_API_KEY']

if apikey
  SCHEDULER.every '5m', first_in: 0 do |job|
    gibbon = Gibbon::API.new
    gibbon.api_key = apikey
    newsletter = gibbon.lists.list({:id => "48437"})
    send_event('mailchimp', {
      # the following is a hack, we get the 21st list, just should get the list by id...
      current: newsletter['data'][21]['stats']['member_count']
    })
  end
end
