Prerequsites: Have a Embedded Explore Page

###Step 1: Enable Javascript API for Explore iFrame
  Modules -> Javascript API -> Enabling iFrame to Parent Page Communication

###Step 2: Create a Form that takes in User Input 
```
<%= form_tag create_look_path, :id=>'create_look_explore'   do %>
  <div class="form-group">
    <%= text_field_tag :title_of_look%>
  </div>

  <div class="form-group">
  <%= submit_tag %>
  </div>
<% end %>
```

###Step 3: Run API Call to Save a Look

  Modules -> API Calls -> Create Look (Save Look)
  



