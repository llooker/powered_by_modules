
# Custom Use Case: Custom Embed Field Picker

### Step 1: Pick a Use Case 
Ex: End Users want to visualize a certain number of Metrics (New Users, Total Sale Price) over time for a particular Date Range and for a particular time period and with other filters specified. 

### Step 2: Widgetize Use Case (Toggle Buttons, Drop down selectors, etc) 

Here is an example of a Simple Form (with checkboxes, radio buttons) in ruby. 
```
<%= form_tag("/dashboard/supplier_dashboard", method: "get") do %>
	
	<p>
	<div class="form-group">
		<%= label_tag(:gender, "Enter a Gender: ") %>
		<!-- radio_button_tag 'gender', 'male' -->
		<%= radio_button_tag "gender", "Male" %> Male
		<%= radio_button_tag "gender", "Female" %> Female
		<%= radio_button_tag "gender", "" %> Both
	<end>

	<p>

	<div class="form-group">
		<%= label_tag(:fields, "Select Your Fields: ") %> <br/>
        <% my_fields = [
          ["users.count", "Users Count"], 
          ["order_items.order_count", "Order Count"], 
          ["order_items.count", "Order Items Count"], 
          ["inventory_items.total_cost", "Total Cost"], 
          ["order_items.total_sale_price", "Total Sale Price"],
          ["order_items.total_gross_margin", "Total Gross Margin"], 
          ["order_items.average_sale_price", "Average Sale Price"], 
          ["order_items.average_gross_margin", "Average Gross Margin"], 
        ]
        %>

        <% my_fields.each do |x| %>
          <%= check_box_tag 'fields[]', x[0] %>
          <%= label_tag 'order_items_count',x[1],for: "fields_", class: 'checkbox-custom-label' %> 
           <br/>
        <% end %>
	<end>
	<br/>
	  <%= submit_tag("Search") %>
	<br/>
<% end %>
```

### Step 3: Grab Input from form, Generate query, Grab the Query Slug

On a form submit (post or get request), grab the values from the form and start to generate an embedded Query. 
Once a query has been generated, make an API call to get the shortened version of the Query - the Query SLUG. 

Sample Default URL: /embed/query/embed/order_items?slug=XXXYYY


```

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
```



### Authenticate with the query slug 

```
require 'cgi'
require 'securerandom'
require 'uri'
require 'base64'
require 'json'
require 'openssl'


class Auth < ActiveRecord::Base

  def self.embed_url(additional_data = {})

    url_data = {
      # System Level Permissions        
      host:               ENV['LOOKER_HOST'], # ex: [mylooker_instance.looker.com] (include port # if self hosted)
      secret:             ENV['EMBED_SECRET'], # Secret Key 
      session_length:     30.minutes,
      force_logout_login: true,

      # User Specific Permissions
      external_user_id:   102, #The External ID must be a Number and must be unique for every embedded User (Primary Key). 
      first_name:         "Dr",
      last_name:          "Strange",
      permissions:        ['see_user_dashboards', 'see_lookml_dashboards', 'access_data', 'see_looks', 'download_with_limit', 'explore'],
      models:             ['powered_by'],
      access_filters:     {:powered_by => {:'products.brand' => "Allegra K"}},
    }.merge(additional_data)

    url = Auth::created_signed_embed_url(url_data)

    "https://#{url}"

  end


  def self.created_signed_embed_url(options)
    # looker options
    secret = options[:secret]
    host = options[:host]

    # user options
    json_external_user_id   = options[:external_user_id].to_json
    json_first_name         = options[:first_name].to_json
    json_last_name          = options[:last_name].to_json
    json_permissions        = options[:permissions].to_json
    json_models             = options[:models].to_json
    json_access_filters     = options[:access_filters].to_json

    # url/session specific options
    embed_path              = '/login/embed/' + CGI.escape(options[:embed_url])
    json_session_length     = options[:session_length].to_json
    json_force_logout_login = options[:force_logout_login].to_json

    # computed options
    json_time               = Time.now.to_i.to_json
    json_nonce              = SecureRandom.hex(16).to_json

    # compute signature
    string_to_sign  = ""
    string_to_sign += host                  + "\n"
    string_to_sign += embed_path            + "\n"
    string_to_sign += json_nonce            + "\n"
    string_to_sign += json_time             + "\n"
    string_to_sign += json_session_length   + "\n"
    string_to_sign += json_external_user_id + "\n"
    string_to_sign += json_permissions      + "\n"
    string_to_sign += json_models           + "\n"
    string_to_sign += json_access_filters

    signature = Base64.encode64(
                   OpenSSL::HMAC.digest(
                      OpenSSL::Digest::Digest.new('sha1'),
                      secret,
                      string_to_sign.force_encoding("utf-8"))).strip

    # construct query string
    query_params = {
      nonce:               json_nonce,
      time:                json_time,
      session_length:      json_session_length,
      external_user_id:    json_external_user_id,
      permissions:         json_permissions,
      models:              json_models,
      access_filters:      json_access_filters,
      first_name:          json_first_name,
      last_name:           json_last_name,
      force_logout_login:  json_force_logout_login,
      signature:           signature
    }
    query_string = query_params.to_a.map { |key, val| "#{key}=#{CGI.escape(val)}" }.join('&')

    "#{host}#{embed_path}?#{query_string}"
  end

end
```


### Display Authenticated URL 

```
	My Embedded URL: <%= @embed_url %> 
	<br/>
  <%= tag(:iframe, src: @embed_url,
                 height: 700,
                 width: "100%", 
                 allowtransparency: 'true')
  %>
```

