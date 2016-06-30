
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

	def self.get_query_slug(query)
		sdk = api_auth()

		# Constructing a Query: 
		# Pass in the necessary model name and field names in order to construct the query. 
		# If Query slug will be used to display an Iframe - Authentication will automatically incorporate in the appropriate access filter fields. 
		
		# query = {
		# 	:model=>"powered_by",
		# 	:view=>"order_items",
		# 	:fields=>
		# 	["order_items.id", "orders.created_date", "products.item_name", "products.category", "order_items.sale_price"],
		# 	:filters=>{:"products.brand"=> "Allegra K"},
		# 	:sorts=>["orders.created_date desc 0"],
		# 	:limit=>"10",
		# 	:query_timezone=>"America/Los_Angeles"
		# }

      	query_detail = sdk.create_query(query)
      	query_id = query_detail[:id]
      	query_slug = query_detail[:slug]

		return query_slug
	end

end


