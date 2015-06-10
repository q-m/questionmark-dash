require_relative '../lib/mixpanel_dashing'
require_relative '../lib/google_analytics_dashing'
require 'date'

if GoogleAnalyticsDashing.configured?
  SCHEDULER.every '1h', first_in: 8 do
    today_minus_30  = Date.today.to_date - 30
    startDate = today_minus_30.strftime("%Y-%m-%d") # 30 days ago
    endDate = DateTime.now.strftime("%Y-%m-%d")  # now

    visitors = Array.new

    GoogleAnalyticsDashing.profiles.each do |profile|
      # Execute the query
      visitCount = GoogleAnalyticsDashing.execute(
        profile,
        'ga:pageviews',
        'filters' => "ga:pagePath=@/products/",
        'start-date' => startDate,
        'end-date' => endDate,
        # 'dimensions' => "ga:month",
      )

      if visitCount.data.rows[0] and visitCount.data.rows[0][0] # deals with no visits
        visits = visitCount.data.rows[0][0]
      else
        visits = 0
      end

      visitors.push(visits.to_i)
    end

    totalProductsViewedWeb = visitors.reduce(&:+)
    totalProductsViewedApp = MixpanelDashing.event_number(event_name: "view_product")


    # Update the dashboard
    send_event('products_viewed_web', {current: totalProductsViewedWeb + totalProductsViewedApp})
  end
end
