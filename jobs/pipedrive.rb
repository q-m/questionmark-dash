require 'open-uri'
require 'json'

totalValue = 0

pipedriveApiUrl = 'https://api.pipedrive.com/v1/deals?filter_id=2&api_token=' + ENV['PIPEDRIVE_API_KEY']

SCHEDULER.every '24h', :first_in => 0 do |job|
  open pipedriveApiUrl do |f|
    result = JSON.parse(f.read)
    result['data'].each do |child|
      totalValue += child['value']
    end
    send_event('pipedrive-total-deal-value', {current: totalValue})
  end
end
