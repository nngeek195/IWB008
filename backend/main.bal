import ballerina/email;
import ballerina/http;
import ballerina/uuid;
import ballerinax/mongodb;

configurable string host = "localhost";
configurable int port = 27017;

final mongodb:Client mongoDb = check new ({
    connection: {
        serverAddress: {
            host,
            port
        }
    }
});

// Configure CORS globally
@http:ServiceConfig {
    cors: {
        allowOrigins: ["*"],
        allowCredentials: true,
        allowMethods: ["POST", "GET"],
        allowHeaders: ["Content-Type"],
        exposeHeaders: ["Content-Length"],
        maxAge: 600
    }
}

//get city data from database this works on 9092 port
service /api on new http:Listener(9092) {

    private final mongodb:Database city;

    function init() returns error? {
        self.city = check mongoDb->getDatabase("city");
    }

    // Resource to get a single user by city
    resource function get city/[string city]() returns city_names|error {
        mongodb:Collection cityCollection = check self.city->getCollection("city");
        stream<city_names, error?> resultStream = check cityCollection->find({city: city});
        record {city_names value;}|error? result = resultStream.next();

        if result is error? {
            return error(string `Cannot find the user with city: ${city}`);
        }
        return result.value;
    }

    // Resource to get all cities
    resource function get cities() returns city_names[]|error {
        mongodb:Collection cityCollection = check self.city->getCollection("city");
        stream<city_names, error?> resultStream = check cityCollection->find({});
        city_names[] citiesList = [];

        check from city_names city in resultStream
            do {
                citiesList.push(city);
            };

        return citiesList;
    }
}

// Configure CORS globally
@http:ServiceConfig {
    cors: {
        allowOrigins: ["*"],
        allowCredentials: true,
        allowMethods: ["POST", "GET"],
        allowHeaders: ["Content-Type"],
        exposeHeaders: ["Content-Length"],
        maxAge: 600
    }
}
//this use to get data from shop database and this works on 9091 port 
service /api on new http:Listener(9091) {

    private final mongodb:Database shopsDb;

    function init() returns error? {
        // Initialize shops database
        self.shopsDb = check mongoDb->getDatabase("shops");
    }

    // Resource to get shops by city
    resource function get shops/[string city]() returns shop_details[]|error {
        mongodb:Collection shopsCollection = check self.shopsDb->getCollection("shops");

        // Query shops by city name
        stream<shop_details, error?> resultStream = check shopsCollection->find({city: city});
        shop_details[] shopsList = [];

        check from shop_details shop in resultStream
            do {
                shopsList.push(shop);
            };

        return shopsList;
    }
}

@http:ServiceConfig {
    cors: {
        allowOrigins: ["*"],
        allowCredentials: true,
        allowMethods: ["POST", "GET"],
        allowHeaders: ["Content-Type"],
        exposeHeaders: ["Content-Length"],
        maxAge: 600
    }
}

//this is the functions use to loging and signing this works on 9090 port
service /api on new http:Listener(9090) {

    private final mongodb:Database userDb;

    // Initialize the MongoDB connection to the "userDb" database
    function init() returns error? {
        self.userDb = check mongoDb->getDatabase("userDb");
    }

    // Resource to handle user signup and send confirmation email
    resource function post signup(UserInput input) returns http:Response|error {
        mongodb:Collection usersCollection = check self.userDb->getCollection("users");

        // Check if username or email already exists
        stream<User, error?> findResult = check usersCollection->find({
            \$or: [{username: input.username}, {email: input.email}]
        });
        User[] existingUsers = check from User user in findResult
            select user;

        if existingUsers.length() > 0 {
            return error("Username or email already exists.");
        }

        // Set up SMTP Client (Configure your SMTP details properly)
        email:SmtpClient smtpClient = check new ("smtp.gmail.com", "nngeek195@gmail.com", "gnqt zacd ptak osja");

        // Try to send the welcome email
        email:Message message = {
            to: [input.email ?: ""],
            subject: "Welcome to TOWO APP",
            body: "Dear " + input.username + ",\n\nWelcome to TOWO APP! We're glad to have you on board."
        };

        // Try sending the email. If it fails, return error message and halt the signup process
        error? emailStatus = smtpClient->sendMessage(message);
        if emailStatus is error {
            http:Response response = new;
            response.statusCode = 400;
            response.setPayload({message: "Failed to send email. Please check the email address."});
            return response;
        }

        // If email was successfully sent, store the user in the database
        string id = uuid:createType1AsString();
        User user = {
            id: id,
            username: input.username,
            password: input.password,
            email: input.email ?: ""
        };

        check usersCollection->insertOne(user);

        // Return success response
        http:Response response = new;
        response.setPayload({message: "Signup successful. Please proceed to login."});
        return response;
    }

    // Resource to handle user login
    resource function post login(LoginInput input) returns http:Response|error {
        mongodb:Collection usersCollection = check self.userDb->getCollection("users");

        // Check if username and password match the records
        stream<User, error?> findResult = check usersCollection->find({
            username: input.username,
            password: input.password
        });
        User[] users = check from User user in findResult
            select user;

        if users.length() == 0 {
            return error("Invalid username or password.");
        }

        // Login successful
        http:Response response = new;
        response.setPayload({message: "Login successful!"});
        return response;
    }
}

