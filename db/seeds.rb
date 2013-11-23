# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

#rails generate scaffold Observation obs_date_desc:text condition:string hours_until_next_lowtide:float condition_code:integer wind_mph:float wind_gust_mph:float temp:float wind_chill:float next_low_tide:datetime weather_score:integer tide_score:integer observed:boolean go_funston:integer

Observation.create!(condition_code: 0, temp: 70, wind_chill: 0, wind_mph: 2, wind_gust_mph: 2, go_funston: 1)
Observation.create!(condition_code: 0, temp: 60, wind_chill: 0, wind_mph: 5, wind_gust_mph: 5, go_funston: 1)
Observation.create!(condition_code: 0, temp: 55, wind_chill: 0, wind_mph: 13, wind_gust_mph: 10, go_funston: 1)
Observation.create!(condition_code: 0, temp: 50, wind_chill: 0, wind_mph: 2, wind_gust_mph: 2, go_funston: 0)
Observation.create!(condition_code: 0, temp: 55, wind_chill: 50, wind_mph: 15, wind_gust_mph: 10, go_funston: 0)
Observation.create!(condition_code: 0, temp: 45, wind_chill: 0, wind_mph: 20, wind_gust_mph: 30, go_funston: -1)
Observation.create!(condition_code: 1, temp: 60, wind_chill: 0, wind_mph: 2, wind_gust_mph: 2, go_funston: 1)
Observation.create!(condition_code: 1, temp: 65, wind_chill: 55, wind_mph: 15, wind_gust_mph: 20, go_funston: 0)
Observation.create!(condition_code: 1, temp: 50, wind_chill: 0, wind_mph: 10, wind_gust_mph: 5, go_funston: 0)
Observation.create!(condition_code: 1, temp: 55, wind_chill: 0, wind_mph: 5, wind_gust_mph: 2, go_funston: 1)
Observation.create!(condition_code: -1, temp: 60, wind_chill: 50, wind_mph: 15, wind_gust_mph: 20, go_funston: -1)
Observation.create!(condition_code: -1, temp: 0, wind_chill: 0, wind_mph: 0, wind_gust_mph: 0, go_funston: -1)
Observation.create!(condition_code: -1, temp: 50, wind_chill: 40, wind_mph: 10, wind_gust_mph: 15, go_funston: -1)