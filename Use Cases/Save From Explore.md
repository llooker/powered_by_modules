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

Modules -> Javascript API -> Client to Server

###Step 4: Run API Call to Save a Look
  Modules -> API Calls -> Create Look (Save Look)
  



