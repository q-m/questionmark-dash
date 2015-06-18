require 'open-uri'
require 'json'

api_key = ENV['PIPEDRIVE_API_KEY']

if api_key
  pipedriveApiUrl = 'https://api.pipedrive.com/v1/deals?filter_id=2&api_token=' + api_key

  SCHEDULER.every '24h', first_in: 0 do |job|
    open pipedriveApiUrl do |f|
      result = JSON.parse(f.read)
      totalValue = result['data'].map {|d| d['value']}.reduce(&:+)
      send_event('pipedrive-total-deal-value', {current: totalValue})
    end
  end
end
