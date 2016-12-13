## Welcome!
This document will walk you through implementing Looker Actions and Salesforce. We've outlined two use cases here, but the code below can be adapted and expanded to any number of additional use cases. 

Briefly, the Looker Actions system works by sending row-level query results out of Looker in a way that can be processed by other systems. Because those results leave Looker in a structured format, and most tools that you'd want to integrate those results into expect information to be in any number of specific formats, an intermediary server is often required to accept the results from Looker and transform them for the application that will ultimately receive them. 

Once you've implemented the server and the integrated Looker and Salesforce to it, adding additional use cases to suit your company's needs is simple incremental work. Read on to see how we've set up this integration.

### Use Cases Covered Here
- Updating the Annual Contract Value (ACV) on an open Opportunity
- Changing the Stage of an Opportunity

### Implementation Notes
- **This is example code!** While lots of the pieces will work right out of the box, this code snippet requires you to input your own pieces of information specific to your Salesforce instance and your Looker instance. An engineer who knows their way around this sort of code should implement it.
- **We're relying on Salesforce's node page, [jsforce](https://jsforce.github.io/), in concert with [node.js](https://nodejs.org/en/).** We actually strongly recommend this setup. Ruby has a different package that we tried - don’t use that! It doesn't work well because it only lets you query their RESTful API. This implementation requires being able to write to Salesforce's SOAP API.
- Following this implementation, **actions will always occur as a single, hard-coded Salesforce user**. With the addition of User Attributes (a Looker feature that will be released in Looker 4.4), you will be able to allow users’ actions to show up as themselves within Salesforce. This is relevant because this implementation only allows the owner of an Opportunity to be able to update it. Therefore, you need each user's credentials to be set to allow them to update their own Oppportunities.
- We chose certain fields for this implementation, but **you can change the fields to whatever makes the most sense for your workflow**. Actions can pass information from other fields that don’t carry the actual action (and don’t necessarily have to be present in the query in Looker). For example, if your table results include `opportunity.name` but not `opportunity.id`, you can pull and send `opportunity.id` in your action anyway.
- Finally, **all of the code snippets below came from one entire code block**. That code block has been broken up to be able to annotate sections effectively, but if you string all pieces together, you will have a complete piece of code that implements a server and all of the actions listed above.
- Seeing updated results in Looker depend on your ETL for Salesforce data. The information should be updated in Salesforce as soon as the Action is complete.

## Implementing Actions for Salesforce

### Get Ready
1. Get a certificate to use SSL for this server. ([We suggest the AWS certificate manager](https://aws.amazon.com/certificate-manager/))
2. Create a [Connected App](https://developer.salesforce.com/page/Connected_Apps) in SFDC - you'll need a consumer key from that setup process.
3. Download Salesforce's node package, ([jsforce](https://jsforce.github.io/). 
4. Ensure you're using [node.js](https://nodejs.org/en/). 

### Provide all Basic Information and Set up a Server
This is where you'll input the information specific to your Salesforce instance, the Connected App you created, and your Looker instance.
```
// Constants
var SANDBOX_HOST = "path to your salesforce host"
// Get these from creating a connected app in Salesforce
var CONSUMER_KEY = "your consumer key"
var CONSUMER_SECRET = "your consumer secret"
var SECURITY_TOKEN = "your security token"
// Your username and password for Salesforce
var USERNAME = "username"
var PASSWORD = "password"
// used as certs for local https development
var CERT_PATH = 'path/to/your/ssl/cert'

var fs = require('fs')
var privateKey = fs.readFileSync(CERT_PATH + "/localhost.key", 'utf8')
var certificate = fs.readFileSync(CERT_PATH + "/localhost.crt", 'utf8')
var http = require('http')
var https = require('https')
var express = require('express')
// Important, the Salesforce node package
var jsforce = require('jsforce')
var bodyParser = require('body-parser')

var app = express()
var port = 3000

// Setup json form encoding (used to parse form data from Looker)
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({
  extended: true
}));
// Setup HTTPS server
var credentials = {key: privateKey, cert: certificate};
var httpsServer = https.createServer(credentials, app);
httpsServer.listen(8443);

var userId = '';
// Connect to Salesforce using JSForce...
var sf_conn = new jsforce.Connection({
  loginUrl: SANDBOX_HOST
});
sf_conn.login(USERNAME, PASSWORD, (err, res) => {
  if (err) {
    return console.log("Error logging in", err)
  }
  console.log("Token: " + sf_conn.accessToken);
  console.log(res);
  userId = res.id;
});
```
### Define your Actions
These are two examples of available actions, including error and permission checking.

*Update ACV*
```
app.post('/update_acv', (req, res) => {
  // Parse form fields
  var opportunity_id = req.body.data.id;
  var update_value = req.body.form_params.update_value;
  // Check if value is valid number
  if (isNaN(parseInt(update_value))) {
    console.log("Update value is not a number.");
    res.send(formResponseJson(false, "Please enter a valid number", false));
  } else {
    // Check if user making the update is the owner of the opportunity,
    // otherwise, we can't update the field in Salesforce.
    sf_conn.sobject("Opportunity").retrieve(opportunity_id, (err, opportunity) => {
      if (err) {
        return console.error(err);
      }
      if (opportunity.OwnerId !== userId) {
        res.send(formResponseJson(false, "You don't have permission to update this field.", false));
      } else {
        sf_conn.sobject("Opportunity").update({
            Id : opportunity_id,
            Amount : update_value
          }, (err, query) => {
            if (err || !query.success) {
              console.log("Query failed: " + err);
              res.send(formResponseJson(query.success, "Error.", false));
            } else {
              res.send(formResponseJson(true, "", true));
            }
        });
      }
    });
  }
});
```
*Update Status*

```
app.post('/update_status', (req, res) => {
  var opportunity_id = req.body.data.id;
  var update_value = req.body.form_params.status;
  sf_conn.sobject("Opportunity").retrieve(opportunity_id, (err, opportunity) => {
    if (err) {
      return console.error(err);
    }
    if (opportunity.OwnerId !== userId) {
      console.log("OwnerId !== UserId");
      res.send(formResponseJson(false, "You don't have permission to update this field.", false));
    } else {
      sf_conn.sobject("Opportunity").update({
          Id : opportunity_id,
          StageName : update_value
        }, (err, query) => {
          if (err || !query.success) {
            console.log("Query failed: " + err);
            res.send(formResponseJson(query.success, "Error.", false));
          } else {
            res.send(formResponseJson(true, "", true));
          }
      });
    }
  });
});

app.listen(port, (err) => {
  if (err) {
    return console.log('Error starting server', err)
  }
  console.log(`Server listening on port ${port}`);
});

var formResponseJson = function(isSuccess, validationError, refreshQuery) {
  var response = {
    "looker": {
      "success": isSuccess,
```
### Define the Actions in LookML

*Update ACV*
```
dimension: amount {
    required_fields: [id]
    action: {
      label: "Update ACV"
      url: "https://localhost:8443/update_acv"
      param: {
        name: "id"
        value: "{{ row['opportunities.id'] }}"
      }
      param: {
        name: "Content-Type"
        value: "application/x-www-form-urlencoded"
      }
      form_param: {
        name: "update_value"
        type: string
      }
    }
    type: number
    sql: ${TABLE}.amount ;;
  }
  ```

```
dimension: status {
    required_fields: [id]
    action: {
      label: "Update Status"
      url: "https://localhost:8443/update_status"
      param: {
        name: "id"
        value: "{{ row['opportunities.id'] }}"
      }
      param: {
        name: "Content-Type"
        value: "application/x-www-form-urlencoded"
      }
      form_param: {
        name: "status"
        type: select
        default: "{{ row['opportunities.status'] }}"
        option: {
          name: "Active Lead"
          label: "Active Lead"
        }
        option: {
          name: "Qualified Prospect"
          label: "Qualified Prospect"
        }
        option: {
          name: "Trial Requested"
          label: "Trial Requested"
        }
        option: {
          name: "Trial"
          label: "Trial"
        }
        option: {
          name: "Trial - In progress, positive"
          label: "Trial - In progress, positive"
        }
        option: {
          name: "Proposal"
          label: "Proposal"
        }
        option: {
          name: "Negotiation"
          label: "Negotiation"
        }
        option: {
          name: "Commit- Not Won"
          label: "Commit- Not Won"
        }
        option: {
          name: "Closed Won"
          label: "Closed Won"
        }
        option: {
          name: "Closed Lost"
          label: "Closed Lost"
        }
      }
    }
    type: string
    sql: ${TABLE}.status ;;
  }
  ```
