//
//  MSNewsTVC.m
//  Top Songs
//
//  Created by Maksym Savisko on 5/7/16.
//  Copyright © 2016 Maksym Savisko. All rights reserved.
//

#import "MSNewsTVC.h"

#import "XMLDictionary.h"
#import "AFNetworking.h"

@interface MSNewsTVC ()
@end

@implementation MSNewsTVC
#pragma mark - UIViewController
- (void) viewDidLoad {
    [super viewDidLoad];
    [self loadSongsList];
}


#pragma mark - Helper Methods
- (void) loadSongsList {
    NSURL *url = [NSURL URLWithString:@"http://ax.itunes.apple.com/WebObjects/MZStoreServices.woa/ws/RSS/topsongs/limit=25/xml"];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes =  [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"application/atom+xml"];
    
    [manager GET:url.absoluteString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //Success
        NSDictionary *d0 = [NSDictionary dictionaryWithXMLParser:(NSXMLParser*)responseObject];
        NSLog(@"Resonse object: %@", (NSXMLParser*)responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //Fail
        NSLog(@"Error: %@", error);
    }];
}

@end
