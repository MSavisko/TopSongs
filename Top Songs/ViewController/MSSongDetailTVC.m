//
//  MSSongDetailTVC.m
//  Top Songs
//
//  Created by Maksym Savisko on 5/8/16.
//  Copyright © 2016 Maksym Savisko. All rights reserved.
//

#import "MSSongDetailTVC.h"
#import "AFNetworking.h"

@interface MSSongDetailTVC ()
@property (strong, nonatomic) NSArray *songItems;
@property (weak, nonatomic) IBOutlet UIImageView *songImageView;

@end

@implementation MSSongDetailTVC
#pragma mark - UITableViewController
- (void) viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.title = self.song.artist;
    self.songItems = @[@"title", @"collectionName", @"releaseDate", @"price", @"url"];
    
    
    [NSThread detachNewThreadSelector:@selector(downloadImageWithAFNetworking) toTarget:self withObject:nil];
    //[self downloadImage];
    //[self downloadImageWithAFNetworking];
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
        [titleLabel setText:self.song.title];
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

#pragma mark - HelperMethods
- (void) downloadAndLoadImage {
    NSString *urlString = @"http://is4.mzstatic.com/image/thumb/Music60/v4/03/59/c0/0359c06c-6cca-dc04-2411-8fc8878caf7c/886445894653.jpg/170x170bb-85.jpg";
    NSURL *url = [[NSURL alloc]initWithString:urlString];
    NSData *data = [[NSData alloc] initWithContentsOfURL:url];
    UIImage *image = [UIImage imageWithData:data];
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        self.songImageView = imageView;
        [self.songImageView setNeedsDisplay];
    });
}

- (void) downloadImage {
    // Set NSURLSessionConfig to be a default session
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    // Create session using config
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    
    // Create URL
    //NSURL *url = [NSURL URLWithString:@"http://is4.mzstatic.com/image/thumb/Music60/v4/03/59/c0/0359c06c-6cca-dc04-2411-8fc8878caf7c/886445894653.jpg/170x170bb-85.jpg"];
    
    // Create URL request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.song.imageUrl];
    request.HTTPMethod = @"GET";
    
    // Create data task
    NSURLSessionDataTask *getDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        // Okay, now we have the image data (on a background thread)
        UIImage *image = [UIImage imageWithData:data];
        
        // We want to update our UI so we switch to the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // Create image view using fetched image (or update an existing one)
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            self.songImageView = imageView;
            [self.songImageView setNeedsDisplay];
            
            // Do whatever other UI updates are needed here on the main thread...
        });
    }];
    
    // Execute request
    [getDataTask resume];
}

- (void) downloadImageWithAFNetworking {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:self.song.imageUrl];
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request
                                                                     progress:nil
                                                                  destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                                                                      NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory
                                                                                                                                            inDomain:NSUserDomainMask
                                                                                                                                   appropriateForURL:nil
                                                                                                                                              create:NO
                                                                                                                                               error:nil];
                                                                      return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
                                                                  }
                                                            completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                                                                NSLog(@"File downloaded to: %@", filePath);
                                                                NSData *data = [NSData dataWithContentsOfURL:filePath];
                                                                UIImage *image = [[UIImage alloc]initWithData:data];
                                                                self.songImageView.image = image;
                                                                [self.songImageView setNeedsDisplay];
                                                                
                                                            }];
    [downloadTask resume];
    
}

@end
