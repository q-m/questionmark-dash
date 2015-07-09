# Inspired by: https://gist.github.com/willjohnson/6232286 
require 'google/api_client'

# Google Analytics client for Dashing jobs
#
# Configuration is done in the environment:
#   GA_KEY_FILE=~/.google-analytics.p12
#   GA_ACCOUNT_EMAIL=12346-ar3984rc@developer.gserviceaccount.com
#   GA_PROFILE_ID_FOO=12345678
#   GA_PROFILE_ID_BLUP=23456789
#
# Then you can perform analytics queries using
#
#   GoogleAnalyticsDashing.execute('FOO', 'ga:pageviews', 'start-date' => ...)
#

module GoogleAnalyticsDashing

  NAME    = 'google-analytics-dashing'.freeze
  VERSION = '0.1'.freeze

  def self.config
    @@config ||= {
      key_file: ENV['GA_KEY_FILE'],
      key_secret: ENV['GA_KEY_SECRET'] || 'notasecret',
      account_email: ENV['GA_ACCOUNT_EMAIL']
    }
  end

  def self.configured?(config = self.config)
    config[:key_file] && config[:key_file].strip != ''
  end

  def self.profile_id(name)
    ENV["GA_PROFILE_ID_#{name.upcase}"]
  end

  def self.profiles
    ENV.keys.select {|k| k.start_with? 'GA_PROFILE_ID'}.map{|k| k.gsub /^GA_PROFILE_ID_/, ''}
  end

  def self.execute(profile, metrics, params={})
    params = params.merge({
      ids: "ga:#{profile_id(profile)}",
      metrics: metrics
    })
    params['start-date'] = params['start-date'].strftime('%Y-%m-%d') if params['start-date'].respond_to?(:strftime)
    params['end-date']   = params['end-date'].strftime('%Y-%m-%d') if params['end-date'].respond_to?(:strftime)
    client.execute(api_method: analytics.data.ga.get, parameters: params)
  end

  def self.execute_i(profile, metrics, params={})
    r = execute(profile, metrics, params)
    r.data.rows[0] && r.data.rows[0][0] && r.data.rows[0][0].to_i
  end

  def self.client
    @@client ||= begin
      client = Google::APIClient.new(application_name: NAME, application_version: VERSION)
      key = Google::APIClient::KeyUtils.load_from_pkcs12(config[:key_file], config[:key_secret])
      client.authorization = Signet::OAuth2::Client.new(
        :token_credential_uri => 'https://accounts.google.com/o/oauth2/token',
        :audience => 'https://accounts.google.com/o/oauth2/token',
        :scope => 'https://www.googleapis.com/auth/analytics.readonly',
        :issuer => config[:account_email],
        :signing_key => key)
      # Request a token for our service account
      client.authorization.fetch_access_token!
      client
    end
  end

  def self.analytics
    @@analytics ||= client.discovered_api('analytics','v3')
  end
end
