# Custom Use Case: Custom Embed Field Picker

### Step 1: Pick a Use Case 
End Users want to visualize a certain number of Metrics (New Users, Total Sale Price) over time for a particular Date Range and for a particular time period and with other filters specified. 

### Step 2: Widgetize Use Case (Toggle Buttons, Drop down selectors, etc) 

Here is an example of a Simple Form (with checkboxes, radio buttons) in ruby. 
```
  <form id="slideout-content" role="form">
    <div class="right-sidebar__checkboxes">
      <label class="right-sidebar__checkbox-label">
        <input class="right-sidebar__checkbox" type="checkbox" name="fields[]" value="users.count">
        <span class="right-sidebar__checkbox-text">Users Count</span>
      </label>
      <label class="right-sidebar__checkbox-label">
        <input class="right-sidebar__checkbox" type="checkbox" name="fields[]" value="order_items.order_count">
        <span class="right-sidebar__checkbox-text">Order Count</span>
      </label>
    </div>
    <div>
        <input class="filter__checkbox filter__checkbox--gender" type="checkbox" name="gender[]" value="Male">
        <input class="filter__checkbox filter__checkbox--gender" type="checkbox" name="gender[]" value="Female">
    </div>
    <div class="right-sidebar__dates-container">
    	<input name="start_range" class="right-sidebar__date" value="2015-01-01" data-provide='datepicker'>
    	<input name="end_range" class="right-sidebar__date"  value="today" data-provide='datepicker'>
    </div>
    <button type="submit" class="right-sidebar__submit-padding right-sidebar__submit btn">Submit</button>
    </form>
```

### Step 3: Grab Input from form, Generate query, Grab the Query Slug

On a form submit (post or get request), grab the values from the form and start to generate an embedded Query. 
Once a query has been generated, make an API call to get the shortened version of the Query - the Query SLUG. 

Sample Default URL - 
embed_url: "embed/query/powered_by/order_items?qid=<my_query_id>"


```
class QueryController < ApplicationController

def create_query
    @fields = params[:fields] #input from form
    @gender = params[:gender] #input from form

    #Looker API Call
    query = {
      :model=>"powered_by",
      :view=>"order_items",
      #:fields=>["order_items.created_month", "users.count","inventory_items.total_cost"],
      :fields => @fields, 
      :filters=>{
      	:"products.brand"=> "Calvin Klein", 
      	:"order_items.created_month"=> "after 2015/01/01", 
	:"users.gender"=>@gender},
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

      # User Permissions
      permissions:        ['see_user_dashboards', 'see_lookml_dashboards', 'access_data', 'see_looks', 'download_with_limit', 'explore'], 
      models:             ['powered_by'], #replace with name of your model
      user_attributes:    {"company" => "Calvin Klein", "user_time_zone" => "America/New York"}, #Row level data permisisons per user and other user specific attributes.
      group_ids:          [9],
      external_group_id:  "Calvin Klein",  #Used to create a group space for all users of this brand. 
      
    }.merge(additional_data)


    url = Auth::created_signed_embed_url(url_data)

    embed_url = "https://#{url}"

  end


  def self.created_signed_embed_url(options)
    puts options.to_json
    # looker options
    secret = options[:secret]
    host = options[:host]

    # user options
    json_external_user_id   = options[:external_user_id].to_json
    json_first_name         = options[:first_name].to_json
    json_last_name          = options[:last_name].to_json
    json_permissions        = options[:permissions].to_json
    json_models             = options[:models].to_json
    json_group_ids          = options[:group_ids].to_json
    json_external_group_id  = options[:external_group_id].to_json
    json_user_attributes    = options[:user_attributes].to_json
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

    # optionally add settings not supported in older Looker versions
    string_to_sign += json_group_ids        + "\n"  if options[:group_ids]
    string_to_sign += json_external_group_id+ "\n"  if options[:external_group_id]
    string_to_sign += json_user_attributes  + "\n"  if options[:user_attributes]

    string_to_sign += json_access_filters

    signature = Base64.encode64(
                                 OpenSSL::HMAC.digest(
                                        OpenSSL::Digest.new('sha1'),
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
    # add optional parts as appropriate
    query_params[:group_ids] = json_group_ids if options[:group_ids]
    query_params[:external_group_id] = json_external_group_id if options[:external_group_id]
    query_params[:user_attributes] = json_user_attributes if options[:user_attributes]
    query_params[:user_timezone] = options[:user_timezone].to_json if options.has_key?(:user_timezone)

    query_string = URI.encode_www_form(query_params)

    "#{host}#{embed_path}?#{query_string}"
  end

end
```


### Display Authenticated URL 

```
My Embedded URL: <%= @embed_url %> <br/>

  <%= tag(:iframe, 
      src: @embed_url,
      height: 700,
      width: "100%", 
      allowtransparency: 'true')
  %>
```

