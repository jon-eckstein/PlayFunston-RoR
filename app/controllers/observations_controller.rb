class ObservationsController < ApplicationController
  before_action :set_observation, only: [:show, :edit, :update, :destroy]

  # GET /observations/new
  def new
    @observation = nil

    cache_timeout = Rails.env.development? ? 0.minutes : 10.minutes

    @observation = Rails.cache.fetch('current_observation', :expires_in => cache_timeout) do
      if (observation = ObservationService.observation_from_wunderground)
        if observation.is_park_closed
          observation.go_funston = -1
        else
          dts = DecisionTreeService.instance
          observation.go_funston = dts.get_decision(observation)
        end

        #get the observation image and last update date...
        image_uri = URI('http://www.flyfunston.org/newwebcam/panolarge.jpg')
        res = Net::HTTP.get_response(image_uri)
        last_modified_dt =res.to_hash['last-modified'].to_s
        observation.image_updated_at = Time.parse(last_modified_dt).in_time_zone(Playfunston::TIMEZONE).strftime('Image last updated on %B %d, %l:%M %p')
        Rails.cache.write('observation_image', res.body)
        observation
      else
        nil
      end
    end
    
    if @observation
      render json: @observation
    else
      render json:{status: :error}, status: :bad_gateway
    end
  end

  def image    
    if(img = Rails.cache.fetch('observation_image'))
      send_data img, :type => 'image/jpeg', :disposition => 'inline'
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
  def set_observation
    @observation = Observation.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def observation_params
    params.permit(:condition_code,:temp,:wind_chill,:wind_mph,:wind_gust_mph,:go_funston)
  end

end
