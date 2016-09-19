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

    looks = []
    all_looks.each do |x| 
      if((x[:user][:id]) == user_id)
        looks << self.get_look_details(x[:id].to_s)
      end
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