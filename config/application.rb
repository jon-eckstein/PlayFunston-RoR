require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module Playfunston
    THRESHOLD_CONDITION_CODE_MAYBE = 0
    THRESHOLD_CONDITION_CODE_NO = 1
    THRESHOLD_WIND_MPH_MAYBE_HIGH = 15
    THRESHOLD_WIND_MPH_MAYBE_LOW = 8
    THRESHOLD_WIND_MPH_NO = 16
    THRESHOLD_TEMP_MAYBE_HIGH = 55
    THRESHOLD_TEMP_MAYBE_LOW = 45
    THRESHOLD_TEMP_NO = 45
    THRESHOLD_TIDE_MAYBE_LOW = 3
    THRESHOLD_TIDE_MAYBE_HIGH = 6
    TIMEZONE = 'Pacific Time (US & Canada)'

  class Application < Rails::Application
    config.time_zone = TIMEZONE
    config.active_record.default_timezone = TIMEZONE
    config.autoload_paths += %W(#{config.root}/lib/services)
    config.autoload_paths += %W(#{config.root}/lib/simpledecisiontree)
  end
end
