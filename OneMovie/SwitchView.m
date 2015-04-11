//
//  SwitchView.m
//  OneMovie
//
//  Created by 俞 丽央 on 15-3-31.
//  Copyright (c) 2015年 李超. All rights reserved.
//

#import "SwitchView.h"
#import <POP.h>


@implementation SwitchView

@synthesize switchButton;
@synthesize movieLabel;
@synthesize bookLabel;

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _isMovie = YES;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    CGSize SIZE = self.bounds.size;
    

    CALayer *darkLayer = [[CALayer alloc]init];
    darkLayer.frame = CGRectMake(0, 0, SIZE.width, SIZE.height);
    darkLayer.cornerRadius = 10;
    darkLayer.opacity = 0.4;
    darkLayer.backgroundColor = [[UIColor blackColor]CGColor];
    [self.layer addSublayer:darkLayer];
    
    
    switchButton = [[UIView alloc]initWithFrame:CGRectMake(SIZE.width/12, 0, SIZE.width/3, SIZE.height)];
    switchButton.layer.cornerRadius = 10;
    switchButton.layer.opacity = 0.2;
    switchButton.layer.backgroundColor = [[UIColor whiteColor]CGColor];
    [self addSubview:switchButton];
    
    UIPanGestureRecognizer *panGesture   = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan1:)];
    [switchButton addGestureRecognizer:panGesture];
    
    movieLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0,self.bounds.size.width/2 , self.bounds.size.height)];
    movieLabel.center = CGPointMake(SIZE.width/4,SIZE.height/2);
    movieLabel.text = @"电影";
    movieLabel.textColor = [UIColor whiteColor];
    movieLabel.textAlignment = NSTextAlignmentCenter;
    movieLabel.font = [UIFont fontWithName:@"Arial" size:24];
    //movieLabel.userInteractionEnabled = YES;
    //开始时禁用 防止手势冲突
    [self addSubview:movieLabel];
    
    bookLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0,SIZE.width/2 , SIZE.height)];
    bookLabel.center = CGPointMake(SIZE.width/4*3,SIZE.height/2);
    bookLabel.text = @"图书";
    bookLabel.textColor = [UIColor whiteColor];
    bookLabel.textAlignment = NSTextAlignmentCenter;
    bookLabel.font = [UIFont fontWithName:@"Arial" size:24];
    bookLabel.userInteractionEnabled = YES;
    [self addSubview:bookLabel];
    
    //[self sendSubviewToBack:switchButton];
    
    UITapGestureRecognizer *tapGesture  = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap1:)];
    [movieLabel addGestureRecognizer:tapGesture];
    
    UITapGestureRecognizer *tapGesture2  = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap2:)];
    [bookLabel addGestureRecognizer:tapGesture2];
}


-(void)tap1:(UITapGestureRecognizer *)recognizer{
    
    [self startAnimationToLeft];
    
}

-(void)tap2:(UITapGestureRecognizer *)recognizer{
    
    [self startAnimationToRight];

}

-(void)pan1:(UIPanGestureRecognizer *)recognizer{
    CGPoint location = [recognizer locationInView:self];
    
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.initialLocation = location.x;
        self.initialcenter = switchButton.center.x;
    }
    
    if(location.x-self.initialLocation+self.initialcenter>switchButton.frame.size.width/2 && location.x-self.initialLocation+self.initialcenter<self.frame.size.width - switchButton.frame.size.width/2)
        switchButton.center =  CGPointMake(location.x-self.initialLocation+self.initialcenter , switchButton.center.y);
    
    
    
    if (recognizer.state == UIGestureRecognizerStateEnded ||
        recognizer.state == UIGestureRecognizerStateCancelled) {
        
        
        if (switchButton.center.x - self.bounds.size.width/2 < 0 ) [self startAnimationToLeft];
        else [self startAnimationToRight];
        
    }
    
    
    //滑出黑色区域时弹回
    if (location.x<switchButton.frame.size.width/2){
        recognizer.enabled = NO;
        [self startAnimationToLeft];
    }
    if (location.x>self.bounds.size.width-switchButton.frame.size.width/2){
        recognizer.enabled = NO;
        [self startAnimationToRight];
    }
    
    
    recognizer.enabled = YES;
}

- (void)startAnimationToLeft{
    [switchButton pop_removeAllAnimations];
    POPSpringAnimation *recoverAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewCenter];
    recoverAnimation.springBounciness = 10.0f; //弹簧反弹力度
    recoverAnimation.dynamicsMass = 2.0f;
    recoverAnimation.dynamicsTension = 200;
    recoverAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(self.bounds.size.width/4, switchButton.frame.size.height/2)];//将switchbutton的中心移动到label的中心 嗯
    [switchButton pop_addAnimation:recoverAnimation forKey:@"recoverAnimation"];
    movieLabel.userInteractionEnabled = NO;
    bookLabel.userInteractionEnabled = YES;
    [self SwitchtoMovie];
}

- (void)startAnimationToRight{
    [switchButton pop_removeAllAnimations];
    POPSpringAnimation *recoverAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewCenter];
    recoverAnimation.springBounciness = 10.0f; //弹簧反弹力度
    recoverAnimation.dynamicsMass = 2.0f;
    recoverAnimation.dynamicsTension = 200;
    recoverAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(self.bounds.size.width/4*3, switchButton.frame.size.height/2)];//将switchbutton的中心移动到label的中心 嗯
    [switchButton pop_addAnimation:recoverAnimation forKey:@"recoverAnimation"];
    movieLabel.userInteractionEnabled = YES;
    bookLabel.userInteractionEnabled = NO;
    [self SwitchtoBook];
}

- (void)SwitchtoMovie{
    if (self.isMovie == NO) {
        NSLog(@"SwitchtoMovie");
        self.isMovie = YES;
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

- (void)SwitchtoBook{
    if (self.isMovie == YES){
        NSLog(@"SwitchtoBook");
        self.isMovie = NO;
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}



@end
