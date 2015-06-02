require 'mixpanel_dashing'
 
SCHEDULER.every '30m', first_in: 0 do |job|
  send_event('mixpanel_submit_product', {
    current: MixpanelDashing.event_number(event_name: "submit_product")
  })
 
  send_event('mixpanel_signup', {
    current: MixpanelDashing.event_number(event_name: "signup")
  })

  send_event('mixpanel_view_product', {
    current: MixpanelDashing.event_number(event_name: "view_product")
  })
end
