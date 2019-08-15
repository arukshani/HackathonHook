import ballerina/log;
import ballerina/websub;
import ballerina/lang.'object as objects;

// Introduce a record mapping the JSON payload received when news update received.
public type GeneralNewsUpdateEvent record {|
    string status;
    //TODO:Map the other details
|};

// Introduce a record mapping the JSON payload received when bitcoin news received.
public type BitcoinNewsUpdateEvent record {|
    string status;
    //TODO:Map the other details
|};

// Introduce a new `listener` wrapping the generic `ballerina/websub:Listener`
public type WebhookListener object {

    *objects:AbstractListener;

    private websub:Listener websubListener;

    public function __init(int port) {
        // Introduce the extension config, based on the mapping details.
        websub:ExtensionConfig extensionConfig = {
            topicIdentifier: websub:TOPIC_ID_HEADER,
            topicHeader: "X-Event-Header",
            headerResourceMap: {
                "general": ["onGeneralNewsUpdate", GeneralNewsUpdateEvent],
                "bitcoin": ["onBitcoinNewsUpdate", BitcoinNewsUpdateEvent]
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
