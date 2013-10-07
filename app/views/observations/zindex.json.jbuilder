json.array!(@observations) do |observation|
  json.extract! observation, 
  json.url observation_url(observation, format: :json)
end
