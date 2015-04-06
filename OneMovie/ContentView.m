//
//  ContentView.m
//  OneMovie
//
//  Created by 李超 on 15/3/22.
//  Copyright (c) 2015年 李超. All rights reserved.
//

#import "ContentView.h"
#import <POP.h>



@implementation ContentView

- (id)initWithFrame:(CGRect)frame  {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpLabelAndImageView];
    }
    return self;
}

- (void)setUpLabelAndImageView{
    
    //    //iphone6 frame
    //    _noticeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 140, 250, 70)];
    //    //iphone 5s frame
    //    //_noticeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 140, 210, 70)];
    //    _noticeLabel.textAlignment = NSTextAlignmentCenter;
    //    _noticeLabel.text = @"松开搜索片源";
    //    _noticeLabel.alpha = 0;
    //    _noticeLabel.font = [UIFont systemFontOfSize:35];
    //    _noticeLabel.backgroundColor = [UIColor clearColor];
    //    _noticeLabel.textColor = [UIColor whiteColor];
    //    [self addSubview:_noticeLabel];
    
    
    
    _posterImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    //_posterImage.layer.anchorPoint = CGPointMake(0.5, 0);
    //_posterImage.layer.position = CGPointMake(self.frame.size.width/2, 0);
    //_posterImage.layer.transform   = [self setTransform3D];
    _posterImage.contentMode = UIViewContentModeScaleAspectFill;
    UIPanGestureRecognizer *panGesture   = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan1:)];
    [_posterImage addGestureRecognizer:panGesture];
    [self addSubview:_posterImage];
    
    _backView = [[UIView alloc]init];
    _backView.frame = _posterImage.frame;
    _backView.layer.cornerRadius = 10;
    _backView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_backView];
    UILabel *detailLabel = [[UILabel alloc]initWithFrame:CGRectMake(100, 100, 100, 100)];
    detailLabel.backgroundColor = [UIColor purpleColor];
    detailLabel.text = @"简介。。";
    [_backView addSubview:detailLabel];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap1:)];
    [_backView addGestureRecognizer:tapGesture];
    
    [self bringSubviewToFront:_posterImage];
    
    
    
}

-(void)pan1:(UIPanGestureRecognizer *)recognizer{
    CGPoint location = [recognizer locationInView:self];
    
    //    static float y_coordinate;
    //    if (y_coordinate != location.y) {
    //        y_coordinate = location.y;
    //        NSLog(@"%f",y_coordinate);
    //    }
    
    //获取手指在PageView中的初始坐标
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.initialLocation = location.x;
        [self bringSubviewToFront:_posterImage];
    }
    
    //    if (recognizer.state == UIGestureRecognizerStateEnded) {
    //
    //
    //        y_coordinate = 0.0f;
    //    }
    
    
    
    
    if (location.x<=_initialLocation) {
        if([self isLocation:location InView:self] || location.x<0){
            
            CGFloat percent = (M_PI /self.initialLocation);
            
            CATransform3D move = CATransform3DMakeTranslation(0, 0, 0.1);
            CATransform3D back = CATransform3DMakeTranslation(0, 0, 0.1);
            
            CATransform3D rotate1 = CATransform3DMakeRotation((location.x-self.initialLocation)*percent, 0, 1, 0);
            CATransform3D rotate2 = CATransform3DMakeRotation(-M_PI+(location.x-self.initialLocation)*percent, 0, 1, 0);
            
            CATransform3D mat1 = CATransform3DConcat(CATransform3DConcat(move, rotate1), back);
            CATransform3D mat2 = CATransform3DConcat(CATransform3DConcat(move, rotate2), back);
            
            _posterImage.layer.transform = CATransform3DPerspect(mat1, CGPointMake(0, 0), 800);
            _backView.layer.transform = CATransform3DPerspect(mat2, CGPointMake(0, 0), 800);
            
            
            if ((location.x-self.initialLocation)*percent < -M_PI_2 ){
                _posterImage.hidden = YES;
                _backView.hidden = NO;
            }
            else {
                _posterImage.hidden = NO;
                _backView.hidden = YES;
            }
            
            //当松手的时候，自动复原
            
            if (recognizer.state == UIGestureRecognizerStateEnded ||
                recognizer.state == UIGestureRecognizerStateCancelled) {
                if ((location.x-self.initialLocation)*percent > -M_PI/2) {
                    POPSpringAnimation *recoverAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerRotationY];
                    recoverAnimation.springBounciness = 18.0f; //弹簧反弹力度
                    recoverAnimation.dynamicsMass = 2.0f;
                    recoverAnimation.dynamicsTension = 200;
                    recoverAnimation.toValue = @(0);
                    [_posterImage.layer pop_addAnimation:recoverAnimation forKey:@"recoverAnimation"];
                    
                } else {
                    
                    
                    //                    POPSpringAnimation *recoverAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerRotationY];
                    //                    recoverAnimation.springBounciness = 18.0f; //弹簧反弹力度
                    //                    recoverAnimation.dynamicsMass = 2.0f;
                    //                    recoverAnimation.dynamicsTension = 200;
                    //                    recoverAnimation.toValue = @(0);
                    //                    [_posterImage.layer pop_addAnimation:recoverAnimation forKey:@"recoverAnimation"];
                    //                    [_backView.layer pop_addAnimation:recoverAnimation forKey:@"recoverAnimation"];
                    
                    POPSpringAnimation *exAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewSize];
                    exAnimation.springBounciness = 18.0f;
                    exAnimation.dynamicsMass = 1.0f;
                    exAnimation.dynamicsTension = 300;
                    exAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(self.frame.size.width*1.1 , self.frame.size.height*1.6 )];
                    [_backView pop_addAnimation:exAnimation forKey:@"exAnimation"];
                    
                    [UIView animateWithDuration:0.5 animations:^{
                        _backView.layer.transform = CATransform3DMakeRotation(0 , 0, 1, 0);
                        
                    }];
                }
            }
        }
    }
    if (location.x>0) {
        //手指超出边界也自动复原
        if ( location.y<0 || location.y > self.bounds.size.height || (location.x - self.initialLocation)>(CGRectGetWidth(self.bounds))-(self.initialLocation)||location.x<0) {
            recognizer.enabled = NO;
            POPSpringAnimation *recoverAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerRotationY];
            recoverAnimation.springBounciness = 18.0f; //弹簧反弹力度
            recoverAnimation.dynamicsMass = 2.0f;
            recoverAnimation.dynamicsTension = 200;
            recoverAnimation.toValue = @(0);
            [_posterImage.layer pop_addAnimation:recoverAnimation forKey:@"recoverAnimation"];
        }
        
        recognizer.enabled = YES;
    }
    
}

