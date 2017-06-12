
# Embedding: Embed a Looker Explore Page

You can embed a looker explore page, much like you would embed a dashboard. 

To embed a looker explore page follow the [Embed a Dashboard](https://discourse.looker.com/t/javascript-embedded-iframe-events/2298 "Embedding") Use Case and add in the appropriate embed_url. 

Default Explore Page-- embed_url: "/embed/explore/<model_name>/<explore_name>?qid="<my_query_id>"
Explore Page with pre-built Query-- embed_url: "/embed/explore/<model_name>/<explore_name>?qid="<my_query_id>"


### Enabling iFrame to Parent Page Communication
Capture Events from an Embedded Explore Page by adding Javascript. 

Our Javascript API allows you to keep track of interactions with the iframe. [Javascript Events - Looker Documentation](https://discourse.looker.com/t/javascript-embedded-iframe-events/2298 "JS Events")

```
window.addEventListener("message", function (event) {
  if (event.source === document.getElementById("looker_iframe").contentWindow){
    MyApp.blob = JSON.parse(event.data); 
    console.log(MyApp.blob);
  }
});
```

A sample response might look like the following.

<<INSERT IMAGE>>


### Add State to an Embedded Explore Page

Once you capture JS events from an embedded explore page, you can allow for navigation between those actions by passing in the qid (query_id) from every event. By adding "history.pushState", your URL can record different events in the iframe and allow users to click the back button on your browser to toggle to the previous state of the iframe. 

```
var MyApp = {};
window.addEventListener("message", function (event) {
	if (event.source === document.getElementById("looker_iframe").contentWindow)
	{
		MyApp.blob = JSON.parse(event.data); 
		console.log(MyApp.blob);

		if (typeof MyApp.blob.explore != "undefined") {
			MyApp.event_URL = MyApp.blob.explore.url;
			const [start, qid] = MyApp.event_URL.split('qid=');
			history.pushState(qid, "explore_page", "?qid="+qid);
		}
	}
});
```

On every action within the iFrame your URL will now get updated with the qid allowing you to navigate between actions.


### Retrieve SQL from Explore iFrame

With Javascript events enabled, you can capture the state of the iFrame and make additional requests to Looker through the API to get access to metadata and additional information. One such request could be to get the Looker generated SQL of queries run in the Explore. 


Step 1: Create a Submit button that users can click on to get input 
```
<form>
  	<div class="form-group">
		<button type="submit" class="submit_button">Submit</button>  
	</div>
</form>
```

Step 2: 
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


Step 3: Parse Event URL from Client to get the QID
```
def get_sql
	event_URL = params[:event_URL].to_s

	query_slug = event_URL.match('qid.*?(?=&)').to_s.split('=')[1]
	puts "QID: #{query_slug}"

	response = ApplicationHelper.get_sql_for_query(query_slug)
	data = {:message => "Looker Generated SQL Query for Slug #{query_slug}:  \n #{response}"}
	render :json => data, :status => :ok
end
```


Step 4: Run API Call to Get SQL based on the Query
[Get SQL for Query](https://github.com/llooker/powered_by_modules/blob/master/Modules/API%20Calls/get_sql_for_query.rb)  







