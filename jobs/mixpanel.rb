# source: https://gist.github.com/ilyakatz/6175747

require 'mixpanel_client'
require 'date'
 
root = ::File.dirname(__FILE__)
require ::File.join(root, "..", 'lib', 'mixpanel_config')
require ::File.join(root, "..", 'lib', 'mixpanel_event_number')

=begin
def mixpanel_exports
  send_event('submit_product', {
     current: number_for_event_using_export("signup", "Netherlands", true)
   })
 
  send_event('mixpanel_signup_portland', {
    current: number_for_event_using_export("view_product", "portland", true)
  })
 
end
 
####### get updates from MixPanel ##########
SCHEDULER.every '24h', :first_in => 0 do |job|
  # MixPanel export API doesn't allow for concurrent requests to export API, so need to make the sequential 
  mixpanel_exports
end
=end
 
SCHEDULER.every '30m', :first_in => 0 do |job| # quite arbitrary update times set for the three events, to not collide the calls, the mixpanel export API doesn't allow for concurrent requests
  send_event('mixpanel_submit_product', {
    current: mixpanel_event_number(event_name: "submit_product")
  })
end

SCHEDULER.every '35m', :first_in => 10 do |job|
  send_event('mixpanel_signup', {
    current: mixpanel_event_number(event_name: "signup")
  })
end

SCHEDULER.every '23m', :first_in => 15 do |job|
  send_event('mixpanel_view_product', {
    current: mixpanel_event_number(event_name: "view_product")
  })
end