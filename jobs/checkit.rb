require_relative '../lib/mixpanel_dashing_checkit'
require 'date'

# calculate number of events since launching the appe
numberOfDaysSinceLaunch = (Date.today - Date.new(2015,11,21)).round


SCHEDULER.every '5m', :first_in => 0 do |job|
  totalGroceriesAdded = MixpanelDashing.event_number(event_name: "ADD_GROCERY", num_days: numberOfDaysSinceLaunch)
  send_event('groceries_added', {current: totalGroceriesAdded})
end
