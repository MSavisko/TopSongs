//
//  MSSongDetailTVC.m
//  Top Songs
//
//  Created by Maksym Savisko on 5/8/16.
//  Copyright © 2016 Maksym Savisko. All rights reserved.
//

#import "MSSongDetailTVC.h"

@interface MSSongDetailTVC ()
@property (strong, nonatomic) NSArray *songData;
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

@end
