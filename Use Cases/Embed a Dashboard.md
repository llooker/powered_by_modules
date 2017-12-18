
# Embedding: Embed a Dashboard


You can embed a looker visualization (whether its a dashboard, look, query, or explore page) on any webpage as an Iframe. 

In this example we walk through embedding an dashboard. 


### Step 1: Create a Dashboard
Within Looker, create a dashboard that you would like to make publicly available on an external webpage. 


### Step 2: Generate Embed URL 

Note the ID of the dashboard from the URL

Example Embed URL: 
embed_url = "https://instancename.looker.com/dashboard/<your_dashboard_id>"



### Step 3: Authenticate Embed URL 

Gather all the parameters that are required to authenticate a dashboard. 
1. User Specific Parameters: First Name, Last Name, External User ID, Permissions, Models, User Attributes
2. System Wide Parameters: Host, Secret, Session Length, Force Login Logout

Using the following snippet of code, pass in the parameters above and create a signed embedded URL that can be accessed via iFrame. 

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
      
      embed_url:          "/embed/dashboards/<dashboard_id>"
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

### Step 4: Display Embed URL
Display the embed URL on a webpage as an Iframe

My Embedded URL: <%= embed_url %> 
<br/>

```
<%= tag(:iframe, src: embed_url,
                 id: 'looker_iframe'
                 height: 700,
                 width: "100%", 
                 allowtransparency: 'true')
%>
```

### Capture Events from your Embedded Iframes by adding Javascript 

```
window.addEventListener("message", function (event) {
  if (event.source === document.getElementById("looker_iframe").contentWindow){
    MyApp.blob = JSON.parse(event.data); 
    console.log(MyApp.blob);
  }
});
```
[Javascript Events - Looker Documentation](https://docs.looker.com/reference/embedding/embed-javascript-events "JS Events")

### Create Custom Filters outside the Looker UI 

Create custom filters (checkboxes, radio buttons, maps) outside of the Looker UI in a HTML form element. Pass in filter actions (clicks, etc...) on Submit. Grab filter elements from the form and append to the end of the Dashboard URL. 

```
    @filters = "&Filter1=" + params[:filter1_value].to_s + "&Filter2=" + params[:filter2_value].to_s + "&Filter3=" + params[:filter3_value].to_s
    @iframe_url = current_user.embed_url(
      embed_url: "/embed/dashboards/#{dashboard_id}?embed_domain=#{embed_domain}&#{@filters}",
    )
```

### Extend this Example by

1. Embedding a LookML Dashboard
embed_url = "/embed/dashboards/<name_of_your_model>::<name_of_lookML_dashboard>"

2. Embedding a Look
embed_url = "/embed/looks/<my_look_id>"

3. Embedding a Query
embed_url: "/embed/query/<model_name>/<explore_name>?qid=<my_query_id>"
[Example Use Case with Embedded Query](https://github.com/llooker/powered_by_modules/blob/master/Use%20Cases/Field%20Picker.md "Metrics Selector")

4. Embedding a Explore Page
embed_url = "/embed/explore/<model_name>/<explore_name>"
Add additional permissions for an embedded explore page such as: ['save_content', 'embed_browse_spaces'] to allow users to save and view content within an embed_browse_space. 
[Example Use Case with Embedded Explore](https://github.com/llooker/powered_by_modules/blob/master/Use%20Cases/Embed%20a%20Explore%20Page.md "Metrics Selector")

