require_relative '../lib/mixpanel_dashing'
require_relative '../lib/google_analytics_dashing'

if GoogleAnalyticsDashing.configured?
  SCHEDULER.every '5m', first_in: 0 do

    viewed = []
    viewed.push GoogleAnalyticsDashing.execute_i(
      'web',
      'ga:pageviews',
      'filters' => "ga:pagePath=@/products/",
      'start-date' => Date.today - 30,
      'end-date' => Date.today,
      # 'dimensions' => "ga:month",
      # 'sort' => "ga:month"
    )
    totalProductsViewedWeb = viewed.compact.reduce(&:+)
    totalProductsViewedApp = MixpanelDashing.event_number(event_name: "view_product")
    send_event('products_viewed', {current: totalProductsViewedWeb + totalProductsViewedApp})

    visited = []
    reach = []
    ['web', 'app'].each do |profile|
      visited.push GoogleAnalyticsDashing.execute_i(
        profile,
        'ga:visitors',
        'start-date' => Date.today - 30,
        'end-date' => Date.today
      )
      reach.push GoogleAnalyticsDashing.execute_i(
        profile,
        'ga:visitors',
        'start-date' => Date.today.strftime('%Y-01-01'),
        'end-date' => Date.today
      )
    end
    send_event('visitor_count', {current: visited.compact.reduce(&:+)})
    send_event('reach_this_year', {value: reach.compact.reduce(&:+)})
  end

end
