# source: https://gist.github.com/ilyakatz/6175747

require 'mixpanel_client'
require 'date'
 
root = ::File.dirname(__FILE__)
require ::File.join(root, "..", 'lib', 'mixpanel_config')
require ::File.join(root, "..", 'lib', 'mixpanel_event_number')
 
#def mixpanel_exports
#  send_event('submit_product', {
#     current: number_for_event_using_export("Ingezonden producten", "Netherlands", true)
#   })
 
#  send_event('mixpanel_signup_portland', {
#    current: number_for_event_using_export("Sign Up", "portland", true)
#  })
 
#end
 
####### get updates from MixPanel ##########
#SCHEDULER.every '24h', :first_in => 0 do |job|
  # MixPanel export API doesn't allow for concurrent requests to export API, so need to make the sequential 
#  mixpanel_exports
#end
 
SCHEDULER.every '10m', :first_in => 0 do |job|
  send_event('m-submit_product', {
    current: mixpanel_event_number(event_name: "submit_product")
  })
 
end