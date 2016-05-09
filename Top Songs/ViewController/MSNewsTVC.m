//
//  MSNewsTVC.m
//  Top Songs
//
//  Created by Maksym Savisko on 5/7/16.
//  Copyright © 2016 Maksym Savisko. All rights reserved.
//

#import "MSNewsTVC.h"
#import "MSSongDetailTVC.h"

#import "MSSong.h"

#import "AFNetworking.h"
#import "MGSwipeTableCell.h"
#import "MBProgressHUD.h"

@interface MSNewsTVC () <NSXMLParserDelegate, MGSwipeTableCellDelegate>
@property (strong, nonatomic) IBOutlet UITableView *newsTableView;
@property (strong, nonatomic) NSXMLParser *xmlParser;
@property (strong, nonatomic) NSMutableArray *arrNewsData;
@property (strong, nonatomic) NSMutableArray *songs;
@property (strong, nonatomic) NSMutableArray *favoriteSongs;
@property (strong, nonatomic) NSMutableDictionary *dictTempDataStorage;
@property (strong, nonatomic) NSMutableString *foundValue;
@property (strong, nonatomic) NSString *currentElement;

@end

@implementation MSNewsTVC
#pragma mark - UITableViewController
- (void) viewDidLoad {
    [super viewDidLoad];
    [self loadSongsListToDict];
    self.favoriteSongs = [[NSMutableArray alloc]init];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    MSSong *song = [[MSSong alloc]initWithDict:self.arrNewsData[indexPath.row]];
    MSSongDetailTVC *detailTVC = segue.destinationViewController;
    detailTVC.song = song;
}

#pragma mark - UITableViewDataSource
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrNewsData.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MGSwipeTableCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"NewsCell"];
    if (cell == nil) {
        cell = [[MGSwipeTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"NewsCell"];
    }
    MSSong *song = self.songs[indexPath.row];
    cell.textLabel.text = song.title;
    cell.detailTextLabel.text = song.releaseDate;
    cell.delegate = self;
    
    cell.rightButtons = @[[MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:@"star_button.png"] backgroundColor:[UIColor colorWithRed:52.0f/255.0f green:152.0f/255.0f blue:219.0f/255.0f alpha:1.0f]]];
    cell.rightSwipeSettings.transition = MGSwipeStateSwipingRightToLeft;
    
    return cell;
}

#pragma mark - MGSwipeTableCellDelegate
-(BOOL) swipeTableCell:(MGSwipeTableCell*) cell tappedButtonAtIndex:(NSInteger) index direction:(MGSwipeDirection)direction fromExpansion:(BOOL) fromExpansion {
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    MSSong *song = self.songs[indexPath.row];
    if (song.isFavorite) {
        song.isFavorite = NO;
        [self.songs replaceObjectAtIndex:indexPath.row withObject:song];
        [self showHudUnFavorites];
    } else {
        song.isFavorite = YES;
        [self.songs replaceObjectAtIndex:indexPath.row withObject:song];
        [self showHudFavorites];
    }
    return YES;
}

#pragma mark - NSXMLParserDelegate
-(void) parserDidStartDocument:(NSXMLParser *)parser {
    self.arrNewsData = [[NSMutableArray alloc] init];
}

-(void) parserDidEndDocument:(NSXMLParser *)parser {
    [self.newsTableView reloadData];
    [self makeSongsArray];
}

-(void) parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    NSLog(@"%@", [parseError localizedDescription]);
}

-(void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    
    [self.foundValue setString:@""];
    if ([elementName isEqualToString:@"entry"]) {
        self.dictTempDataStorage = [[NSMutableDictionary alloc] init];
    }
    self.currentElement = elementName;
}

-(void) parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    if ([elementName isEqualToString:@"entry"]) {
        [self.arrNewsData addObject:[[NSDictionary alloc] initWithDictionary:self.dictTempDataStorage]];
    }
    else if ([elementName isEqualToString:@"title"]){
        [self.dictTempDataStorage setObject:[NSString stringWithString:self.foundValue] forKey:@"title"];
    }
    else if ([elementName isEqualToString:@"im:releaseDate"]){
        NSString *shortenDate = [self.foundValue substringToIndex:10];
        [self.dictTempDataStorage setObject:[NSString stringWithString:shortenDate] forKey:@"releaseDate"];
    }
    else if ([elementName isEqualToString:@"im:name"]) {
        [self.dictTempDataStorage setObject:[NSString stringWithString:self.foundValue] forKey:@"collectionName"];
    }
    else if ([elementName isEqualToString:@"im:image"]){
        [self.dictTempDataStorage setObject:[NSString stringWithString:self.foundValue] forKey:@"imageUrl"];
    }
    else if ([elementName isEqualToString:@"im:artist"]) {
        [self.dictTempDataStorage setObject:[NSString stringWithString:self.foundValue] forKey:@"artist"];
    }
    else if ([elementName isEqualToString:@"im:price"]) {
        [self.dictTempDataStorage setObject:[NSString stringWithString:self.foundValue] forKey:@"songPrice"];
    }
    else if ([elementName isEqualToString:@"id"]) {
        [self.dictTempDataStorage setObject:[NSString stringWithString:self.foundValue] forKey:@"url"];
    }
    [self.foundValue setString:@""];
}

-(void) parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    [self.foundValue appendString:string];
}

#pragma mark - Helper Methods
- (void) loadSongsListToDict {
    NSURL *url = [NSURL URLWithString:@"http://ax.itunes.apple.com/WebObjects/MZStoreServices.woa/ws/RSS/topsongs/limit=25/xml"];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes =  [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"application/atom+xml"];
    
    [manager GET:url.absoluteString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //Success
        self.xmlParser = [[NSXMLParser alloc] init];
        self.xmlParser = (NSXMLParser*)responseObject;
        self.xmlParser.delegate = self;
        self.foundValue = [[NSMutableString alloc] init];
        [self.xmlParser parse];
        //NSLog(@"Array: %@", self.arrNewsData);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //Fail
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                        message:@"No internet connection. Please, check Cellular settings."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        //NSLog(@"Error: %@", error);
    }];
}

- (void) makeSongsArray {
    self.songs = [[NSMutableArray alloc]init];
    for (int i = 0; i < self.arrNewsData.count; i++) {
        MSSong *song = [[MSSong alloc]initWithDict:self.arrNewsData[i]];
        [self.songs addObject:song];
    }
}

#pragma mark - MBProgressHUDMethod
- (void) showHudFavorites {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeCustomView;
    hud.labelText = @"Add to Favorites";
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    });
}

- (void) showHudUnFavorites {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeCustomView;
    hud.labelText = @"Delete from Favorites";
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    });
}

@end
