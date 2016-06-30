

class DashboardController < ApplicationController

	def look
		# Pass in the Look ID. ID can be found by hovering over a look in the Looker Instance
	   	@options = {
			embed_url: "/embed/looks/1023"
		}
	    @embed_url = Auth::embed_url(@options)
	end


end