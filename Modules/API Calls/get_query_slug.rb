
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

		# IF YOU ARE USING ACCESS FILTER FIELDS, you will need to specify the current user's session in the filtered params
		sdk = api_auth()
		# query = {
	 #       :model=>"powered_by",
	 #       :view=>"order_items",
	 #       :fields=>
	 #        ["order_items.id", "orders.created_date", "products.item_name", "products.category", "order_items.sale_price"],
	 #       :filters=>{:"products.brand"=> "Allegra K"},
	 #       :sorts=>["orders.created_date desc 0"],
	 #       :limit=>"10",
	 #       :query_timezone=>"America/Los_Angeles"
	 #    }
      	query_detail = sdk.create_query(query)
      	query_id = query_detail[:id]
      	query_slug = query_detail[:slug]


		#Saved_Query.create(user_id: "John Doe", query_id: 27)
		return query_slug
	end

end