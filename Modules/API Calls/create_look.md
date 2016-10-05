**Input Parameters**: 
* `user_id` for permissioning the user
* `query_id` for query selection
* `title` for the title of the Look (i.e. the saved query)
* `space` for the directory or Space where the Look will be saved

**Resulting Action**: A Look is saved in the Looker Instance based on the specified parameters.
		

```
require 'looker-sdk'

module ApplicationHelper

	def self.api_auth
		sdk = LookerSDK::Client.new(
			# Looker/API Credentials
			:client_id => ENV['API_CLIENT_ID'],
			:client_secret => ENV['API_SECRET'],
			:api_endpoint => ENV['API_ENDPOINT'],
			:connection_options => {:ssl => {:verify => false}}
		)
		return sdk
	end

	def self.create_look(query_slug, title)
		sdk = self.api_auth()

	    query_info = sdk.query_for_slug(query_slug)
	    query_id = query_info[:id]

	    #The Required parameters to create a Look are listed below. Additional parameters, such as the User ID, description, etc... can also be specified. 
		body = {
			:user_id => current_user,
			:query_id => query_id,
			:title => title,
			:description => "My Description",
			:space_id => 327,
		}
	    return sdk.create_look(body)
  	end
  	
end
```
		
Please reach out to a Looker Analyst for any questions and / or assistance implementing.
