Prerequsites: Have a Embedded Explore Page

###Step 1: Enable Javascript API for Explore iFrame
  Modules -> Javascript API -> Enabling iFrame to Parent Page Communication

###Step 2: Create a Form that takes in User Input 
```
<form action="/create_look" id="create_look_explore" method="post">
	<div class="form-inline text-right">
		<input class="form-control" id="title_of_look" name="title_of_look" placeholder="Enter a Unique Title" type="text" value="" />
		<input class="btn btn-default" name="commit" type="submit" value="Save Report" />
	</div>
</form>
```

###Step 3: Pass form submission input to the server
Pass Client information (iFrame events/Form Fills) to the server via Javascript/Ajax Calls

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

###Step 4: Run API Call to Save a Look

[Create (Save) Look](https://github.com/llooker/powered_by_modules/blob/master/Modules/API%20Calls/create_look.md)
  



