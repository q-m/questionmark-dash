# combining Mixpanel and Google Analytics
# sources: https://gist.github.com/willjohnson/6232286 & https://gist.github.com/ilyakatz/6175747

######################
## Google Analytics ##
######################
require 'google/api_client'
require 'date'
 
# Update these to match your own apps credentials
service_account_email = 'xxxx@developer.gserviceaccount.com' # Email of service account
key_file = 'project-xxxx.p12' # File containing your private key
key_secret = 'notasecret' # Password to unlock private key
profiles = [{name: 'Website', id: 'xxxx'},{name: 'Apps', id: 'xxxx'}]
 
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
  
##############
## Mixpanel ##
##############
require 'mixpanel_client'
require 'date'
 
root = ::File.dirname(__FILE__)
require ::File.join(root, "..", 'lib', 'mixpanel_config')
require ::File.join(root, "..", 'lib', 'mixpanel_event_number')

 
# Start the scheduler
SCHEDULER.every '1h', :first_in => 8 do # modified from 1m
 
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
      'metrics' => "ga:pageviews",
      'filters' => "ga:pagePath=@/products/" 
    })
    
    if visitCount.data.rows[0] and visitCount.data.rows[0][0] # deals with no visits
      visits = visitCount.data.rows[0][0]
    else
      visits = 0
    end
    
    visitors.push(visits) 
  end
   
  totalProductsViewedWeb = visitors.map(&:to_i).reduce(:+)
  totalProductsViewedinApp = mixpanel_event_number(event_name: "view_product")
  
  
  # Update the dashboard
  send_event('products_viewed_web', {current: totalProductsViewedWeb + totalProductsViewedinApp})
end
