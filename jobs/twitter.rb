require 'open-uri'

handle = 'questionmark_nl'

SCHEDULER.every '1h', :first_in => 0 do |job|
  open 'https://twitter.com/'+handle, 'Accept-Language' => 'en' do |f|
    result = f.read

    %w(tweets followers).each do |what|
      if result.match /([0-9,.]+)\s*#{what}/im
        value = $1.gsub(/[^0-9]/, '').to_i
        send_event("twitter-#{what}", {current: value})
      end
    end
  end
end
