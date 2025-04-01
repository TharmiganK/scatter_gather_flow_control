type Contact record {|
    string firstname;
    string surname;
    string phone;
    string email;
|};

type ContactList record {|
    Contact[] contacts;
|};