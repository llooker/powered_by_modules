_*Prerequsites: Have an Embedded Explore Page (see our Embed docs [here](https://looker.com/docs/reference/api-and-integration/api-reference))

###Step 1: Enable Javascript API for Explore iFrame

```
var MyApp = {};

window.addEventListener("message", function (event) {
  if (event.source === document.getElementById("looker_iframe").contentWindow)
   {
    MyApp.blob = JSON.parse(event.data); 
    console.log(MyApp.blob);
  }
});


// callback handler for form submit
$(function(){
  $("#create_look_explore").submit(function(event){
    event.preventDefault();

    // var action = $(this).attr('action');
    // var method = $(this).attr('method');

    MyApp.event_URL = MyApp.blob.explore.url;

    console.log(MyApp.event_URL);
    var title = $(this).find('#title_of_look').val();

    $.ajax({
		method: "post",
		url: "/create_look",
		data: { title: title, event_URL: MyApp.event_URL }, 
		dataType: 'json', 
 
		success: function(data,status,xhr){
			console.log(data.message);
			alert(data.message);
		},
		error: function(xhr,status,error){
			console.log(xhr);
			alert('Enter a Valid Query and a Unique Title \n' + error);
		}
	});

  });
});
```
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

###Step 3: 
Pass Client information (JS events/Form Fills) to the server via Javascript/Ajax Calls 
```
var MyApp = {};

window.addEventListener("message", function (event) {
  if (event.source === document.getElementById("looker_iframe").contentWindow)
   {
    MyApp.blob = JSON.parse(event.data); 
    console.log(MyApp.blob);
  }
});


// callback handler for form submit
$(function(){
  $("#create_look_explore").submit(function(event){
    event.preventDefault();

    // var action = $(this).attr('action');
    // var method = $(this).attr('method');

    MyApp.event_URL = MyApp.blob.explore.url;

    console.log(MyApp.event_URL);
    var title = $(this).find('#title_of_look').val();
    // var data = $(this).serializeArray();

    $.ajax({
		method: "post",
		url: "/create_look",
		data: { title: title, event_URL: MyApp.event_URL }, 
		dataType: 'json', 
 
		success: function(data,status,xhr){
			console.log(data.message);
			alert(data.message);
		},
		error: function(xhr,status,error){
			console.log(xhr);
			alert('Enter a Valid Query and a Unique Title \n' + error);
		}
	});

  });
});

```



###Step 4: Run API Call to Save a Look

[Create (Save) Look](https://github.com/llooker/powered_by_modules/blob/master/Modules/API%20Calls/create_look.md)  



