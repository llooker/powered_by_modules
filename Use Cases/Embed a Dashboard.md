
# Embedding: Embed a Dashboard


You can embed a looker visualization (whether its a dashboard, look, query, or explore page) on any webpage as an Iframe. 

In this example we walk through embedding an dashboard. 


### Step 1: Create a Dashboard
With in the Looker Application, create a dashboard that you would like to make publicly available on an external webpage. 


### Step 2: Generate Embed URL 

Note the ID of the dashboard from the URL

Example Embed URL: 
embed_url = "https://instancename.looker.com/dashboard/<your_dashboard_id>"



### Step 3: Authenticate Embed URL 

Gather all the parameters that are required to authenticate a dashboard. 
1. User Specific Parameters: First Name, Last Name, External User ID, Permissions, Models, Access Filter Fields
2. System Wide Parameters: Host, Secret, Session Length, Force Login Logout

Using the following snippet of code, pass in the parameters above and create a signed embedded URL that can be accessed via Iframe. 

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

    embed_url = "https://#{url}"

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

### Step 4: Display embeded URL
Display the embedded URL on a webpage as an Iframe

My Embedded URL: <%= embed_url %> 
<br/>

```
<%= tag(:iframe, src: embed_url,
                 height: 700,
                 width: "100%", 
                 allowtransparency: 'true')
%>
```


### Extending this Example 

1. Embed a Dashboard
2. Embed a Look
3. Embed a Query
4. Embed a Explore Page
