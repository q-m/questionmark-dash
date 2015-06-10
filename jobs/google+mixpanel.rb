require_relative '../lib/mixpanel_dashing'
require_relative '../lib/google_analytics_dashing'

if GoogleAnalyticsDashing.configured?
  SCHEDULER.every '1h', first_in: 2 do
    viewed = visited = reach = []

    GoogleAnalyticsDashing.profiles.each do |profile|
      viewed.push GoogleAnalyticsDashing.execute_i(
        profile,
        'ga:pageviews',
        'filters' => "ga:pagePath=@/products/",
        'start-date' => Date.today - 30,
        'end-date' => DateTime.now,
        # 'dimensions' => "ga:month",
        # 'sort' => "ga:month"
      ).to_i

      visited.push GoogleAnalyticsDashing.execute_i(
        profile,
        'ga:visitors',
        'start-date' => Date.today - 30,
        'end-date' => DateTime.now
      )

      reach.push GoogleAnalyticsDashing.execute_i(
        profile,
        'ga:visitors',
        'start-date' => Date.today.strftime('%Y-01-01'),
        'end-date' => DateTime.now
      )
    end

    totalProductsViewedWeb = viewed.compact.reduce(&:+)
    totalProductsViewedApp = MixpanelDashing.event_number(event_name: "view_product")
    send_event('products_viewed_web', {current: totalProductsViewedWeb + totalProductsViewedApp})

    send_event('visitor_count', {current: visited.compact.reduce(&:+)})
    send_event('reach_this_year', {value: reach.compact.reduce(&:+)})
  end
end
