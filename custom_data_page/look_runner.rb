require 'looker-sdk'

module ApplicationHelper


	#Talk about the limitations of running something as a look via the api. No dynamic filtering capability. 
	#Run as a query result instead. (If using access filter fields, this could be a problem)
	def self.get_look_data()
		sdk = api_auth()
      	return sdk.run_look(1273, "jpg")
	end


end