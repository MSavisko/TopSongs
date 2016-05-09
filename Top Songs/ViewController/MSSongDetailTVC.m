//
//  MSSongDetailTVC.m
//  Top Songs
//
//  Created by Maksym Savisko on 5/8/16.
//  Copyright © 2016 Maksym Savisko. All rights reserved.
//

#import "MSSongDetailTVC.h"
#import "AFNetworking.h"
#import <Social/Social.h>

@interface MSSongDetailTVC () <UIActionSheetDelegate, UIAlertViewDelegate>
@property (strong, nonatomic) NSArray *songItems;
@property (weak, nonatomic) IBOutlet UIImageView *songImageView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareButton;

@end

@implementation MSSongDetailTVC
#pragma mark - UITableViewController
- (void) viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.title = self.song.artist;
    self.songItems = @[@"title", @"collectionName", @"releaseDate", @"price", @"url"];
    [NSThread detachNewThreadSelector:@selector(downloadAndLoadImage) toTarget:self withObject:nil];
}

#pragma makr - Action
- (IBAction)shareButtonPressed:(id)sender {
    UIActionSheet *shareActionSheet = [[UIActionSheet alloc]initWithTitle:@"How to share?"
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"Twitter", @"Facebook", @"E-mail", nil];
    [shareActionSheet showInView:self.view];
}

#pragma mark - TableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.songItems[indexPath.row]isEqualToString:@"url"]) {
        [[UIApplication sharedApplication] openURL:self.song.url];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - TableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.songItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = [self.songItems objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if ([cell.reuseIdentifier isEqualToString:@"title"]) {
        UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:100];
        [titleLabel setText:self.song.name];
    }
    if ([cell.reuseIdentifier isEqualToString:@"collectionName"]) {
        UILabel *collectionLabel = (UILabel *)[cell.contentView viewWithTag:200];
        [collectionLabel setText:self.song.collectionName];
    }
    if ([cell.reuseIdentifier isEqualToString:@"releaseDate"]) {
        UILabel *dateLabel = (UILabel *)[cell.contentView viewWithTag:300];
        [dateLabel setText:self.song.releaseDate];
    }
    if ([cell.reuseIdentifier isEqualToString:@"price"]) {
        UILabel *dateLabel = (UILabel *)[cell.contentView viewWithTag:400];
        [dateLabel setText:self.song.price];
    }
    if ([cell.reuseIdentifier isEqualToString:@"url"]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

#pragma mark - UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) { //Twitter
        if ([self stringResultTwitter].length > 116) {
            [self showAlertWithMessage:@"The result is too long to send the tweet. You will need to manually cut it!" tag:100];
        } else {
            [self shareWithTwitter];
        }
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 100) {
        [self shareWithTwitter];
    }
    if (alertView.tag == 200) {
        [self shareWithFacebook];
    }
}

#pragma mark - ShareMethods
- (void) shareWithTwitter {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweet setInitialText:[self stringResultTwitter]];
        NSData *data = [NSData dataWithContentsOfURL:self.song.imagePath];
        UIImage *image = [[UIImage alloc]initWithData:data];
        [tweet addImage:image];
        [tweet setCompletionHandler:^(SLComposeViewControllerResult result)
         {
             if (result == SLComposeViewControllerResultCancelled)
             {
                 //The user cancelled
             }
             else if (result == SLComposeViewControllerResultDone)
             {
                 //The user sent the tweet
             }
         }];
        [self presentViewController:tweet animated:YES completion:nil];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Twitter"
                                                        message:@"Twitter integration is not available. A Twitter account must be set up on your device."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void) shareWithFacebook {
    
}

#pragma mark - PresentationDataMethod
- (NSString*) stringResultTwitter {
    NSString *result = [NSString stringWithFormat:@"Artist: %@\nTrack name: %@\nCollection name: %@\nReleased: %@\nPrice: %@", self.song.artist, self.song.name, self.song.collectionName, self.song.releaseDate, self.song.price];
    return result;
}

#pragma mark - HelperMethods
- (void) downloadAndLoadImage {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:self.song.imageUrl];
    
    NSString *fileName = [NSString stringWithFormat:@"%@.jpg", self.song.title];
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request
                                                                     progress:nil
                                                                  destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                                                                      NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory
                                                                                                                                            inDomain:NSUserDomainMask
                                                                                                                                   appropriateForURL:nil
                                                                                                                                              create:NO
                                                                                                                                               error:nil];
                                                                      return [documentsDirectoryURL URLByAppendingPathComponent:fileName];
                                                                  }
                                                            completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                                                                NSLog(@"File downloaded to: %@", filePath);
                                                                NSData *data = [NSData dataWithContentsOfURL:filePath];
                                                                UIImage *image = [[UIImage alloc]initWithData:data];
                                                                self.songImageView.image = image;
                                                                [self.songImageView setNeedsDisplay];
                                                                [self.song setImagePath:filePath];
                                                                
                                                            }];
    [downloadTask resume];
}

- (void) showAlertWithMessage:(NSString*)message tag:(NSInteger)tag {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning!"
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    alert.tag = tag;
    [alert show];
}

@end
