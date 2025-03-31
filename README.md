# Parallel Data Aggregation and Email Notification using Scatter-Gather

This example showcases the use of the scatter-gather control flow to concurrently process and aggregate data from multiple sources, transforming it into a unified JSON structure, and subsequently delivering the result via email using the Google Gmail connector.

**Data Sources:**

The example utilizes two CSV files, `contacts_1.csv` and `contacts_2.csv`, located in the `resources` directory, as input data sources. Each CSV file represents contact information with the following structure:

| Resource        | First Name | Last Name | Phone       | Email                     |
|-----------------|------------|-----------|-------------|---------------------------|
| `contacts_1.csv`| John       | Doe       | 096548763   | john.doe@texasComp.com    |
| `contacts_2.csv`| Jane       | Doe       | 091558780   | jane.doe@texasComp.com    |

**Contact JSON example:**

```json
{
  "firstName": "John",
  "lastName": "Doe",
  "phone": "096548763",
  "email": "john.doe@texasComp.com"
}
```

**Processing Flow:**

1.  **Parallel Data Retrieval:** The scatter-gather component initiates parallel processing of `contacts_1.csv` and `contacts_2.csv`.
2.  **Data Transformation:** Each CSV resource is independently processed, extracting the contact information.
3.  **Aggregation:** The extracted contact data from both resources is aggregated into a single JSON array, where each element represents a contact.
4.  **Email Notification:** The aggregated JSON data is then formatted and sent as an email using the Google Gmail connector.

**API Endpoint:**

The functionality is exposed as a RESTful API endpoint, accessible via an HTTP GET request.

**Request:**

```
GET http://localhost:9090/api/contacts
```

**Response:**

```json
[
  {
    "firstName": "John",
    "lastName": "Doe",
    "phone": "096548763",
    "email": "john.doe@texasComp.com"
  },
  {
    "firstName": "Jane",
    "lastName": "Doe",
    "phone": "091558780",
    "email": "jane.doe@texasComp.com"
  }
]
```

The API will trigger the scatter-gather flow, resulting in an email being sent containing the aggregated contact information in JSON format. 

The email will contain a JSON object, similar to this:

```json
{
  "contacts": [
    {
      "firstName": "John",
      "lastName": "Doe",
      "phone": "096548763",
      "email": "john.doe@texasComp.com"
    },
    {
      "firstName": "Jane",
      "lastName": "Doe",
      "phone": "091558780",
      "email": "jane.doe@texasComp.com"
    }
  ]
}
```