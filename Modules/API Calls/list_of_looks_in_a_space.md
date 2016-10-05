**Input Parameters**: 
* `space_id` to specify the Space (user or shared) where the list of Looks will be retrieved


**Resulting Action**: Returns an array of Looks created in a Space with additional Metadata about each Look. 

		

```
require 'looker-sdk'

module ApplicationHelper

	def self.api_auth
    sdk = LookerSDK::Client.new(
      # Looker/API Credentials
      :client_id => ENV['API_CLIENT_ID'],
	    :client_secret => ENV['API_SECRET'],
	    :api_endpoint => ENV['API_ENDPOINT'],
	    :connection_options => {:ssl => {:verify => false}}
    )
    return sdk
	end

  def self.get_looks_in_space(space_id)
    sdk = self.api_auth()

    # Specify Additional Searches/Filters within the Space Call (i.e. Only return the looks associated with a space)
    fields ={:fields=> 'looks'}
    looks = sdk.space(space_id, fields)

    # Convert String to Array in order to manipulate String values
    looks_in_space = looks[:looks].to_a

    looks = []

    # For every Look in the Space grab certain details about the Look --  
    looks_in_space.each do |x| 
      looks << get_look_details(x[:id])
    end

    return looks
  end

  def self.get_look_details(look_id)

    sdk = api_auth()
    look = sdk.look(look_id)      

    puts "\n" + "Look Information - " + "\n"
    puts "ID: " + look[:id].to_s + "\n"
    puts "Title: " + look[:title].to_s + "\n"
    puts "Description: " + look[:description].to_s + "\n"


    #To get the Full Query URL for a look, make a call to the Look API method based on the Look ID
    look_url = look['url'].split('?', 2).last
    query_url ="/embed/query/powered_by/order_items?#{look_url}"

    #To get user information, make a call to the USER API method based on the user ID of the Look
    user = sdk.user(look[:user][:id])
    created_user_name = user[:first_name] + " " + user[:last_name]
    puts "Created User: " + created_user_name + "\n"

    #Return all valid information about the Look
    return Look.new(look[:id].to_s, look[:title].to_s, look[:description].to_s, query_url, created_user_name)
  end

end




class Look
  attr_accessor :look_id, :title, :description, :query_url, :created_user_name

  def initialize(look_id, title, description, query_url, created_user_name)
    @look_id = look_id
    @title = title
    @description = description
    @query_url = query_url
    @created_user_name = created_user_name
  end
end
```
	
Please reach out to a Looker Analyst for any questions and / or assistance implementing.
