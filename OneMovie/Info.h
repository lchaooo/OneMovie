//
//  Info.h
//  OneMovie
//
//  Created by 李超 on 15/4/28.
//  Copyright (c) 2015年 李超. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Info : NSObject
@property (strong,nonatomic) NSString *name;
@property (strong,nonatomic) NSString *rating;
@property (strong,nonatomic) NSString *type;
@property (strong,nonatomic) NSString *details;
@property (strong,nonatomic) NSURL *posterURL;
- (id)initWithID:(NSString *)ID;
@end
