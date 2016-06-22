### FORM/Wigets
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
->

### Grab Input from form, Generate embed parameters, and grab the query slug from the created query

	Modules -> Embed Parameters -> Create Query


### Authenticate with the query slug 

	Modules -> Embed Authentication -> Auth


### Display Authenticated URL 

	<h1>RESULTS </h1>


	My Embedded URL: <%= @embed_url %> 

	<br/>
	<br/>


  	<%= tag(:iframe, src: @embed_url,
                 height: 700,
                 width: "100%", 
                 allowtransparency: 'true')
  	%>

