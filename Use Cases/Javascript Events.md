# Javascript Event Broadcasting 

## Initial Steps
To enable event broadcasting follow the steps below. Detailed instructions can be found on our official docs page <https://docs.looker.com/reference/embedding/embed-javascript-events> 
1. Whitelist your website domain (https://mywebsite.com) on your Looker Admin panel to enable communication
2. Add your website domain to the iFrame HTML source tag <br/>
  Ex: <iframe src="https://my.looker.com/embed/dashboards/1?<b>embed_domain=https://mywebsite.com</b>" />
3. Add an HTML ID tag to your iFrame. This ID will help target iFrames with embedded content from just Looker. 
  Ex: <iframe id="looker_iframe" src="<my_link>" />



## iFrame to Parent Page Communication

### Broadcast and log events

Add in the following Javascript to broadcast clicks and events from an iFrame to the console. Make sure to replace the element_id (looker_iframe) with your ID from step 3 above.

```
window.addEventListener("message", function(event) {
  if (event.source === document.getElementById("looker_iframe").contentWindow) {
    if (event.origin === "https://my.looker.com/") {
      console.log(JSON.parse(event.data));
    }
  }
});
```

<Include GIF> 


### Dynamically generate iFrame Height 

Setting fixed length iframes can lead to multiple scrollbars. Broadcast and update your iFrame height to allow for flexible length embedded content.

```
window.addEventListener('message', function (event) {
  var iframe = document.getElementById('looker_iframe');
  var data;

  if (event.source === iframe.contentWindow) {
    data = JSON.parse(event.data);
    console.log(data);

    if (data.type == 'page:properties:changed') {
      //Dynamically set the iFrame height everytime the page is updated
      iframe.style.height = data.height + 'px';
    } 
  }
});
```
<Include Images + GIF>


### Return Query metadata 

Store user sessions or iframe History on the parent site for different queries run on an explore page.

```
window.addEventListener('message', function (event) {
  var iframe = document.getElementById('looker_iframe');
  var data;

  if (event.source === iframe.contentWindow) {
    data = JSON.parse(event.data);
    console.log(data);
    if (data.type == 'explore:state:changed') {
      var url = new URLSearchParams(data.explore.url);
      var qid = url.get('qid');
      var toggle = url.get('toggle');

      var queryParams = [];
      var queryString = '';

      if (qid) queryParams.push('qid=' + qid);
      if (toggle) queryParams.push('toggle=' + toggle);
      if (queryParams.length > 0) queryString = '?' + queryParams.join('&');

      history.replaceState({}, document.title, window.location.pathname + queryString);
    }
  }
});
```
<Insert GIF>

### Trigger dashboards to be visible on tile loads

```
  $(window).on("message", function (event) {
  if (event.originalEvent.source === $("#looker_iframe")[0].contentWindow) { // confirm message came from Looker
    data = JSON.parse(event.data);
    console.log(data);
      if(data.type == "dashboard:tile:complete"){
          // Check to see if dashboard tiles have finished loading and make the iframe visible 
          jQuery('#container').hide();
          $("#looker").css("visibility", "visible");
          $("#looker").fadeTo("1000", 1);

      };
  }
});
```

```
<div id="container">
  <img src="/Spinner.gif" >
</div>
<iframe 
  style="visibility:hidden;opacity: 0" 
  id = "looker" 
  src="https://demo.looker.com/embed/dashboards/1?&embed_domain=http://localhost:3000" 
  > </iframe>
```


## Parent to iFrame Communication

### Link Custom Filters to Looker iFrames
Pass in user specified custom filter values from the parent page into the iFrame through a client side JS push event (without refreshing the iFrame). 
First, create a custom HTML form. 
```
  <form id="filter_element" role="form">
    <div>
        <input type="checkbox" name="category[]" value="Tops">
        <input type="checkbox" name="category[]" value="Bottoms">
        <input type="checkbox" name="category[]" value="Formal">
        <input type="checkbox" name="category[]" value="Accessories">
    </div>
    <div>
        <input type="checkbox" name="gender[]" value="Male">
        <input type="checkbox" name="gender[]" value="Female">
    </div>
    <div>
    	<input name="start_range">
    	<input name="end_range">
    </div>
    <button type="submit">Submit</button>
    </form>
```
On a filter click or action, the following post event transmits filter information from the parent website into the Looker iFrame to re-update the iFrame with the latest information. 
```
	$('.filter_element').click(function() {
		let Gender = `${checkboxList('gender')}`;
		let Category = `${checkboxList('category')}`;
		let startDate = new Date($('.start_range').val()).toISOString().slice(0,10);
		let endDate = new Date($('.end_range').val()).toISOString().slice(0,10);

	  iframe.contentWindow.postMessage(JSON.stringify({
			type:"dashboard:filters:update",
	 		filters:{
	 			Gender: Gender,
	 			Date: startDate + " to " + endDate,
	 			Category: Category
	 		}
		}),"https://my.looker.com");

		iframe.contentWindow.postMessage(JSON.stringify({
			type: "dashboard:run"
		}),"https://my.looker.com");

	});
```
<insert GIF> 

