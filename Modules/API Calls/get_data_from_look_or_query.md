***Get Data from a Query (for new queries)***

**Input Parameters**:
* all query variables should be included as input parameters. See inline comments in the code snippet below for an example
	
**Resulting Action**: A query is executed against the database based on the input parameters, and the results of that query are returned.

```
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


	def self.get_query_data(query)

		# Constructing a Query: 
		# Pass in the necessary model name and field names in order to construct the query. 
		# If results from the Query will be displayed in a custom format (non-iframe), Access Filter Field values will need to be added to the Query that is executed. (IF YOU ARE USING ACCESS FILTER FIELDS, you will need to specify the current user's session in the filtered params)

		sdk = api_auth()

		@query = {
			:model=>"powered_by",
			:view=>"order_items",
			:fields=>
			["order_items.id", "orders.created_date", "products.item_name", "products.category", "order_items.sale_price"],
			:filters=>{:"products.brand"=> "Allegra K"},
			:sorts=>["orders.created_date desc 0"],
			:limit=>"10",
			:query_timezone=>"America/Los_Angeles"
	    }
	  	return sdk.run_inline_query("json", query)

	end

end
```
	
***Get Data from a Look (for queries that have already been saved)***

**Input Parameters**:
* `look_id` specifies the Look that results are retrieved from after the query is executed
* `result_format` specifies the format in which the results are returned. See API documentation for the full list of format types.
	
**Resulting Action**: A Look query is executed against the database, and the results of that query are returned.
	
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

	def self.get_look_data(look_id)
		sdk = api_auth()
      		return sdk.run_look(look_id, "jpg")
	end

end
```

Please reach out to a Looker Analyst for any questions and / or assistance implementing.
