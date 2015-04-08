//
//  WebModel.h
//  OneMovie
//
//  Created by 李超 on 15/3/21.
//  Copyright (c) 2015年 李超. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebModel : NSObject

- (void)getMovieDictionaryByMovieID:(NSString *)ID;
- (void)getBookIDByBookTag;

@end
