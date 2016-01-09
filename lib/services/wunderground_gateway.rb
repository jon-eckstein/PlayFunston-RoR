class WundergroundGateway

  API_URL = "http://api.wunderground.com/api/#{ENV['WUNDERGROUND_API_KEY']}/conditions/tide/astronomy/q/pws:KCASANFR69.json"
  class << self
    def current_observation
      JSON.parse(RestClient.get(API_URL))
    rescue => e
      puts "Error getting wunderground observation, #{e}"
      nil
    end
  end

end