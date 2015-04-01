//
//  WebModel.m
//  OneMovie
//
//  Created by 李超 on 15/3/21.
//  Copyright (c) 2015年 李超. All rights reserved.
//

#import "WebModel.h"
#import <AFNetworking.h>
#import <YTKKeyValueStore.h>

@interface WebModel ()
@property (strong,nonatomic) YTKKeyValueStore *store;
@end

@implementation WebModel

- (id)init{
    self = [super init];
    if (self) {
        _store = [[YTKKeyValueStore alloc] initDBWithName:@"details.db"];
        NSString *tableName = @"detailsTable";
        [_store createTableWithName:tableName];
    }
    return self;
}

//获取电影信息并储存
- (void)getMovieDictionaryByMovieID:(NSString *)ID{
    NSString *path = [NSString stringWithFormat:@"https://api.douban.com/v2/movie/subject/%@",ID];
    NSURL *url = [NSURL URLWithString:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    requestOperation.responseSerializer = [AFJSONResponseSerializer serializer];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation,id responseData){
        NSDictionary *dic = (NSDictionary *)responseData;
        NSString *id = @"movie";
        [_store putObject:dic withId:id intoTable:@"detailsTable"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MovieDictionary has been downloaded" object:nil];
    }failure:^(AFHTTPRequestOperation *operation,NSError *error){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Net is not working" object:nil];
    }];
    [requestOperation start];
}

- (void)getBookDictionaryByBookTag:(NSString *)tag{
    int j = arc4random()%181;
    NSString *start = [NSString stringWithFormat:@"%d",j];
    NSString *path = [NSString stringWithFormat:@"https://api.douban.com/v2/book/search?start=%@&tag=%@" ,start, tag];
    NSURL *url = [NSURL URLWithString:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    requestOperation.responseSerializer = [AFJSONResponseSerializer serializer];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation,id responseData){
        NSDictionary *dic = (NSDictionary *)responseData;
        NSString *id = @"book";
        [_store putObject:dic withId:id intoTable:@"detailsTable"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"BookDictionary has been downloaded" object:nil];
    }failure:^(AFHTTPRequestOperation *operation,NSError *error){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Net is not working" object:nil];
    }];
    [requestOperation start];
    
}
@end
