//
//  MovieView.m
//  OneMovie
//
//  Created by 李超 on 15/3/30.
//  Copyright (c) 2015年 李超. All rights reserved.
//

#import "MovieView.h"
#import "ContentView.h"

@interface MovieView()
@property (strong,nonatomic) ContentView *contentView;
@end

@implementation MovieView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubView];
    }
    return self;
}

- (void)setupSubView{
    _contentView = [[ContentView alloc] initWithFrame:CGRectMake(self.frame.size.width*0.175, 0, self.frame.size.width*0.65, self.frame.size.width*0.65*17/12)];
    _contentView.backgroundColor = [UIColor blackColor];
    [self addSubview:_contentView];
}

@end
