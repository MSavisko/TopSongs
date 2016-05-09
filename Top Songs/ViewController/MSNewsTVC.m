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

@interface MSNewsTVC () <NSXMLParserDelegate>
@property (strong, nonatomic) IBOutlet UITableView *newsTableView;
@property (strong, nonatomic) NSXMLParser *xmlParser;
@property (strong, nonatomic) NSMutableArray *arrNewsData;
@property (strong, nonatomic) NSMutableArray *songs;
@property (strong, nonatomic) NSMutableDictionary *dictTempDataStorage;
@property (strong, nonatomic) NSMutableString *foundValue;
@property (strong, nonatomic) NSString *currentElement;

@end

@implementation MSNewsTVC
#pragma mark - UITableViewController
- (void) viewDidLoad {
    [super viewDidLoad];
    [self loadSongsListToDict];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    MSSong *song = [[MSSong alloc]initWithDict:self.arrNewsData[indexPath.row]];
    MSSongDetailTVC *detailTVC = segue.destinationViewController;
    detailTVC.song = song;
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

#pragma mark - UITableViewDataSource
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrNewsData.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewsCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"NewsCell"];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    MSSong *song = self.songs[indexPath.row];
    cell.textLabel.text = song.title;
    cell.detailTextLabel.text = song.releaseDate;
    
    return cell;
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

@end
