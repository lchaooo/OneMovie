//
//  Info.m
//  OneMovie
//
//  Created by 李超 on 15/4/28.
//  Copyright (c) 2015年 李超. All rights reserved.
//

#import "Info.h"
#import <YTKKeyValueStore.h>

@interface Info()
@property (strong,nonatomic) NSString *ID;
@property (strong,nonatomic) YTKKeyValueStore *store;
@end

@implementation Info
- (id)initWithID:(NSString *)ID{
    self = [super init];
    if (self) {
        _ID = ID;
        _store = [[YTKKeyValueStore alloc] initDBWithName:@"details.db"];
        NSString *tableName = @"detailsTable";
        [_store createTableWithName:tableName];
        [self setUpProperties];
    }
    return self;
}

- (void)setUpProperties{
    NSDictionary *dic = [_store getObjectById:_ID fromTable:@"detailsTable"];

    self.name = dic[@"title"];
    
    NSString *rating = [NSString stringWithFormat:@"评分：%@",dic[@"rating"][@"average"]];
    if ([rating length]>6) {
        rating = [rating substringToIndex:6];
    }
    self.rating = rating;
    
    self.posterURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",dic[@"images"][@"large"]]];
    
    if ([_ID isEqualToString:@"movie"]) {
        NSString *type = @"类型：";
        for (int i=0; i<[dic[@"genres"] count]; i++) {
            type = [type stringByAppendingString:[NSString stringWithFormat:@"%@/",[dic[@"genres"] objectAtIndex:i]]];
        }
        NSString *realType = [type substringToIndex:[type length]-1];
        self.type = realType;
        
        NSString *detail = dic[@"summary"];
        detail = [NSString stringWithFormat:@"%@\n\n主演:",detail];
        for (NSDictionary *castDic in dic[@"casts"]) {
            detail = [NSString stringWithFormat:@"%@%@/",detail,castDic[@"name"]];
        }
        detail = [detail substringToIndex:[detail length]-1];
        self.details = detail;
    } else if([_ID isEqualToString:@"book"]){
        NSString *type = @"类型：";
        for (int i=0; i<3; i++) {
            type = [type stringByAppendingString:[NSString stringWithFormat:@"%@/",[dic[@"tags"] objectAtIndex:i][@"name"]]];
        }
        NSString *realType = [type substringToIndex:[type length]-1];
        self.type = realType;
        
        NSString *detail = dic[@"summary"];
        detail = [NSString stringWithFormat:@"介绍：%@\n\n作者介绍:",detail];
        detail = [NSString stringWithFormat:@"%@%@/",detail,dic[@"author_intro"]];
        detail = [detail substringToIndex:[detail length]-1];
        self.details = detail;
    }
}

@end
