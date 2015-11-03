//
//  ChatTableViewCell.h
//  Chat With Me
//
//  Created by Per Friis on 03/11/15.
//  Copyright © 2015 Friis Consult aps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatTableViewCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UILabel *dateLabel;
@property (nonatomic, strong) IBOutlet UILabel *messageLabel;
@end
