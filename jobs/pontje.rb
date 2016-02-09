# encoding: utf-8
require 'open-uri'
require 'json'
require 'time'

line = 'GVB_900_1' # Distelweg -> Tasmanstraat

class NoPontjeException < Exception; end

def get_next_pontje(line)
  open "http://v0.ovapi.nl/line/#{line}", "User-Agent" => "QuestionmarkDashBot (Ruby/#{RUBY_VERSION})" do |f|
    result = JSON.parse(f.read)
    if result && result[line] && a = result[line]['Actuals']
      return a.values.map{|v| Time.parse(v['ExpectedDepartureTime'])}.min
    else
      raise NoPontjeException
    end
  end
end

next_pontje = nil
last_failure = nil
SCHEDULER.every '1s' do
  # only try every two hours if we have no valid result
  next if last_failure && (Time.now - last_failure) < 60*60*2
  last_failure = nil

  begin
    next_pontje ||= get_next_pontje(line)

    diff = next_pontje - Time.now
    if diff <= 0
      next_pontje = get_next_pontje(line)
      diff = next_pontje - Time.now
    end

    diffminutes = (diff/60.0).to_i
    difftext = diffminutes.to_s + ':' + '%02d'%(diff-diffminutes*60)
    send_event("pontje", {text: difftext})

  rescue NoPontjeException
    send_event("pontje", {text: ' '})
    last_failure = Time.now
  end
end
