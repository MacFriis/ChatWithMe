//
//  Chat+CoreDataProperties.h
//  Chat With Me
//
//  Created by Per Friis on 03/11/15.
//  Copyright © 2015 Friis Consult aps. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Chat.h"

NS_ASSUME_NONNULL_BEGIN

@interface Chat (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *conversation;
@property (nullable, nonatomic, retain) NSDate *date;
@property (nullable, nonatomic, retain) NSString *message;
@property (nullable, nonatomic, retain) NSString *from;
@property (nullable, nonatomic, retain) NSString *to;
@property (nullable, nonatomic, retain) NSString *recordName;

@end

NS_ASSUME_NONNULL_END
