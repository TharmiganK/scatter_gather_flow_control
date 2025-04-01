import ballerinax/googleapis.gmail;

final gmail:ConnectionConfig gmailConfig = {
    auth: {
        clientId: gmailClientId,
        clientSecret: gmailClientSecret,
        refreshToken: gmailRefreshToken
    }
};

final gmail:Client gmailClient = check new (gmailConfig);