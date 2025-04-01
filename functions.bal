import ballerina/io;
import ballerinax/googleapis.gmail;

function readContactsFromCsv(string path) returns Contact[]|error {
    stream<Contact, error?> csvStream = check io:fileReadCsvAsStream(path);
    Contact[] contacts = [];
    check csvStream.forEach(function(Contact contact) {
        contacts.push(contact);
    });
    return contacts;
}

function sendEmailWithContacts(Contact[] contacts) returns error? {
    ContactList contactList = {contacts};
    string messageBody = contactList.toJsonString();

    gmail:MessageRequest message = {
        to: [recipientEmail],
        subject: "Aggregated Contact Information",
        bodyInText: messageBody
    };

    _ = check gmailClient->/users/["me"]/messages/send.post(message);
}