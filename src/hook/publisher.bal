import ballerina/http;
import ballerina/log;
import ballerina/websub;
import ballerina/io;

// Creates a new client to check for updates periodically from the third party backend.
http:Client thirdPartyBE = new("https://newsapi.org/v2");

listener http:Listener httpListener = new(9090);

// The topics against which the publisher will publish updates and the subscribers
// need to subscribe to, to receive notifications with new updates.
final string NEWS_TOPIC = "http://localhost:9090/news/newstopic";
final string BITCOIN_TOPIC = "http://localhost:9090/news/bitcoin";

// Invokes the function that starts up a Ballerina WebSub Hub, registers the topic
// against which updates will be published, and maintains a reference to the
// returned hub object to publish updates.
websub:WebSubHub webSubHub = startHubAndRegisterTopic();

@http:ServiceConfig {
    basePath: "/news"
}
service newsMgt on httpListener {

    // This resource accepts the discovery requests for news updates.
    // Requests received at this resource would respond with a Link Header
    // indicating the topic to subscribe to and the hub(s) to subscribe at.
    @http:ResourceConfig {
        methods: ["GET", "HEAD"],
        path: "/discoverHubForNews"
    }
    resource function discoverNewsTopic(http:Caller caller, http:Request req) {
        http:Response response = new;
        // Adds a link header indicating the hub and topic.
        websub:addWebSubLinkHeader(response, [webSubHub.hubUrl], NEWS_TOPIC);
        response.statusCode = 202;
        var result = caller->respond(response);
        if (result is error) {
           log:printError("Error discovering news topic", result);
        }
    }

    // This resource accepts the discovery requests for bitcoin.
    // Requests received at this resource would respond with a Link Header
    // indicating the topic to subscribe to and the hub(s) to subscribe at.
    @http:ResourceConfig {
        methods: ["GET", "HEAD"],
        path: "/discoverHubForBitcoin"
    }
    resource function discoverBitcoinTopic(http:Caller caller, http:Request req) {
        http:Response response = new;
        // Adds a link header indicating the hub and topic.
        websub:addWebSubLinkHeader(response, [webSubHub.hubUrl], BITCOIN_TOPIC);
        response.statusCode = 202;
        var result = caller->respond(response);
        if (result is error) {
           log:printError("Error discovering bitcoin topic", result);
        }
    }

    //Publishes news to topics.
    @http:ResourceConfig {
        methods: ["GET"],
        path: "/checkForUpdates"
    }
    resource function newsUpdates(http:Caller caller, http:Request req) {

        //Check for general news updates.
        var newsResponse = thirdPartyBE->get("/top-headlines?country=us&category=business&apiKey=8cf52e6024924582a4ce31b998d7d032");
        //Check for bitcoin news.
        var bitcoinResponse = thirdPartyBE->get("/everything?q=bitcoin&from=2019-07-15&sortBy=publishedAt&apiKey=8cf52e6024924582a4ce31b998d7d032");

        var newsPayload = extractPayload(newsResponse);
        var bitcoinPayload = extractPayload(bitcoinResponse);

        http:Response resToCaller = new;

        if (newsPayload is json && bitcoinPayload is json) {
            resToCaller.statusCode = 202;
            var result = caller->respond(resToCaller);
            if (result is error) {
               log:printError("Error responding to newsUpdates", err = result);
            }
            //Publishes the update to the Hub to notify the subscribers.
            var newsResult = webSubHub.publishUpdate(NEWS_TOPIC, newsPayload);
            var bitcoinResult = webSubHub.publishUpdate(BITCOIN_TOPIC, bitcoinPayload);
            if (newsResult is error) {
                log:printError("Error publishing update for news", newsResult);
            }
            if (bitcoinResult is error) {
                log:printError("Error publishing update for bitcoin", bitcoinResult);
            }
        } else {
            resToCaller.statusCode = 500;
            resToCaller.setTextPayload("Error in calling third party backend");
            var result = caller->respond(resToCaller);
            if (result is error) {
               log:printError("Error responding to newsUpdates", err = result);
            }
        }
    }

    //Publishes news to topics.
    @http:ResourceConfig {
        methods: ["GET"],
        path: "/publish"
    }
    resource function newsUpdatesToCustomSubs(http:Caller caller, http:Request req) {

        //Check for general news updates.
        var newsResponse = thirdPartyBE->get("/top-headlines?country=us&category=business&apiKey=8cf52e6024924582a4ce31b998d7d032");
        //Check for bitcoin news.
        var bitcoinResponse = thirdPartyBE->get("/everything?q=bitcoin&from=2019-07-15&sortBy=publishedAt&apiKey=8cf52e6024924582a4ce31b998d7d032");

        var newsPayload = extractPayload(newsResponse);
        var bitcoinPayload = extractPayload(bitcoinResponse);

        http:Response resToCaller = new;

        if (newsPayload is json && bitcoinPayload is json) {

            json general = {"subject" : "general"};
            json|error gn = general.mergeJson(newsPayload);

            json bitcoin = {"subject" : "bitcoin"};
            json|error bc = bitcoin.mergeJson(newsPayload);

            if (gn is json && bc is json) {
                //io:println(general);
                //io:println(bitcoin);

                resToCaller.statusCode = 202;
                var result = caller->respond(resToCaller);
                if (result is error) {
                   log:printError("Error responding to newsUpdates", err = result);
                }

                //Publishes the update to the Hub to notify the subscribers.
                var newsResult = webSubHub.publishUpdate(NEWS_TOPIC, gn);
                var bitcoinResult = webSubHub.publishUpdate(BITCOIN_TOPIC, bc);

                if (newsResult is error) {
                    log:printError("Error publishing update for news", newsResult);
                }
                if (bitcoinResult is error) {
                    log:printError("Error publishing update for bitcoin", bitcoinResult);
                }
            } else {
                io:println(gn);
                io:println(bc);
            }
        } else {
            resToCaller.statusCode = 500;
            resToCaller.setTextPayload("Error in calling third party backend");
            var result = caller->respond(resToCaller);
            if (result is error) {
               log:printError("Error responding to newsUpdates", err = result);
            }
        }
    }
}

// Starts up a Ballerina WebSub Hub on port 9191 and registers the topic against
// which updates will be published.
function startHubAndRegisterTopic() returns websub:WebSubHub {
    var hubStartUpResult = websub:startHub(new http:Listener(9191));
    websub:WebSubHub internalHub = hubStartUpResult is websub:HubStartedUpError
                    ? hubStartUpResult.startedUpHub : hubStartUpResult;

    var result1 = internalHub.registerTopic(NEWS_TOPIC);
    if (result1 is error) {
        log:printError("Error registering for news topic", result1);
    }

    var result2 = internalHub.registerTopic(BITCOIN_TOPIC);
    if (result2 is error) {
        log:printError("Error registering for bitcoin topic", result2);
    }
    return internalHub;
}

function extractPayload(http:Response|error thirdPartyRes) returns @tainted json|error {
    if (thirdPartyRes is http:Response) {
        var msg = thirdPartyRes.getJsonPayload();
        return msg;
    } else {
        return thirdPartyRes;
    }
}
