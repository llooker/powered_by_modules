

class DashboardController < ApplicationController
		## Include information on how to adjust this for clients with Access Filter Fields
	def lookML_dashboard
	   	# Pass in the name of the lookML Dashboard
	   	@options = {
			embed_url: "/embed/dashboards/powered_by/supplier_dashboard"
		}

	    @embed_url = Auth::embed_url(@options)
	  	# @embed_url = @embed_url + '&embed_domain=http://localhost:3000'
	end
end



