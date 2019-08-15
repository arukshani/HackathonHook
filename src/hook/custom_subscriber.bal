import ballerina/io;
import ballerina/log;
import ballerina/websub;

@websub:SubscriberServiceConfig {
    path: "/subscriber",
    subscribeOnStartUp: true,
    target: "http://localhost:9090/news/discoverHubForNews"
}
service specificSubscriber on new WebhookListener(8080) {
    resource function onGeneralNewsUpdate(websub:Notification notification, GeneralNewsUpdateEvent gNews) {
        log:printInfo(gNews.subject);
    }

    resource function onBitcoinNewsUpdate(websub:Notification notification, BitcoinNewsUpdateEvent bNews) {
        log:printInfo(bNews.subject);
    }
}
