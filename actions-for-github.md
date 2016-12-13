## Welcome!
This document will walk you through implementing Looker Actions and GitHub. We've outlined 4 use cases here, but the code below can be adapted and expanded to any number of additional use cases. Briefly, the Looker Actions system works by sending row-level query results out of Looker in a way that can be processed by other systems. Because those results leave Looker in a structured format, and most tools that you'd want to integrate those results into expect information to be in any number of specific formats, an intermediary server is often required to accept the results from Looker and transform them for the application that will ultimately receive them. Once you've implemented the server and the integrated Looker and Github to it, adding additional use cases to suit your company's needs is simple incremental work. Read on to see how we've set up this integration.

### Use Cases Covered Here
- Creating a new Issue
- Commenting on an Issue
- Labeling an Issue
- Closing or re-opening an existing Issue 
- Assigning an Issue

### Implementation Notes
- This is example code! While lots of the pieces will work right out of the box, this code snippet requires you to input your own pieces of information specific to your GitHub repository and your Looker instance. An engineer who knows their way around this sort of code should implement it.
- We're using Sinatra to set up a server here, but you can adapt the implementation to use the tools of your own choosing.
- We're relying on Oktokit ([GitHub's Ruby Wrapper on top of their API](http://octokit.github.io/octokit.rb/)), so you'll need that for this implementation to function.
- Following this implementation, actions will always occur as a single GitHub user. With the addition of User Attributes (a Looker feature that will be released in Looker 4.4), you would be able to allow users’ actions to show up as themselves within GitHub. To extend the existing implementation, any user who wants to be able to use the GitHub actions would need to get their own authentication token and set it on their account in Looker so User Attributes can be aware of it.
- We chose certain fields for this implementation, but you can change the fields to whatever makes the most sense for your workflow. Actions can pass information from other fields that don’t carry the actual action (and don’t necessarily have to be present in the query in Looker). For example, if your table results include `issue_title` but not `issue_id`, you can pull and send `issue_id` in your action anyway.
- Depending on the speed of your ETL, it may take a while to see the results of the action that you’ve performed in Looker. You can circumvent this by 'kicking' the ETL every time you make a change via actions. That option is embedded in this code, but you can also choose to omit it entirely by setting the ETL option to false. At that point, your data will update at its regularly scheduled ETL.
- Finally, all of the code snippets below came from one entire code block. That code block has been broken up to be able to annotate sections effectively, but if you string all pieces together, you will have a complete piece of code that implements a server and all of the actions listed above.

## Implementing Actions for GitHub

### Get Ready
1. Get a certificate to use SSL for this server. ([We suggest the AWS certificate manager](https://aws.amazon.com/certificate-manager/))
2. Get your authorization token from GitHub (github.com/settings/token).
3. Install [Oktokit](http://octokit.github.io/octokit.rb/)

### Configure your Server
The next three sections should run as one code block. They're broken up here for ease of understanding and reading.

```
require 'sinatra'

require 'octokit'
require 'sinatra/base'
require 'webrick'
require 'webrick/https'
require 'openssl'
require 'json'


REPO_NAME = '[filepath to your repo goes here]'
CERT_PATH = '[file path to your certificate from Basic Step #1]'

# personal access token from github from Basic Step #2
GITHUB_TOKEN = ENV['GITHUB_AUTH_TOKEN'] || 'TOKEN GOES HERE'

# whether or not to perform the ETL / refresh query when action is completed 
# input either true or false
PERFORM_ETL = true | false

webrick_options = {
  :Port               => 8443,
  :Logger             => WEBrick::Log::new($stderr, WEBrick::Log::DEBUG),
  :DocumentRoot       => "/ruby/htdocs",
  :SSLEnable          => true,
  :SSLVerifyClient    => OpenSSL::SSL::VERIFY_NONE,
  :SSLCertificate     => OpenSSL::X509::Certificate.new(  File.open(File.join(CERT_PATH, "looker.self.signed.pem")).read),
  :SSLPrivateKey      => OpenSSL::PKey::RSA.new(          File.open(File.join(CERT_PATH, "looker.self.signed.key")).read),
  :SSLCertName        => [ [ "CN",WEBrick::Utils::getservername ] ]
}

class MyServer  < Sinatra::Base
  set :show_exceptions, false

  def default_client
    Octokit::Client.new(:access_token => GITHUB_TOKEN)
  end

  before '/*' do
    data = JSON.parse(request.body.read, symbolize_names: true)
    @form_params = data[:form_params]
    @data = data[:data]
    
    @client = default_client
  end

# if you selected 'true' for PERFORM_ETL, input your ETL logic in this code block
  def execute_etl
    `[your ETL logic goes here]`
  end

  def reply_success
    execute_etl if PERFORM_ETL

    content_type 'application/json'

    {'looker' => {'success' => true, 'refresh_query' => PERFORM_ETL}}.to_json
  end
```
### Define the Forms you Want Constructed on the Server
Some information is better to pull on the server itself (rather than asking for it in your LookML code). In these examples, we're pulling the unique list of labels available in your  GitHub repo to populate a dropdown in the form, and then passing the entire form through to Looker. If you'd prefer, you can also create forms in the Looker Actions code and not on the server at all. 

```
  # these are the more complex forms that contain extra information from the 
  # github API (such as assignee candidates / possible labels)

  post '/assignee_form.json' do
    assignees = @client.repository_assignees(REPO_NAME)

    data = assignees.map do |user|
      {'name' => user.login, 'label' => user.login}
    end

    [{'name' => 'user', 'required' => 'true', 'type' => 'select'}.merge('options' => data)].to_json
  end

  post '/create_issue_form.json' do
    assignees = @client.repository_assignees(REPO_NAME)

    label_names = default_client.labels(REPO_NAME).map(&:name)

    labels = label_names.map do |label|
      {'name' => label, 'label' => label}
    end

    data = assignees.map do |user|
      {'name' => user.login, 'label' => user.login}
    end

    [
      {'name' => 'title', 'required' => true},
      {'name' => 'body', 'type' => 'textarea'},
      {'name' => 'Assignee', 'type' => 'select'}.merge('options' => data),
      {'name' => 'Label 1', 'type' => 'select'}.merge('options' => labels),
      {'name' => 'Label 2', 'type' => 'select'}.merge('options' => labels),
    ].to_json
o  end

  post '/label_form.json' do
    label_names = default_client.labels(REPO_NAME).map(&:name)

    labels = label_names.map do |label|
      {'name' => label, 'label' => label}
    end

    [{'name' => 'label', 'required' => 'true', 'type' => 'select'}.merge('options' => labels)].to_json
  end
```


### Define the Actions you Want to Perform
You can implement any or all of the following actions. They should also be considered blueprints for other actions you might want to implement.
 
*Create an Issue*
```
  post '/create_issue' do
    title = @form_params[:title]
    body = @form_params[:body]
    assignee = @form_params[:"Assignee"]
    label1 = @form_params[:'Label 1']
    label2 = @form_params[:'Label 2']

    labels = []

    labels.push(label1) if label1
    labels.push(label2) if label2

    @client.create_issue(REPO_NAME, title, body, {
      :assignee => assignee, :labels => labels
    })
    
    reply_success
  end
```
*Add Assignee*
```
  post '/issue/:issue_number/add_assignee' do |issue_number|
    login = @form_params[:user]
    @client.update_issue(REPO_NAME, issue_number, {:assignee => login})
    
    reply_success
  end
 ```
*Toggle Issue State from Opened to Closed*
 
```
  post '/issue/:issue_number/state/:state' do |issue_number, state|
    if state == 'reopen'
      @client.reopen_issue(REPO_NAME, issue_number)
    else
      @client.close_issue(REPO_NAME, issue_number)    
    end
    
    reply_success  
  end
```
*Add a Comment to an Issue*

```
  post '/issue/:issue_number/add_comment' do |issue_number|
    body = @form_params[:comment_body]

    @client.add_comment(REPO_NAME, issue_number, body)

    reply_success
  end
```
*Add a Label to an Issue*

```
  # looker action will request the label form (above) to allow user to pick amongst valid labels
  post '/issue/:issue_number/add_label' do |issue_number|
    label_name = @form_params[:label]
    @client.add_labels_to_an_issue(REPO_NAME, issue_number, [label_name])

    reply_success
  end
```
*Remove a Label from an Issue*
```
  post '/issue/:issue_number/remove_label/:label_name' do |issue_number, label_name|
    @client.remove_label(REPO_NAME, issue_number, label_name)
    
    reply_success
  end
```
### Defining Actions in LookML
The following sections of code will be done in the Looker IDE on the fields that you want to update to include actions. The field that you select will offer the action when you click any value of that field on the Explore page, in a Look, or in a tile on a Dashboard.

 *Create an Issue*
 ```
   dimension: name {
    sql: ${TABLE}.name ;;

    action: {
      label: "Create Issue"
      url: "https://localhost:8443/create_issue"
      form_url: "https://localhost:8443/create_issue_form.json"
    }
  }
  ```
  
  *Add an Assignee to an Issue*
  ``` 
   dimension: assignee {
    # note this here is bad below
    sql: COALESCE(${TABLE}.assignee, 'NONE')  ;;

    action: {
      label: "Add/Update Assignee"
      url: "https://localhost:8443/issue/{{number._value}}/add_assignee"
      form_url: "https://localhost:8443/assignee_form.json"
    }
  }
```
*Toggle Issue Open or Closed*
```
dimension: open {
    type: yesno
    sql: ${TABLE}.state = 'open' ;;

    action: {
      label: "Toggle Open/Closed"
      url: "https://localhost:8443/issue/{{ number._value}}/state/{% if value == 'Yes' %}close{% else %}reopen{% endif %}"
    }
  }
  ```
*Add Comment to an Issue and Add a Label to an Issue*
```
dimension: title {
    description: "This is the name of the issue."
    required_fields: [repo.name, number]
    html: <a href="https://github.com/jonathanswenson/{{ row['repo.name'] }}/issues/{{ row['issue.number'] }}"  target="_blank">{{ value }}</a>
      ;;
    sql: ${TABLE}.title ;;


    action: {
      label: "Add Comment"
      url: "https://localhost:8443/issue/{{number._value}}/add_comment"

      form_param: {
        name: "comment_body"
        required: yes
      }
    }

    action: {
      label: "Add Label"
      url: "https://localhost:8443/issue/{{number._value}}/add_label"
      form_url: "https://localhost:8443/label_form.json"
    }
    ```
