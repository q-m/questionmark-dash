require 'uptimerobot'

# set the uptimerobot api key to fetch data
apikey = ENV['UPTIMEROBOT_APIKEY']

# number of days for uptime ratio, defaults to 30 days
period = ENV['UPTIMEROBOT_PERIOD'] || 30

if apikey
  SCHEDULER.every '5m', first_in: 0 do |job|
    client = UptimeRobot::Client.new(apiKey: apikey)

    monitors = client.getMonitors(customUptimeRatio: period)['monitors']['monitor']

    send_event('uptimerobot', {
      monitors: monitors.map do |monitor|
        {
          name: monitor['friendlyname'],
          status: 'S' << monitor['status'],
          uptime: monitor['customuptimeratio']
        }
      end
    })
  end
end
