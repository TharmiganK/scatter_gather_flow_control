import ballerina/data.jsondata;
import ballerina/http;
import ballerina/io;
import ballerina/log;
import ballerinax/googleapis.gmail;

listener http:Listener httpDefaultListener = http:getDefaultListener();

service /api on httpDefaultListener {

    resource function get contacts() returns error|Contact[] {
        do {
            fork {
                worker worker1 returns Contact[]|error {
                    Contact[]|error contacts = io:fileReadCsv("./resources/contacts_1.csv");
                    if contacts is error {
                        log:printError("error occurred while reading the file", contacts);
                        return contacts;
                    }
                    return contacts;
                }
                worker worker2 returns Contact[]|error {
                    Contact[]|error contacts = io:fileReadCsv("./resources/contacts_2.csv");
                    if contacts is error {
                        log:printError("error occurred while reading the file", contacts);
                        return contacts;
                    }
                    return contacts;
                }
            }
            map<Contact[]|error> waitResult = wait {worker1, worker2};
            Contact[] contacts1 = check waitResult.get("worker1");
            Contact[] contacts2 = check waitResult.get("worker2");
            Contact[] allContacts = [...contacts1, ...contacts2];
            string gmailBody = jsondata:prettify({contracts: allContacts});
            gmail:Message gmailMessage = check gmailClient->/users/["me"]/messages/send.post({to: [gmailRecipient], subject: "Contacts List", bodyInText: gmailBody});
            return allContacts;

        } on fail error err {
            // handle error

            log:printError("error occurred while serving the request", err);
            return err;
        }
    }
}
