import ballerina/log;
import ballerina/websub;
import ballerina/lang.'object as objects;

// Introduce a record mapping the JSON payload received when news update received.
public type GeneralNewsUpdateEvent record {|
    string subject;
    //string status;
    //TODO:Map other details
|};

// Introduce a record mapping the JSON payload received when bitcoin news received.
public type BitcoinNewsUpdateEvent record {|
    string subject;
    //string status;
    //TODO:Map other details
|};

// Introduce a new `listener` wrapping the generic `ballerina/websub:Listener`
public type WebhookListener object {

    *objects:AbstractListener;

    private websub:Listener websubListener;

    public function __init(int port) {
        // Introduce the extension config, based on the mapping details.
        websub:ExtensionConfig extensionConfig = {
            topicIdentifier:websub:TOPIC_ID_PAYLOAD_KEY,
            payloadKeyResourceMap: {
                "subject": {
                   "general": ["onGeneralNewsUpdate", GeneralNewsUpdateEvent],
                   "bitcoin": ["onBitcoinNewsUpdate", BitcoinNewsUpdateEvent]
                }
            }
        };

        // Set the extension config in the generic `websub:Listener` config.
        websub:SubscriberListenerConfiguration sseConfig = {
            extensionConfig: extensionConfig
        };

        // Initialize the wrapped generic listener.
        self.websubListener = new(port, sseConfig);
    }

    public function __attach(service s, string? name = ()) returns error?  {
        return self.websubListener.__attach(s, name);
    }

    public function __start() returns error? {
        return self.websubListener.__start();
    }

    public function __immediateStop() returns error? {
        return self.websubListener.__immediateStop();
    }

    public function __gracefulStop() returns error? {
        return self.websubListener.__gracefulStop();
    }
};

@websub:SubscriberServiceConfig {
    path: "/subscriber",
    subscribeOnStartUp: true,
    target: "http://localhost:9090/news/discoverHubForNews"
}
service specificSubscriber on new WebhookListener(8080) {
    resource function onGeneralNewsUpdate(websub:Notification notification, GeneralNewsUpdateEvent gNews) {
        log:printInfo("onGeneralNewsUpdate>>");
        log:printInfo(gNews.subject);
    }

    resource function onBitcoinNewsUpdate(websub:Notification notification, BitcoinNewsUpdateEvent bNews) {
        log:printInfo("onBitcoinNewsUpdate>>");
        log:printInfo(bNews.subject);
    }
}
