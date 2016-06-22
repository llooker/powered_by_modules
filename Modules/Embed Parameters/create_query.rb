

class DashboardController < ApplicationController
## Include information on how to adjust this for clients with Access Filter Fields

	def create_query

		@fields = params[:fields]
		@fields = @fields << "order_items.created_month"
		@gender = params[:gender]

		query = {
       		:model=>"powered_by",
       		:view=>"order_items",
       		#:fields=>["order_items.created_month", "users.count","inventory_items.total_cost"],
       		:fields => @fields, 
       		:filters=>{:"products.brand"=> "Allegra K", :"order_items.created_month"=> "after 2015/01/01", :"users.gender"=>@gender},
       		:sorts=>["inventory_items.created_month desc"],
       		:limit=>"100",
       		:query_timezone=>"America/Los_Angeles"
      	}

      	query_slug = ApplicationHelper.get_query_slug(query)

      	@options = {
			##Using the Query Slug --> You can get the Query Slug by grabbing a URL
			embed_url: "/embed/query/powered_by/order_items?query=#{query_slug}"
		}
            
            @embed_url = Auth::embed_url(@options)

	end
end