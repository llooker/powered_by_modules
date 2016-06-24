
## Controller
class DashboardController < ApplicationController
  def user_defined_dashboard
    # Pass in the Dashboard ID for a User Defined Dashboard
      @options = {
        embed_url: "/embed/dashboards/234",
        height: '2247',
      }

      @embed_url = Auth::embed_url(@options)

      # embed_url calls the Authentication Class that generates the full URL with all the parameters that looker requires to authenticate
      # @embed_url = @embed_url + '&embed_domain=http://localhost:3000'
  end

  def user_defined_dashboard_with_filters
    # Pass in the Dashboard ID and Filter Values for a User Defined Dashboard
    # Filters can be customized and defined outside of the Iframe. On Filter submit, pass in filter values to the IFrame to load the new dashboard
      state = params[:state]
      date_range = params[:date_filter]

      @options = {
        embed_url: "/embed/dashboards/234?Date=#{date_range}&State=#{state}",
        height: '2247',
      }

      @embed_url = Auth::embed_url(@options)

      # embed_url calls the Authentication Class that generates the full URL with all the parameters that looker requires to authenticate
      # @embed_url = @embed_url + '&embed_domain=http://localhost:3000'
  end


  
end



