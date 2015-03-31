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

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

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
    
    
    
    UILabel *movieLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0,self.bounds.size.width/2 , self.bounds.size.height)];
    movieLabel.center = CGPointMake(SIZE.width/4,SIZE.height/2);
    movieLabel.text = @"电影";
    movieLabel.textColor = [UIColor whiteColor];
    movieLabel.textAlignment = NSTextAlignmentCenter;
    movieLabel.font = [UIFont fontWithName:@"Arial" size:24];
    [self addSubview:movieLabel];
    
    UILabel *bookLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0,SIZE.width/2 , SIZE.height)];
    bookLabel.center = CGPointMake(SIZE.width/4*3,SIZE.height/2);
    bookLabel.text = @"图书";
    bookLabel.textColor = [UIColor whiteColor];
    bookLabel.textAlignment = NSTextAlignmentCenter;
    bookLabel.font = [UIFont fontWithName:@"Arial" size:24];
    [self addSubview:bookLabel];
    
}

-(void)pan1:(UIPanGestureRecognizer *)recognizer{
    CGPoint location = [recognizer locationInView:self];
    
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.initialLocation = location.x;
        self.initialcenter = switchButton.center.x;
    }
    
    switchButton.center =  CGPointMake(location.x-self.initialLocation+self.initialcenter , switchButton.center.y);
    
    
    
    if (recognizer.state == UIGestureRecognizerStateEnded ||
        recognizer.state == UIGestureRecognizerStateCancelled) {
        
        
        if (switchButton.center.x - self.bounds.size.width/2 < 0 ){
            POPSpringAnimation *recoverAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewCenter];
            recoverAnimation.springBounciness = 18.0f; //弹簧反弹力度
            recoverAnimation.dynamicsMass = 2.0f;
            recoverAnimation.dynamicsTension = 200;
            recoverAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(self.bounds.size.width/4, switchButton.frame.size.height/2)];//将switchbutton的中心移动到label的中心 嗯
            [switchButton pop_addAnimation:recoverAnimation forKey:@"recoverAnimation"];
        }
        else{
            POPSpringAnimation *recoverAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewCenter];
            recoverAnimation.springBounciness = 18.0f; //弹簧反弹力度
            recoverAnimation.dynamicsMass = 2.0f;
            recoverAnimation.dynamicsTension = 200;
            recoverAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(self.bounds.size.width/4*3, switchButton.frame.size.height/2)];//将switchbutton的中心移动到label的中心 嗯
            [switchButton pop_addAnimation:recoverAnimation forKey:@"recoverAnimation"];
        }
    }
    
    
    //滑出黑色区域时弹回
    if (location.x<switchButton.frame.size.width/2){
        recognizer.enabled = NO;
        POPSpringAnimation *recoverAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewCenter];
        recoverAnimation.springBounciness = 18.0f; //弹簧反弹力度
        recoverAnimation.dynamicsMass = 2.0f;
        recoverAnimation.dynamicsTension = 200;
        recoverAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(self.bounds.size.width/4, switchButton.frame.size.height/2)];//将switchbutton的中心移动到label的中心 嗯
        [switchButton pop_addAnimation:recoverAnimation forKey:@"recoverAnimation"];
    }
    if (location.x>self.bounds.size.width-switchButton.frame.size.width/2){
        recognizer.enabled = NO;
        POPSpringAnimation *recoverAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewCenter];
        recoverAnimation.springBounciness = 18.0f; //弹簧反弹力度
        recoverAnimation.dynamicsMass = 2.0f;
        recoverAnimation.dynamicsTension = 200;
        recoverAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(self.bounds.size.width/4*3, switchButton.frame.size.height/2)];//将switchbutton的中心移动到label的中心 嗯
        [switchButton pop_addAnimation:recoverAnimation forKey:@"recoverAnimation"];
    }
    
    
    recognizer.enabled = YES;
}




@end
