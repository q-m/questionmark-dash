# source: https://gist.github.com/ilyakatz/6175747

class MixPanelConfiguration
 
  def self.config
    {
      api_key: ENV['MIXPANEL_API_KEY'],
      api_secret: ENV['MIXPANEL_API_SECRET']
    }
  end
 
end