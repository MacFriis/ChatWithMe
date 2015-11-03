# ChatWithMe

A sample project
## iOS Chat using CloudKit
This app is written in objective-c, using only standard components from iOS (CoreData, CloudKit)
There is no security or handling of who is on the chat, this is only a POC.

To build, you need to change the **Team** and the **Buldle identifier**,  then "fix" the capability "Cloud Kit" to make sure that the provision file have the database


##To use
Only on device (the simulator, don't support remote push, so it can send, but don't receive)
Enter your own name - when prompet

*You need to be logged in to iCloud on your device, otherwise, the "savesubscription" will fail*

tap - New Chat and enter a name, that you know some one else is using
start chat

There is not any UX or UI created
You can customize the tableview, to look anything you like.
