//
//  WebModel.h
//  OneMovie
//
//  Created by 李超 on 15/3/21.
//  Copyright (c) 2015年 李超. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Info.h"

@interface WebModel : NSObject
@property (strong,nonatomic) Info *movieInfo;
@property (strong,nonatomic) Info *bookInfo;
- (void)getMovieDictionaryByMovieID:(NSString *)ID;
- (void)getBookIDByBookTag;

@end
