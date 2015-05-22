# source: https://gist.github.com/willjohnson/6232286

require 'google/api_client'
require 'date'
 
# Update these to match your own apps credentials
service_account_email = '812494510900-94lo81hb3a1asv3ihi6j812ssvuhp508@developer.gserviceaccount.com' # Email of service account
key_file = 'keys/API Project-ab93d389bbd3.p12' # File containing your private key
key_secret = 'notasecret' # Password to unlock private key
# Array of profile names and corresponding Analytics profile id
profiles = [{name: 'Website', id: '78868897'},{name: 'Apps', id: '65811751'}]
#  ,
#        {name: 'site2', id: '22222222'},
#        {name: 'site3', id: '33333333'},
#        {name: 'site4', id: '44444444'}
#      ]
 
# Get the Google API client
client = Google::APIClient.new(:application_name => 'questionmark-analytics', 
  :application_version => '0.01')
 
# Load your credentials for the service account
key = Google::APIClient::KeyUtils.load_from_pkcs12(key_file, key_secret)
client.authorization = Signet::OAuth2::Client.new(
  :token_credential_uri => 'https://accounts.google.com/o/oauth2/token',
  :audience => 'https://accounts.google.com/o/oauth2/token',
  :scope => 'https://www.googleapis.com/auth/analytics.readonly',
  :issuer => service_account_email,
  :signing_key => key)
 
# Start the scheduler
SCHEDULER.every '30m', :first_in => 0 do # modified from 1m
 
  # Request a token for our service account
  client.authorization.fetch_access_token!
 
  # Get the analytics API
  analytics = client.discovered_api('analytics','v3')
 
  # Start and end dates
  #startDate = DateTime.now.strftime("%Y-%m-01") # first day of current month
  
  today_minus_30  = Date.today.to_date - 30
  startDate = today_minus_30.strftime("%Y-%m-%d") # 30 days ago
  endDate = DateTime.now.strftime("%Y-%m-%d")  # now
  
  visitors = Array.new
 
  profiles.each do |profile|
    # Execute the query
    visitCount = client.execute(:api_method => analytics.data.ga.get, :parameters => { 
      'ids' => "ga:" + profile[:id],
      'start-date' => startDate,
      'end-date' => endDate,
      # 'dimensions' => "ga:month",
      'metrics' => "ga:visitors",
      # 'sort' => "ga:month" 
    })
    
    if visitCount.data.rows[0] and visitCount.data.rows[0][0] # deals with no visits
      visits = visitCount.data.rows[0][0]
    else
      visits = 0
    end
    
    visitors.push(visits) 
end
 
  # Update the dashboard
  send_event('visitor_count', {current: visitors.map(&:to_i).reduce(:+)}) # this visitors.map(&:to_i).reduce(:+)} adds all the visitors in the array to a total
end