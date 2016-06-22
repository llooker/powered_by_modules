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

  def self.get_looks_by_user(user_id)
    sdk = self.api_auth()

        all_looks = sdk.all_looks(:fields => 'id, user').to_a

        looks_for_user = []
        all_looks.each do |x| 
          if((x[:user][:id]) == user_id)
            looks_for_user << x[:id].to_s
            self.get_look_details(x[:id])
          end
        end

        return looks_for_user
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
    #puts "Full Embed URL: " + query_url + "\n" 
          

    #To get user information, make a call to the USER API method based on the user ID of the Look
    user = sdk.user(look[:user][:id])
    created_user_name = user[:first_name] + " " + user[:last_name]
      puts "Created User: " + created_user_name + "\n"
          
  end

end