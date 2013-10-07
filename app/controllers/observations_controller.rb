require 'net/http'
require 'open-uri'
require "services/decision_tree_service" 

class ObservationsController < ApplicationController
  before_action :set_observation, only: [:show, :edit, :update, :destroy]

  
  # GET /observations/new
  def new        
    @observation = nil

    @observation = Rails.cache.fetch("current_observation", :expires_in => 10.minutes) do      
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
              
      dts = DecisionTreeService.instance
      observation.go_funston = dts.get_decision(observation)

      #get the observation image...
      path = Rails.root.join("app", "assets", "images", "current_observation_large.jpg").to_s
      open(path, 'wb') do |file|
        file << open('http://www.flyfunston.org/newwebcam/panolarge.jpg').read
      end
      
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

    respond_to do |format|
      if @observation.save
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
      params[:observation]
    end
end
