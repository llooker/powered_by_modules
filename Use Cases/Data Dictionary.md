

# Creating a Data Dictionary

### Step 1: Build out LookML Model
within your LookML Model, define Fields with descriptions, labels, and other parameters that you might to pull into your data dictionary.

### Step 2: Use API call to pull in LookML Metadata
Connect to our API and call the following Method (lookML_model_explore) to pull in the appropriate fields that you would want to identify within your Data Dictionary. 
Sample Ruby code can be found in Modules -> API Calls -> Get LookML Metadata


### Step 3:

Format the results from the lookML_model_explore call using custom CSS and HTML. Consider using JS Plugins to allow for Search and Sort functionality to make the dictionary more accessible. In this block, we use the [DataTable JS Plugin](https://datatables.net/).
