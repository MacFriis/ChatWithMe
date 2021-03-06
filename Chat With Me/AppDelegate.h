//
//  AppDelegate.h
//  Chat With Me
//
//  Created by Per Friis on 03/11/15.
//  Copyright © 2015 Friis Consult aps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Chat.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (readonly, strong, nonatomic) NSString *me;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


- (void)startListenForChat;
- (void)submitChatMessage:(Chat *)chat;

@end

