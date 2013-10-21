require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module Playfunston
    THRESHOLD_CONDITION_CODE_MAYBE = 0;
    THRESHOLD_CONDITION_CODE_NO = 1;
    THRESHOLD_WIND_MPH_MAYBE_HIGH = 25;
    THRESHOLD_WIND_MPH_MAYBE_LOW = 15;
    THRESHOLD_WIND_MPH_NO = 25;
    THRESHOLD_TEMP_MAYBE_HIGH = 55;
    THRESHOLD_TEMP_MAYBE_LOW = 45;
    THRESHOLD_TEMP_NO = 45;
    THRESHOLD_TIDE_MAYBE_LOW = 3;    
    THRESHOLD_TIDE_MAYBE_HIGH = 6;    
  class Application < Rails::Application
    



  end
end
