require 'open-uri'
require 'json'
require 'time'

source      = 'Distelweg'
destination = 'Tasmanstraat'

def get_next_pontje(source, destination)
  puts "** next pontje!"
  open "http://pontveer.nl/api/?l=#{source}&d=#{destination}&app_version=1.1.1&platform=webapp" do |f|
    result = JSON.parse(f.read)
    return Time.parse(result['departures']['1']['time'])
  end
end

next_pontje = nil
SCHEDULER.every '1s' do
  next_pontje ||= get_next_pontje(source, destination)

  diff = next_pontje - Time.now
  if diff <= 0
    next_pontje ||= get_next_pontje(source, destination)
    diff = next_pontje - Time.now
  end

  diffminutes = (diff/60.0).to_i
  difftext = diffminutes.to_s + ':' + '%02d'%(diff-diffminutes*60)
  send_event("pontje", {text: difftext})
end
