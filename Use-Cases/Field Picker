
# Custom Use Case: Custom Embed Field Picker

### Step 1: Pick a Use Case 
Ex: End Users want to visualize a certain number of Metrics (New Users, Total Sale Price) over time for a particular Date Range and for a particular time period and with other filters specified. 

### Step 2: Widgetize Use Case (Toggle Buttons, Drop down selectors, etc) 

Here is an example of a Simple Form (with checkboxes, radio buttons). 
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

Source Code: Modules -> Embed Parameters -> Create Query 

Sample Default URL: /embed/query/embed/order_items?slug=XXXYYY


### Authenticate with the query slug 

	Modules -> Embed Authentication -> Auth


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

