//
//  FileStore.h
//  OneMovie
//
//  Created by 李超 on 15/4/27.
//  Copyright (c) 2015年 李超. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileStore : NSObject
+ (instancetype)fileStore;
@property (strong,nonatomic) NSArray *movieIDs;
- (NSString *)getMovieID;
@end
