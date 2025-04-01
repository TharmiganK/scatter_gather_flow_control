import ballerina/http;

service / on new http:Listener(9090) {
    resource function get api/contacts() returns Contact[]|error {
        worker A returns Contact[]|error {
            return readContactsFromCsv("resources/contacts_1.csv");
        }
        
        worker B returns Contact[]|error {
            return readContactsFromCsv("resources/contacts_2.csv");
        }

        map<Contact[]|error|Contact[]|error> mapResult = wait {A, B};
        
        Contact[] contacts1Result = check mapResult.get("A");
        Contact[] contacts2Result = check mapResult.get("B");
        Contact[] contacts = [...contacts1Result, ...contacts2Result];
        
        check sendEmailWithContacts(contacts);
        return contacts;
    }
}