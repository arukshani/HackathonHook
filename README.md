# HackathonHook

# WebHook Based Notification

Webhook based notification on news updates for general and bitcoin news

To start publishers and subscribers use this command: ballerina run hook

Use the following URL to check for updates from third party resources(this should ideally be called periodically) and publish news to hub

http://localhost:9090/news/publish

Subscribers will get notified of general and bitcoin news

NOTE: Had to move the custom subscriber to a single file and a different module to get it to work

ISSUES: 
1) https://github.com/ballerina-platform/ballerina-lang/issues/17788
2) https://github.com/ballerina-platform/ballerina-lang/issues/17728



