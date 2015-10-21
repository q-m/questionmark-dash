require_relative '../lib/mixpanel_dashing'
require_relative '../lib/google_analytics_dashing'

if GoogleAnalyticsDashing.configured?
  SCHEDULER.every '1h', first_in: 0 do

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

    uniqueVisitorsMonthly = []
    uniqueVisitorsYearly = []
    sessionsMonthly = []
    pageViewsMonthly = []

    ['web', 'app'].each do |profile|
      uniqueVisitorsMonthly.push GoogleAnalyticsDashing.execute_i(
        profile,
        'ga:users',
        'start-date' => Date.today - 30,
        'end-date' => Date.today
      )
      uniqueVisitorsYearly.push GoogleAnalyticsDashing.execute_i(
        profile,
        'ga:users',
        'start-date' => Date.today.strftime('%Y-01-01'),
        'end-date' => Date.today
      )
      sessionsMonthly.push GoogleAnalyticsDashing.execute_i(
        profile,
        'ga:sessions',
        'start-date' => Date.today - 30,
        'end-date' => Date.today
      )
      pageViewsMonthly.push GoogleAnalyticsDashing.execute_i(
        profile,
        'ga:pageviews',
        'start-date' => Date.today - 30,
        'end-date' => Date.today
      )
    end

    # calculate sessions per user for the last month on web and app, by dividing sessions monthly by uv monthly
    sessionsPerUserPerMonth = (sessionsMonthly.compact.reduce(&:+).to_f/uniqueVisitorsMonthly.compact.reduce(&:+).to_f).round(2)

    send_event('sessions_count', {current: sessionsPerUserPerMonth})

    send_event('visitor_count', {current: uniqueVisitorsMonthly.compact.reduce(&:+)})
    send_event('reach_this_year', {value: uniqueVisitorsYearly.compact.reduce(&:+)})
  end

end
