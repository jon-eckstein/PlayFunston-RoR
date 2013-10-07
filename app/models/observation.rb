class Observation < ActiveRecord::Base

	def tree_values        
		[self.condition_code, self.temp, self.wind_chill, self.wind_mph, self.wind_gust_mph ];        
	end
  
	def condition_code

		if (["Clear", "Partly Cloudy", "Scattered Clouds", "Haze"].include?(self.condition) )
		   return 1
		end
		if (["Mostly Cloudy", "Overcast", "Fog", "Mist"].include?(self.condition))
		   return 0;
		end

		return -1;
	end
  
  
	def wind_text

		if (self.wind_gust_mph > 0) 
	         "#{self.wind_mph} MPH gusting to #{self.wind_gust_mph}  MPH"
		else
	         "#{self.wind_mph} MPH"
		end

	end
  
	def temp_text

		if (self.wind_chill > 0) 
			"#{self.temp} F (feels like #{self.wind_chill} F with wind chill)"
		else 
			"#{	self.temp} F"
		end             

	end

end
