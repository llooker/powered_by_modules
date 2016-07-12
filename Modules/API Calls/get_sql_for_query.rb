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

  	def self.get_sql_for_query(query_slug)
  		sdk = self.api_auth()

  		query_info = sdk.query_for_slug(query_slug)
	    query_id = query_info[:id]

	    return sdk.run_query(query_id, "sql")
  	end
  	
end