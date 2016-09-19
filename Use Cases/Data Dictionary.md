

# Creating a Data Dictionary

### Step 1: Build out LookML Model
Define Fields with descriptions, labels, and other parameters within your LookML Model that you might to pull into your data dictionary.

Step 3:


### Step 2: Use API call to pull in LookML Metadata
Connect to our API and call the following Method (lookML_model_explore) to pull in the appropriate fields that you would want to identify within your Data Dictionary. 
Sample Ruby code can be found in Modules -> API Calls -> Get LookML Metadata


### Step 3:

Format the results from the lookML_model_explore call using custom CSS and HTML. Consider using JS Plugins to allow for Search and Sort functionality to make the dictionary more accessible. In this block, we use the DataTable JS Plugin found [[here]]((https://datatables.net/)).

Examples:
Default Dictionary with Pagination and Sorts

Dictionary filtered to fields that contain the word "lifetime"

