require_relative '../lib/google_analytics_dashing'
require 'date'

if GoogleAnalyticsDashing.configured?
  SCHEDULER.every '24h', first_in: 5 do # we have another call to GA, do first call after 5s

    # Start and end dates
    startDate = DateTime.now.strftime('%Y-01-01') # begin of the year
    endDate = DateTime.now.strftime("%Y-%m-%d")  # now
    
    visitors = Array.new
   
    GoogleAnalyticsDashing.profiles.each do |profile|
      visitCount = GoogleAnalyticsDashing.execute(
        profile,
        'ga:visitors',
        'start-date' => startDate,
        'end-date' => endDate,
        # 'dimensions' => "ga:month",
        # 'sort' => "ga:month" 
      )

      if visitCount.data.rows[0] and visitCount.data.rows[0][0] # deals with no visits
        visits = visitCount.data.rows[0][0]
      else
        visits = 0
      end
      
      visitors.push(visits.to_i) 
    end
   
    # Update the dashboard
    send_event('reach_this_year', {value: visitors.reduce(&:+)})
  end
end
