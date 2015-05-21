require 'mixpanel_client'
require 'date'
 
root = ::File.dirname(__FILE__)
require ::File.join(root, "..", 'lib', 'mixpanel_config')
require ::File.join(root, "..", 'lib', 'mixpanel_event_number')
 
def mixpanel_exports
  send_event('submit_product', {
    current: number_for_event_using_export("Aantal toegevoegde producten")
  })
 
#  send_event('mixpanel_signup_portland', {
#    current: number_for_event_using_export("Sign Up", "portland", true)
#  })
 
end
 
####### get updates from MixPanel ##########
SCHEDULER.every '1m', :first_in => 0 do |job|
  # MixPanel export API doesn't allow for concurrent requests to export API, so need to make the sequential 
  mixpanel_exports
end
 
SCHEDULER.every '1m', :first_in => 0 do |job|
  send_event('submit_product', {
    current: mixpanel_event_number(event_name: "Aantal toegevoegde producten")
  })
 
end