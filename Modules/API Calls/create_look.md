text ext txt

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


text text
