//
//  FileStore.m
//  OneMovie
//
//  Created by 李超 on 15/4/27.
//  Copyright (c) 2015年 李超. All rights reserved.
//

#import "FileStore.h"

@implementation FileStore

+ (instancetype)fileStore{
    return [[self alloc] init];
}

- (id)init{
    self = [super init];
    if (self) {
        [self readMovieID];
    }
    return self;
}

- (void)readMovieID{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"MovieID" ofType:@"plist"];
    _movieIDs = [[NSMutableArray alloc] initWithContentsOfFile:plistPath];
    
}

- (NSString *)getMovieID{
    return [_movieIDs objectAtIndex:arc4random()%249];
}

@end
