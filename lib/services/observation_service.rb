class ObservationService
  class << self
    def observation_from_wunderground
      wu_observation = WundergroundGateway.current_observation
      return nil unless wu_observation


      observation = Observation.new
      if(current_obs = wu_observation['current_observation'])
        weather_updated_desc = current_obs['observation_time'].gsub! 'Last Updated on', 'Weather last updated on'
        observation.obs_date_desc = weather_updated_desc[0..-4] #clear the timezone..lazy way
        observation.condition = current_obs['weather']
        observation.wind_mph = current_obs['wind_mph']
        observation.temp = current_obs['temp_f']
        observation.wind_gust_mph = current_obs['wind_gust_mph']
        observation.wind_chill = current_obs['windchill_f']
      end


      #get the tide data...
      if(tide_summary = wu_observation['tide']['tideSummary'])
        if tide_summary.count > 0
          next_low_tide = get_next_low_tide(tide_summary)
          if next_low_tide
            observation.next_low_tide = next_low_tide.in_time_zone(timezone).to_s
            observation.hours_until_next_lowtide = (next_low_tide.to_time - Time.now.to_datetime) / 1.hour
            observation.hours_until_next_low_tide_desc = distance_of_time_in_words(next_low_tide,Time.now.to_datetime)
          end

          next_high_tide = get_next_high_tide(tide_summary)
          if next_high_tide
            observation.next_high_tide = next_high_tide.in_time_zone(timezone).to_s
            observation.hours_until_next_high_tide = (next_high_tide.to_time - Time.now.to_datetime) / 1.hour
            observation.hours_until_next_high_tide_desc = distance_of_time_in_words(next_high_tide,Time.now.to_datetime)
          end
        end
      end

      # get sun_phase data
      if(sun_phase = wu_observation['sun_phase'])
        sunrise = Time.new(Time.now.year, Time.now.month, Time.now.day, sun_phase['sunrise']['hour'],sun_phase['sunrise']['minute']).in_time_zone(timezone)
        sunset = Time.new(Time.now.year, Time.now.month, Time.now.day, sun_phase['sunset']['hour'],sun_phase['sunset']['minute']).in_time_zone(timezone)
        observation.sunrise = sunrise
        observation.sunset = sunset
        observation.is_park_closed = !(((Time.now <=> sunrise) > -1) && ((Time.now <=> sunset) < 1))
      end

      observation
    end

    def observation_from_forecastio(observation)
      nil
    end


    private
    def get_next_low_tide(tide_summary)
      return get_next_tide(tide_summary, 'Ebb')
    end

    def get_next_high_tide(tide_summary)
      return get_next_tide(tide_summary, 'Flood')
    end

    def get_next_tide(tide_summary, tide_direction)
      tide_summary.each do |tide|
        # puts tide
        if tide['data']['type'] == "Max #{tide_direction}"
          tide_epoch = tide['utcdate']['epoch']
          tide_date = Time.at(tide_epoch.to_i).to_datetime
          return tide_date
        end
      end

      return nil
    end

    def timezone
      Playfunston::TIMEZONE
    end
  end
end