@http:ServiceConfig {
    cors: {
        allowOrigins: ["*"],
        allowCredentials: true,
        allowMethods: ["POST", "GET"],
        allowHeaders: ["Content-Type"],
        exposeHeaders: ["Content-Length"],
        maxAge: 600
    }
}
//use to get idea from users
service /api on new http:Listener(9094) {

    private final mongodb:Database idea;

    // Initialize the MongoDB connection to the "userDb" database
    function init() returns error? {
        self.idea = check mongoDb->getDatabase("idea");
    }

    // Resource to handle user signup and send confirmation email
    resource function post msg(MsgInput input) returns http:Response|error {
        mongodb:Collection ideaCollection = check self.idea->getCollection("idea");

        // Set up SMTP Client (Configure your SMTP details properly)
        email:SmtpClient smtpClient = check new ("smtp.gmail.com", "nngeek195@gmail.com", "gnqt zacd ptak osja");

        // Try to send the welcome email
        email:Message message = {
            to: [input.email ?: ""],
            subject: "TOWO APP NOTIFICATION",
            body: "Dear " + input.username + ",\n\nThanks for your Feedback"
        };

        // Try sending the email. If it fails, return error message and halt the signup process
        error? emailStatus = smtpClient->sendMessage(message);
        if emailStatus is error {
            http:Response response = new;
            response.statusCode = 400;
            response.setPayload({message: "Failed to send email."});
            return response;
        }

        // If email was successfully sent, store the user in the database
        string id = uuid:createType1AsString();
        Msg msg = {
            id: id,
            username: input.username,
            msg: input.msg,
            email: input.email ?: ""
        };

        check ideaCollection->insertOne(msg);

        // Return success response
        http:Response response = new;
        response.setPayload({message: "successfull."});
        return response;
    }
}

@http:ServiceConfig {
    cors: {
        allowOrigins: ["*"],
        allowCredentials: true,
        allowMethods: ["POST", "GET"],
        allowHeaders: ["Content-Type"],
        exposeHeaders: ["Content-Length"],
        maxAge: 600
    }
}
//use to give password to user when they foget it
service /api on new http:Listener(9095) {

    private final mongodb:Database userDb;

    function init() returns error? {
        // Connect to the 'userDb' database
        self.userDb = check mongoDb->getDatabase("userDb");
    }

    // Resource to handle "Forget Password" request
    resource function post foget(ReserPassUserInput input) returns http:Response|error {
        mongodb:Collection usersCollection = check self.userDb->getCollection("users");

        // Query the MongoDB database for matching username and email
        stream<User, error?> resultStream = check usersCollection->find({
            username: input.username,
            email: input.email
        });

        User[] users = check from User user in resultStream
            select user;

        if users.length() == 0 {
            // No matching user found, return error response
            http:Response response = new;
            response.statusCode = 404;
            response.setPayload({message: "User not found with the given username and email."});
            return response;
        }

        // Get the user's password
        User user = users[0];
        string password = user.password;

        // Set up SMTP Client (Configure your SMTP details properly)
        email:SmtpClient smtpClient = check new ("smtp.gmail.com", "nngeek195@gmail.com", "gnqt zacd ptak osja");

        // Create the email message with the user's password
        email:Message message = {
            to: [input.email],
            subject: "Your Password for TOWO APP",
            body: "Dear " + input.username + ",\n\nYour password is: " + password + "\n\nPlease keep it safe."
        };

        // Send the email with the password
        error? emailStatus = smtpClient->sendMessage(message);
        if emailStatus is error {
            // If email sending fails, return error message
            http:Response response = new;
            response.statusCode = 500;
            response.setPayload({message: "Failed to send email. Please try again later."});
            return response;
        }

        // Return success response
        http:Response response = new;
        response.setPayload({message: "Password has been sent to your email."});
        return response;
    }
}

// User Input Type Definition for Forget Password
type ReserPassUserInput record {
    string username;
    string email;
};

// User Record
type User record {
    string id;
    string username;
    string password;
    string email;
};

type city_names record {
    string city;
    float latitude;
    float longitude;

};

type shop_details record {
    string city;
    string name;
    string type1;
    string whatsapp;
    int local;
    float latitude?;
    float longitude?;
};

// User Input Type Definition for Signup
type UserInput record {
    string username;
    string password;
    string email?;
};

// User Input Type Definition for Login
type LoginInput record {
    string username;
    string password;
};

// User Input msg
type MsgInput record {
    string username;
    string email?;
    string msg;
};

// massage Record
type Msg record {
    string id;
    string username;
    string email;
    string msg;

};

// User Input msg
type ResetInput record {
    string username;
    string email?;
};

// massage Record
type Reset record {
    string id;
    string username;
    string email;

};

