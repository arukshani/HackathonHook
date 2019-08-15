// The Ballerina WebSub Subscriber service, which subscribes to notifications at the Hub.
import ballerina/log;
import ballerina/websub;

//The endpoint to which the subscriber service is bound.
listener websub:Listener websubEP = new(8181);

// Annotations specifying the subscription parameters for the news service.
// A subscription request would be sent to the hub with the topic discovered at the
// resource URL specified.
@websub:SubscriberServiceConfig {
    path: "/newseventsubscriber",
    subscribeOnStartUp: true,
    target: "http://localhost:9090/news/discoverHubForNews",
    leaseSeconds: 3600,
    secret: "Kslk30SNF2AChs2"
}
service websubSubscriberForNews on websubEP {
    // Defines the resource, which accepts the content delivery requests for general news.
    resource function onNotification(websub:Notification notification) {
        log:printInfo("NEWS UPDATES!!");
        var payload = notification.getJsonPayload();
        if (payload is json) {
            log:printInfo("==================WebSub Notification Received for general news: " + payload.toJsonString());
        } else {
            log:printError("Error retrieving payload as string", payload);
        }
    }
}

// Annotations specifying the subscription parameters for the bitcoin service.
// A subscription request would be sent to the hub with the topic discovered at the
// resource URL specified.
@websub:SubscriberServiceConfig {
    path: "/bitcoineventsubscriber",
    subscribeOnStartUp: true,
    target: "http://localhost:9090/news/discoverHubForBitcoin",
    leaseSeconds: 3600,
    secret: "Kslk30SNF2AChs2"
}
service websubSubscriberForBitCoin on websubEP {
    // Defines the resource, which accepts the content delivery requests for bitcoin.
    resource function onNotification(websub:Notification notification) {
        log:printInfo("BITCOIN NEWS!!");
        var payload = notification.getJsonPayload();
        if (payload is json) {
            log:printInfo("=======================WebSub Notification Received for Bitcoin: " + payload.toJsonString());
        } else {
            log:printError("Error retrieving payload as string", payload);
        }
    }
}