-(BOOL)isLocation:(CGPoint)location InView:(UIView *)view{
    if ((location.y > 0 && location.y < view.bounds.size.height) &&
        (location.x > 0 && location.x < view.bounds.size.width)) {
        return YES;
    }else{
        return NO;
    }
}

//-(CATransform3D)setTransform3D{
//    CATransform3D transform = CATransform3DIdentity;
//    transform.m34 = 2.5/-2000;
//    return transform;
//}

CATransform3D CATransform3DMakePerspective(CGPoint center, float disZ)
{
    CATransform3D transToCenter = CATransform3DMakeTranslation(-center.x, -center.y, 0);
    CATransform3D transBack = CATransform3DMakeTranslation(center.x, center.y, 0);
    CATransform3D scale = CATransform3DIdentity;
    scale.m34 = -1.0f/disZ;
    return CATransform3DConcat(CATransform3DConcat(transToCenter, scale), transBack);
}

CATransform3D CATransform3DPerspect(CATransform3D t, CGPoint center, float disZ)
{
    return CATransform3DConcat(t, CATransform3DMakePerspective(center, disZ));
}


-(void)tap1:(UIPanGestureRecognizer *)recognizer{
    POPSpringAnimation *leAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewSize];
    leAnimation.springBounciness = 18.0f;
    leAnimation.dynamicsMass = 2.0f;
    leAnimation.dynamicsTension = 200;
    leAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(self.frame.size.width , self.frame.size.height )];
    [_backView pop_addAnimation:leAnimation forKey:@"leAnimation"];
    
    
    [UIView animateWithDuration:0.5 animations:^{
        CATransform3D rotate2 = CATransform3DMakeRotation(M_PI/2, 0, 1, 0);
        _backView.layer.transform = CATransform3DPerspect(rotate2, CGPointMake(0, 0), 800);
    } completion:^(BOOL finished){
        _posterImage.hidden = NO;
        _backView.hidden = YES;
        CATransform3D rotate1 = CATransform3DMakeRotation(-M_PI/2, 0, 1, 0);
        _posterImage.layer.transform = CATransform3DPerspect(rotate1, CGPointMake(0, 0), 800);
        POPSpringAnimation *recoverAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerRotationY];
        recoverAnimation.springBounciness = 18.0f; //弹簧反弹力度
        recoverAnimation.dynamicsMass = 2.0f;
        recoverAnimation.dynamicsTension = 200;
        recoverAnimation.toValue = @(0);
        [_posterImage.layer pop_addAnimation:recoverAnimation forKey:@"recoverAnimation"];
        [self pop_removeAllAnimations];
    }
    ];

}

@end
