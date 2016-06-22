

class DashboardController < ApplicationController
	## Include information on how to adjust this for clients with Access Filter Fields
	def query
		# Pull up a full query by passing in the Query Slug. 
		# The query slug can be found in the URL or through the API
		@options = {
			embed_url: "/embed/query/powered_by/order_items?query=5Yf4DK4"
		}
    	@embed_url = Auth::embed_url(@options)
	end
end


