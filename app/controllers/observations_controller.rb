require 'net/http'
require 'open-uri'
require "services/decision_tree_service" 
require 'date'
include ActionView::Helpers::DateHelper

class ObservationsController < ApplicationController
  before_action :set_observation, only: [:show, :edit, :update, :destroy]

  
  
  # GET /observations/new
  def new          
    timezone = "Pacific Time (US & Canada)"
    @observation = nil

    #@observation = Rails.cache.fetch("current_observation", :expires_in => 10.minutes) do      
    @observation = Rails.cache.fetch("current_observation", :expires_in => 1.seconds) do      
      # puts "here getting observation"      
      wunderground_api_key = ENV["WUNDERGROUND_API_KEY"];      
      uri = URI("http://api.wunderground.com/api/#{wunderground_api_key}/conditions/tide/astronomy/q/pws:KCASANFR69.json")
      obs_json = Net::HTTP.get(uri)         
      hash = ActiveSupport::JSON.decode(obs_json)             
      # puts obs_json
      current_obs = hash["current_observation"]
      
      #get the observation...
      observation = Observation.new        
      weather_updated_desc = current_obs["observation_time"].gsub! 'Last Updated on', 'Weather last updated on'       
      observation.obs_date_desc = weather_updated_desc[0..-4] #clear the timezone..lazy way
      observation.condition = current_obs["weather"]
      observation.wind_mph = current_obs["wind_mph"]
      observation.temp = current_obs["temp_f"]
      observation.wind_gust_mph = current_obs["wind_gust_mph"]
      observation.wind_chill = current_obs["windchill_f"]
      
      #get the tide data...
      tide_summary = hash["tide"]["tideSummary"];
      # puts tide_summary

      if tide_summary.count > 0
          next_low_tide = get_next_low_tide(tide_summary)
          if next_low_tide
            observation.next_low_tide = next_low_tide.in_time_zone(timezone).to_s
            # tide_diff = (next_low_tide - Time.now.to_datetime)
            # hours,minutes,seconds,frac = Date.send(:day_fraction_to_time, tide_diff)
            # puts "hours: " + hours.to_s
            observation.hours_until_next_lowtide = (next_low_tide.to_time - Time.now.to_datetime) / 1.hour 
            observation.hours_until_next_low_tide_desc = distance_of_time_in_words(next_low_tide,Time.now.to_datetime)
            # puts "text: " + observation.hours_until_next_low_tide_desc
            # puts "low tide: " + next_low_tide.to_s + ", now: " +  Time.now.to_datetime.to_s + ", diff: %.2f" % ((next_low_tide.to_time - Time.now) / 1.hour)            
          end

          next_high_tide = get_next_high_tide(tide_summary)
          if next_high_tide
            observation.next_high_tide = next_high_tide.in_time_zone(timezone).to_s
            observation.hours_until_next_high_tide = (next_high_tide.to_time - Time.now.to_datetime) / 1.hour 
            observation.hours_until_next_high_tide_desc = distance_of_time_in_words(next_high_tide,Time.now.to_datetime)
          end

      end
      

      sun_phase = hash["sun_phase"]
      sunrise = Time.new(Time.now.year, Time.now.month, Time.now.day, sun_phase["sunrise"]["hour"],sun_phase["sunrise"]["minute"]).in_time_zone(timezone)            
      sunset = Time.new(Time.now.year, Time.now.month, Time.now.day, sun_phase["sunset"]["hour"],sun_phase["sunset"]["minute"]).in_time_zone(timezone)
      puts "sunrise: #{sunrise}"       
      puts "sunset: #{sunset}"       
      observation.sunrise = sunrise 
      observation.sunset = sunset            
      observation.is_park_closed = !(((Time.now <=> sunrise) > -1) && ((Time.now <=> sunset) < 1))
      
      if observation.is_park_closed
        observation.go_funston = -1
      else  
        dts = DecisionTreeService.instance
        observation.go_funston = dts.get_decision(observation)
        puts "here after got decision"
      end

      #get the observation image and last update date...      
      image_uri = URI("http://www.flyfunston.org/newwebcam/panolarge.jpg")
      res = Net::HTTP.get_response(image_uri)      
      last_modified_dt =res.to_hash["last-modified"].to_s    
      observation.image_updated_at = Time.parse(last_modified_dt).in_time_zone(timezone).strftime("Image last updated on %B %d, %l:%M %p")
      Rails.cache.write('observation_image', res.body)      
      
      
      observation  
    end
    

    render json: @observation
    
    # respond_to do |format|
    #   format.html index.html.erb
    #   format.json { render json: @observation }
    # end
  end

  def image    
      img = Rails.cache.fetch("observation_image")
      if !img.nil?
        send_data Rails.cache.fetch("observation_image"), :type => "image/jpeg", :disposition => 'inline'    
      end 
  end

  # GET /observations
  # GET /observations.json
  def index
    @observations = Observation.all
  end

  # POST /observations
  # POST /observations.json
  def create
    @observation = Observation.new(observation_params)    
    
    # Observation.create!(condition_code: 0, temp: 70, wind_chill: 0, wind_mph: 2, wind_gust_mph: 2, go_funston: 1)
    #get rid of any potentially ridiculous entries.
    #there could be extreme cases where it's sunny but the wind is blowing too hard to go, but I'm simplifying things for now.
    #TODO: look into this more carefully.
    return if @observation.condition_code == 0 && @observation.go_funston == -1 
    return if @observation.condition_code == 2 && @observation.go_funston == 1 
    # puts "observation: " + @observation.to_s  

    respond_to do |format|
      if @observation.save
        DecisionTreeService.instance.train_tree #retrain tree, TODO:this should be done offline
        format.html { redirect_to @observation, notice: 'Observation was successfully created.' }
        format.json { render action: 'show', status: :created, location: @observation }
      else
        format.html { render action: 'new' }
        format.json { render json: @observation.errors, status: :unprocessable_entity }
      end
    end
  end


  # DELETE /observations/1
  # DELETE /observations/1.json
  def destroy
    @observation.destroy
    respond_to do |format|
      format.html { redirect_to observations_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_observation
      @observation = Observation.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def observation_params
      params.permit(:condition_code,:temp,:wind_chill,:wind_mph,:wind_gust_mph,:go_funston)
    end


    def get_next_low_tide(tide_summary)
      return get_next_tide(tide_summary, "Ebb")
    end

    def get_next_high_tide(tide_summary)
      return get_next_tide(tide_summary, "Flood")
    end  

    def get_next_tide(tide_summary, tide_direction)
      tide_summary.each do |tide| 
        # puts tide
        if tide["data"]["type"] == "Max #{tide_direction}"  
          tide_epoch = tide["utcdate"]["epoch"]          
          tide_date = Time.at(tide_epoch.to_i).to_datetime 
          # puts "tide date: " + tide_date.to_s         
          return tide_date
        end                  
      end

      return nil
    end
end
