
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
end



