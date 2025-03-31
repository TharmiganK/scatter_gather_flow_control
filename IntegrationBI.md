# Guide to implement the application in Ballerina Intergrator(BI)

This document provides a comprehensive guide to implementing the application in Ballerina Integrator (BI). The application is designed to aggregate data from multiple sources and send it via email using the Google Gmail connector. The following sections outline the steps to set up and run the application, including prerequisites, configuration, and execution.

## Prerequisites

- Download and install the [Visual Studio Code](https://code.visualstudio.com/download).
- Install the [WSO2 Ballerina Integrator extension](https://marketplace.visualstudio.com/items?itemName=WSO2.ballerina-integrator) for Visual Studio Code.
- Set up Ballerina Integrator for the first time by following the instruction provided when you open the Ballerina Integrator extension in Visual Studio Code. Restart Visual Studio Code after the setup is complete.

## Create a new project

- Click on the Ballerina Integrator icon on the sidebar.
- Click on the Create Integration button.
- Enter the Integration Name as `ScatterGatherFlowControl`.
- Select Project Directory by clicking on the Select Location button.
- Click on the Create Integration button to create the integration project.

## Create an HTTP service

- In the design view, click on the `Add Artifact` button.
- Select `HTTP Service` under the `Integration as API` category.
- Select the `Create and use the default HTTP listener` option from the Listener dropdown.
- Select `Design from Scratch option` as the The contract of the service.
- Specify the Service base path as `/api`.
- Click on the `Create` button to create the new service with the specified configurations.

## Add an HTTP resource

- In the service designer view, remove the default `GET` resource.
- Click on the `+ Resource` to add a `GET` resource.
- Specify the Resource path as `/contacts`.
- Remove the default response and add a new response.
  - Select the `Body` field and from the dropdown, select `+ Add Type`.
    - In the `New Type` window, provide `Contact` as the name.
    - Select `Record` as the kind.
    - Click on `JSON` for fields and provide the following sample JSON in the panel:
        ```json
        {
        "firstname": "John",
        "surname": "Doe",
        "phone": "096548763",
        "email": "john.doe@texasComp.com"
        }
        ```
    - Click on `Import` button and then select `Save` to save the new type.
  - Click on `Add` to add the new response.
- Click on `Save` to save the resource.

## Define the configurables for the Gmail connector

- In the home view, click on the `+ Add Artifact` button.
- Select `Configuration` from the `Other Artifacts` category.
- Click on `+ Add Configurable Variable` to add the following configurable variables one by one.
  | Varaible | Type |
  |----------|------|
  |`gmailRecipient`| `string`|
  |`gmailClientSecret`| `string`|
  |`gmailClientId`| `string`|
  |`gmailRefreshToken`| `string`|

## Implement the integration logic

- In the service designer view, click on the newly created `GET` resource.
- Add a `Fork` node to the canvas. (This node is located under `Concurreny` category)
  - Keep the default options (which creates two workers) and click on `Save`.
- Add a `Call Function` node to the first worker of the `Fork` node.
  - Search for `csv` and select `io:fileReadCsv` function.
  - Give `contacts` as the variable name.
  - Give `Contact` as the return type.
  - Give `./resources/contacts_1.csv` as the file path.
  - Click on `Save` to save the node.
- Do the same for the second worker of the `Fork` node, but this time give `./resources/contacts_2.csv` as the file path.
- Click on the `Wait` node and change the variable type as `map<Contact[]|error>`.
- Add `Declare variable` node to store the contacts from the worker 1.
  - Give `contacts1` as the variable name.
  - Select `Contact[]` as the type.
  - Provide the following as the expression: `check waitResult.get("worker1")`
- Similarly, add another `Declare variable` node to store the contacts from the worker 2.
  - Give `contacts2` as the variable name.
  - Select `Contact[]` as the type.
  - Provide the following as the expression: `check waitResult.get("worker2")`
- Add a `Declare variable` node to store the aggregated contacts.
  - Give `allContacts` as the variable name.
  - Select `Contact[]` as the type.
  - Provide the following as the expression: `[...contacts1, ...contacts2]`
- Add a `Call Function` node to generate the prettified JSON.
  - Search for `json` and select `jsondata:prettify` function.
  - Give `gmailBody` as the variable name.
  - Give `{contracts: allContacts}` as the value.
- Click on the flow to add a new node, and select `Add Connection`.
  - Search for `Gmail` and select `Gmail Client`.
    - Click on the `Config` field and using the `Construct Record` in the `Expression Helper`, selct the `ConnectionConfig` and slect `OAuth2RefreshTokenGrantConfig` as the type for `auth` field.
    - Provide the configurable values to the corresponding fields.
- Click on the flow to call the created Gmail client.
  - Select `Sends the specified message to the recipients` function.
  - Provide the variable name as `gmailMessage`.
  - Provide `"me"` for the `UserId` field.
  - Click on the `Payload` tab and using the `Expression Helper` construct the `MessageRequest` record with the following fields
    - `to`
    - `subject`
    - `body`
   - Provide the following values for the fields:
     - `to`: `gmailRecipient`
     - `subject`: `"Contacts List"`
     - `body`: `gmailBody`
- Add a `Return` node to return the `allContacts` variable.

**Note:** There will be an error in the worker nodes since they are not configured to return the expected types. Switch to Pro-Code review and add the following `returns` statement for both workers: `returns Contact[]|error`.
