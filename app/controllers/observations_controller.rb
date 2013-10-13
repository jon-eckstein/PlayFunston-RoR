require 'net/http'
require 'open-uri'
require "services/decision_tree_service" 
require 'date'
include ActionView::Helpers::DateHelper

class ObservationsController < ApplicationController
  before_action :set_observation, only: [:show, :edit, :update, :destroy]

  
  # GET /observations/new
  def new          
    @observation = nil

    # @observation = Rails.cache.fetch("current_observation", :expires_in => 10.minutes) do      
    @observation = Rails.cache.fetch("current_observation", :expires_in => 1.seconds) do      
      puts "here getting observation"
      uri = URI("http://api.wunderground.com/api/f88d918861288deb/conditions/tide/q/pws:KCASANFR69.json")
      obs_json = Net::HTTP.get(uri)      
      hash = ActiveSupport::JSON.decode(obs_json)       
      current_obs = hash["current_observation"]
      #get the observation...
      observation = Observation.new  
      observation.obs_date_desc = current_obs["observation_time"]
      observation.condition = current_obs["weather"]
      observation.wind_mph = current_obs["wind_mph"]
      observation.temp = current_obs["temp_f"]
      observation.wind_gust_mph = current_obs["wind_gust_mph"]
      observation.wind_chill = current_obs["windchill_f"]
      
      #get the tide data...
      tide_summary = hash["tide"]["tideSummary"];
      if tide_summary.count > 0
          next_low_tide = get_next_low_tide(tide_summary)
          if next_low_tide
            observation.next_low_tide = next_low_tide.in_time_zone("Pacific Time (US & Canada)").to_s
            # tide_diff = (next_low_tide - Time.now.to_datetime)
            # hours,minutes,seconds,frac = Date.send(:day_fraction_to_time, tide_diff)
            # puts "hours: " + hours.to_s
            observation.hours_until_next_lowtide = (next_low_tide.to_time - Time.now.to_datetime) / 1.hour 
            observation.hours_until_next_low_tide_desc = distance_of_time_in_words(next_low_tide,Time.now.to_datetime)
            # puts "text: " + observation.hours_until_next_low_tide_desc
            # puts "low tide: " + next_low_tide.to_s + ", now: " +  Time.now.to_datetime.to_s + ", diff: %.2f" % ((next_low_tide.to_time - Time.now) / 1.hour)            
          end 
      end
      

      dts = DecisionTreeService.instance
      observation.go_funston = dts.get_decision(observation)

      #get the observation image...
      # path = Rails.root.join("app", "assets", "images", "current_observation_large.jpg").to_s
      # open(path, 'wb') do |file|
      #   file << open('http://www.flyfunston.org/newwebcam/panolarge.jpg').read
      # end
      
      observation  
    end
    

    render json: @observation
    
    # respond_to do |format|
    #   format.html index.html.erb
    #   format.json { render json: @observation }
    # end
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
      tide_summary.each do |tide| 
        # puts tide
        if tide["data"]["type"] == "Max Ebb"
          tide_epoch = tide["utcdate"]["epoch"]          
          tide_date = Time.at(tide_epoch.to_i).to_datetime 
          # puts "tide date: " + tide_date.to_s         
          return tide_date
        end                  
      end

      return nil
    end
end
