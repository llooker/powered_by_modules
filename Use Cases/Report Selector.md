# Custom Use Case: Custom Report Selector


Similar to embedding a dashboard, you can embed a look as an Iframe within any web application. 

You can also dynamically select looks from a particular project or space by using the API.  


### Step 1: API CALL
Use the API to get a list of all looks and attributes about that look in a particular space or project. 

#### API calls (Modules -> API Calls):

* [Get All Looks In a Space](https://github.com/llooker/powered_by_modules/blob/master/Modules/API%20Calls/list_of_looks_in_a_space.md)
* [Get All Looks Created By a User](https://github.com/llooker/powered_by_modules/blob/master/Modules/API%20Calls/list_of_looks_created_by_user.md)
* [Get All Looks in a User Space](https://github.com/llooker/powered_by_modules/blob/master/Modules/API%20Calls/get_looks_in_user_space.rb)

(Note: The API Calls above can be adjusted to grab dashboards instead of Looks)

These Calls return an array of Looks with the following metadata about each of the looks -- Look ID, Title, Description, Modified Date, Created User


### Step 2: Generate Embed URL 

We could display all the Looks from the API call as selections and allow the User to visualize this look as a Data Element (Table) or as a Visualization.

On a User Selection (of Look/Type of Look) we grab the form parameters and append the Look ID and type (Data = “&show=data”, Viz = “&show=viz”) to generate the embedded URL. 

Example Embed URL: 
embed_url = "https://instancename.looker.com/looks/<my_look_id>?<&show=data>"



### Step 3: Authenticate Embed URL 

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


### Extend this Example 

1. Handle User permissions on Customer Side <br/>
	Ex: You could have two sets of Users - Basic and Premium. Basic Users can be configured to only show looks from certain Models (Make a change to the API call to only render Looks from a particular Space and a particular Model). Premium Users get access to all looks in a Space. 
2. Scale in complex ways - you could use this pattern to point the API at different spaces based on the permissions of the logged in user.  So you could easily design customer tier levels where higher paying customers get access to different levels of reporting. 


