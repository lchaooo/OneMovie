//
//  contentView.m
//  OneMovie
//
//  Created by 李超 on 15/3/22.
//  Copyright (c) 2015年 李超. All rights reserved.
//

#import "ContentView.h"

@interface ContentView()

@end

@implementation ContentView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpImageView];
    }
    return self;
}

- (void)setUpImageView{
    _posterImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self addSubview:_posterImage];
}

@end
