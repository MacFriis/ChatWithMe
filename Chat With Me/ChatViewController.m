//
//  ChatViewController.m
//  Chat With Me
//
//  Created by Per Friis on 03/11/15.
//  Copyright © 2015 Friis Consult aps. All rights reserved.
//
@import CoreData;

#import "ChatViewController.h"
#import "AppDelegate.h"
#import "Chat.h"
#import "ChatTableViewCell.h"

@interface ChatViewController () <NSFetchedResultsControllerDelegate, UITableViewDataSource,UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;

@property (nonatomic, readonly) AppDelegate *appDelegate;
@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, strong) NSString *chatWithHandle;

@end

@implementation ChatViewController

- (AppDelegate *)appDelegate{
    return [[UIApplication sharedApplication] delegate];
}

- (NSManagedObjectContext *)managedObjectContext{
    return self.appDelegate.managedObjectContext;
}

- (void)viewDidLoad {
    [super viewDidLoad];
       // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (!self.appDelegate.me || self.appDelegate.me.length == 0) {
        UIAlertController *askForName = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Who are you", @"Ask for name - title") message:NSLocalizedString(@"Enter caller name", @"Ask for name - Message") preferredStyle:UIAlertControllerStyleAlert];
        [askForName addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = NSLocalizedString(@"Caller name", @"Ask for name - placeholder");
        }];
        
        [askForName addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSString *name = [(UITextField *)askForName.textFields.firstObject text];
            if (!name || name.length == 0) {
                // TODO: handle errors gracefully...
                abort();
            }
            
            [[NSUserDefaults standardUserDefaults] setValue:name forKey:@"me"];
            self.title = self.appDelegate.me;
            [self.appDelegate startListenForChat];

        }]];
        
        [self presentViewController:askForName animated:YES completion:nil];
    } else {
        self.title = self.appDelegate.me;
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate and UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    if ([[self.fetchedResultsController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        return [sectionInfo numberOfObjects];
    } else
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChatTableViewCell *cell;
    Chat *chat = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell = [tableView dequeueReusableCellWithIdentifier:[chat.from isEqualToString:self.appDelegate.me]?@"send cell":@"receive cell"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    dateFormatter.timeStyle = NSDateFormatterMediumStyle;
    dateFormatter.doesRelativeDateFormatting = YES;
    
    cell.dateLabel.text = [dateFormatter stringFromDate:chat.date];
    cell.messageLabel.text = chat.message;

    return cell;
}


/* not used, when
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([[self.fetchedResultsController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        return [sectionInfo name];
    } else
        return nil;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [self.fetchedResultsController sectionIndexTitles];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
}
*/

#pragma mark - User interaction
- (IBAction)newReciever:(id)sender{
    UIAlertController *askForReceiver = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"New chat", @"new chat - title") message:NSLocalizedString(@"Enter name of the one you want to chat with", @"New chat - Message") preferredStyle:UIAlertControllerStyleAlert];
    [askForReceiver addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = NSLocalizedString(@"receiver call name", @"new chat - placeholder");
    }];
    
    [askForReceiver addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.chatWithHandle = [(UITextField *)askForReceiver.textFields.firstObject text];
        
        self.title = [NSString stringWithFormat:@"%@ - %@",self.appDelegate.me, self.chatWithHandle];
        
    }]];
    
    [self presentViewController:askForReceiver animated:YES completion:nil];
}

#pragma mark - fetchedResultsController
- (NSFetchedResultsController *)fetchedResultsController{
    if (!_fetchedResultsController) {
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Chat"];
        fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];
        
        // TODO: create predicate that only shows the chat thread you want it to show now
//        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"to == %@",self.chatWithHandle];
        
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        
        _fetchedResultsController.delegate = self;
        
        NSError *error;
        [_fetchedResultsController performFetch:&error];
        if (error) {
            NSLog(@"%@ - %@",@(__PRETTY_FUNCTION__),error);
            abort(); // as this is a critical element, the app could just abord
        }
    }
    
    return _fetchedResultsController;
}


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        default:
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    Chat *chat = [NSEntityDescription insertNewObjectForEntityForName:@"Chat" inManagedObjectContext:self.managedObjectContext];
    chat.from = self.appDelegate.me;
    chat.to = self.chatWithHandle;
    chat.date = [NSDate date];
    chat.message = textField.text;
    
    [self.appDelegate submitChatMessage:chat];
    
    textField.text = @"";
    

    
    return YES;
}




@end
