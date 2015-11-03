//
//  AppDelegate.m
//  Chat With Me
//
//  Created by Per Friis on 03/11/15.
//  Copyright © 2015 Friis Consult aps. All rights reserved.
//

#import "AppDelegate.h"
@import CloudKit;

@interface AppDelegate ()

@end

@implementation AppDelegate
@synthesize me = _me; // only needed as the property is readonly
- (NSString *)me{
    if (!_me || _me.length == 0) {
        _me = [[NSUserDefaults standardUserDefaults] valueForKey:@"me"];
    }
    return _me;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Override point for customization after application launch.

    [application registerForRemoteNotifications];
    
    [self startListenForChat];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.friisconsult.Chat_With_Me" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Chat_With_Me" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Chat_With_Me.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        
        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - notifications

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    
    CKNotification *cloudKitNotification = [CKNotification notificationFromRemoteNotificationDictionary:userInfo];
    
    if (cloudKitNotification.notificationType == CKNotificationTypeQuery) {
        CKRecordID *recordID = [(CKQueryNotification *)cloudKitNotification recordID];
        
        CKDatabase *publicDatabase = [[CKContainer defaultContainer] publicCloudDatabase];
        
        [publicDatabase fetchRecordWithID:recordID completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
            if (error) {
                NSLog(@"%@ - %@",@(__PRETTY_FUNCTION__), error);
            } else {
                
                // coredata is not block safe and we need ui to run in the main thread
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    Chat *chat = [NSEntityDescription insertNewObjectForEntityForName:@"Chat" inManagedObjectContext:self.managedObjectContext];
                    
                    chat.date = [record valueForKey:@"date"];
                    chat.from = [record valueForKey:@"from"];
                    chat.to   = [record valueForKey:@"to"];
                    chat.message = [record valueForKey:@"message"];
                    chat.conversation = [record valueForKey:@"conversation"];
                    chat.recordName = record.recordID.recordName;
                    
                    [self saveContext];
                    
                }];
            }
        }];
        
        
    }
    
    
    NSLog(@"%@ - %@",@(__PRETTY_FUNCTION__), userInfo);
    
    
    completionHandler(UIBackgroundFetchResultNewData);
    
}



#pragma mark - cloudkit chat
- (void)startListenForChat{
    if (!self.me || self.me.length == 0) {
        return;
    }
    
   
    
    
    CKDatabase *database = [[CKContainer defaultContainer] publicCloudDatabase];
    
    CKSubscription *chatSubscription = [[CKSubscription alloc] initWithRecordType:@"Chat" predicate:[NSPredicate predicateWithFormat:@"to == %@",self.me] subscriptionID:self.me options:CKSubscriptionOptionsFiresOnRecordCreation];
    
    
    CKNotificationInfo *notificationInfo = [CKNotificationInfo new];
    notificationInfo.shouldSendContentAvailable = YES;
    
    chatSubscription.notificationInfo = notificationInfo;
    
    [database saveSubscription:chatSubscription completionHandler:^(CKSubscription * _Nullable subscription, NSError * _Nullable error) {
        NSLog(@"%@ - %@",@(__PRETTY_FUNCTION__),error);
    }];
}

- (void)submitChatMessage:(Chat *)chat{
    CKRecord *record = [[CKRecord alloc] initWithRecordType:@"Chat"];
    chat.recordName = record.recordID.recordName;
    
    [record setValue:chat.date forKey:@"date"];
    [record setValue:chat.to forKey:@"to"];
    [record setValue:chat.from forKey:@"from"];
    [record setValue:chat.message forKey:@"message"];
    [record setValue:chat.conversation forKey:@"conversation"];
    
    CKDatabase *publicDatabase = [[CKContainer defaultContainer] publicCloudDatabase];
    
    [publicDatabase saveRecord:record completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
        NSLog(@"%@ - %@",@(__PRETTY_FUNCTION__), error);
    }];
}




@end
