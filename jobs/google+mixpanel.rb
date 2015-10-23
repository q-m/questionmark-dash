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
    uniqueVisitorsQuarterly = []
    sessionsQuarterly = []
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

      uniqueVisitorsQuarterly.push GoogleAnalyticsDashing.execute_i(
        profile,
        'ga:users',
        'start-date' => Date.today - 90,
        'end-date' => Date.today
      )

      sessionsQuarterly.push GoogleAnalyticsDashing.execute_i(
        profile,
        'ga:sessions',
        'start-date' => Date.today - 90,
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

    # unique visitors for the last 30 days on all properties
    send_event('visitor_count', {current: uniqueVisitorsMonthly.compact.reduce(&:+)})

    # unique visitors for the last year on all properties
    send_event('reach_this_year', {value: uniqueVisitorsYearly.compact.reduce(&:+)})

    # sessions per user for the last month on all properties, by dividing sessions monthly by uv monthly
    sessionsPerUserPerMonth = (sessionsMonthly.compact.reduce(&:+).to_f/uniqueVisitorsMonthly.compact.reduce(&:+).to_f).round(2)
    send_event('sessions_count', {current: sessionsPerUserPerMonth})

    # sessions per user for the last month on web
    sessionsPerUserPerMonthWeb = (sessionsMonthly[0].to_f/uniqueVisitorsMonthly[0].to_f).round(2)
    send_event('sessions_count_web', {current: sessionsPerUserPerMonthWeb})

    # sessions per user for the last month on app
    sessionsPerUserPerMonthApp = (sessionsMonthly[1].to_f/uniqueVisitorsMonthly[1].to_f).round(2)
    send_event('sessions_count_app', {current: sessionsPerUserPerMonthApp})

    # sessions per user for 2015 on web
    sessionsPerUserThisYearWeb = (sessionsQuarterly[0].to_f/uniqueVisitorsQuarterly[0].to_f).round(2)
    send_event('sessions_count_web_quarterly', {current: sessionsPerUserThisYearWeb})

    # sessions per user for 2015 on app
    sessionsPerUserThisYearApp = (sessionsQuarterly[1].to_f/uniqueVisitorsQuarterly[1].to_f).round(2)
    send_event('sessions_count_app_quarterly', {current: sessionsPerUserThisYearApp})

  end

end
