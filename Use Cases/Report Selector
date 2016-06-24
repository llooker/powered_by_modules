# Custom Use Case: Custom Report Selector


Similar to embedding a dashboard, you can embed a look as an Iframe within any web application. 

We can take this a step further and allow the user to dynamically select which look they might want to see on the page. 

Take a particular Space or Project. In our fashion.ly site, we refer to the following customized space within looker. 


### Step 1: API CALL
We can use the API to get a list of all the looks and attributes about that look in a particular space or project. 

API calls (Modules -> API Calls):
Get All Looks In a Space
Get All Looks Created By a User 
Get All Looks in a User Home Space

(Note: The API Calls above can be adjusted to grab dashboards instead of Looks)


These Calls return an array of Looks with the following metadata about each of the looks -- Look ID, Title, Description, Modified Date, Created User

### Step 2: Generate Embed URL 

We could display all the Looks from the API call as selections and Allow the User to visualize this look as a Data Element (Table) or as a Visualization.

On a User Selection (of Look/Type of Look) we grab the form parameters and append the Look ID and type (Data = “&show=data”, Viz = “&show=viz”) to generate the embedded URL. 


Example Embed URL: 
embed_url = "https://instancename.looker.com/looks/<my_look_id>?<&show=data>"



### Step 3: Authenticate Embed URL 

	Modules -> Embed Authentication -> Auth




### Extending this Example 

1. Handle User permissioning on Customer Side
	Ex: You have Basic Users and Premium Users. Basic Users are only shown looks from certain Models (Make a change to the API call to only render Looks from a particular Space and a particular Model). Premium Users get access to all looks in a Space. 
2. Scales in complex ways - you could use this pattern to point the API at different spaces based on the SSO login.  So you could easily design customer tier levels where higher paying customers get access to different levels of reporting

