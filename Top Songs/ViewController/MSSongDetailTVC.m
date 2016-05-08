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

@end

@implementation MSSongDetailTVC
#pragma mark - UITableViewController
- (void) viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.songData = @[self.song.title, self.song.collectionName, self.song.releaseDate, self.song.price];
    self.songItems = @[@"title", @"collectionName", @"version", @"materials"];
    
}

@end
