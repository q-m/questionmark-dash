require_relative '../lib/google_analytics_dashing'
require 'date'

if GoogleAnalyticsDashing.configured?
  SCHEDULER.every '1h', first_in: 0 do

    # Start and end dates
    today_minus_30  = Date.today.to_date - 30
    startDate = today_minus_30.strftime("%Y-%m-%d") # 30 days ago
    endDate = DateTime.now.strftime("%Y-%m-%d")  # now

    visitors = Array.new

    GoogleAnalyticsDashing.profiles.each do |profile|
      # Execute the query
      visitCount = GoogleAnalyticsDashing.execute(
        profile,
        "ga:visitors",
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

    # Update dashboard with sum of all visitors
    send_event('visitor_count', {current: visitors.reduce(&:+)})
  end
end
