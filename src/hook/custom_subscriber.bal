import ballerina/io;
import ballerina/log;
import ballerina/websub;

@websub:SubscriberServiceConfig {
    path: "/subscriber",
    subscribeOnStartUp: false
}
service specificSubscriber on new WebhookListener(8080) {
    resource function onGeneralNewsUpdate(websub:Notification notification, GeneralNewsUpdateEvent gNews) {
        log:printInfo(io:sprintf("General News Received: %s, Status: %s", gNews.status));
    }

    resource function onBitcoinNewsUpdate(websub:Notification notification, BitcoinNewsUpdateEvent bNews) {
        log:printInfo(io:sprintf("Bitcoin News Received: %s", bNews.status));
    }
}
