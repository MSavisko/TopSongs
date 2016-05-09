//
//  MSSong.m
//  Top Songs
//
//  Created by Maksym Savisko on 5/8/16.
//  Copyright © 2016 Maksym Savisko. All rights reserved.
//

#import "MSSong.h"

@implementation MSSong
- (instancetype) initWithDict:(NSDictionary*)dict {
    self = [super init];
    if (self) {
        _artist = dict[@"artist"];
        _title = dict[@"title"];
        _collectionName = dict[@"collectionName"];
        _releaseDate = dict[@"releaseDate"];
        _price = dict[@"songPrice"];
        _url = [[NSURL alloc]initWithString:dict[@"url"]];
        _imageUrl = [[NSURL alloc]initWithString:dict[@"imageUrl"]];
        
        NSString *name = [_title substringToIndex:[_title length] - [_artist length] - 3];
        _name = name;
        _imagePath = nil;
    }
    return self;
}

- (void) setImagePath:(NSURL *)imagePath {
    _imagePath = imagePath;
}

@end
