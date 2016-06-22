

class DashboardController < ApplicationController
	## Include information on how to adjust this for clients with Access Filter Fields
	def explore
  		@options = {
      		embed_url: "/embed/explore/powered_by/order_items_simple",
      		height: '750',
    	}
    	@embed_url = Auth::embed_url(@options)
	end
end


