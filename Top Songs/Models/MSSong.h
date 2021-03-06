//
//  MSSong.h
//  Top Songs
//
//  Created by Maksym Savisko on 5/8/16.
//  Copyright © 2016 Maksym Savisko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSSong : NSObject
@property (strong, readonly, nonatomic) NSString *artist;
@property (strong, readonly, nonatomic) NSString *name;
@property (strong, readonly, nonatomic) NSString *title;
@property (strong, readonly, nonatomic) NSString *collectionName;
@property (strong, readonly, nonatomic) NSString *releaseDate;
@property (strong, readonly, nonatomic) NSString *price;
@property (strong, readonly, nonatomic) NSURL *url;
@property (strong, readonly, nonatomic) NSURL *imageUrl;
@property (strong, readonly, nonatomic) NSURL *imagePath;
@property (nonatomic) BOOL isFavorite;

- (instancetype) initWithDict:(NSDictionary*)dict;
- (void) setImagePath:(NSURL *)imagePath;

@end
