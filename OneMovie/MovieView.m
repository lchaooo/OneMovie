//
//  MovieView.m
//  OneMovie
//
//  Created by 俞 丽央 on 15-4-4.
//  Copyright (c) 2015年 李超. All rights reserved.
//

#import "MovieView.h"
#import <POP.h>

@interface MovieView()
@property (nonatomic) NSUInteger      initialLocation;
@end

@implementation MovieView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpLayOut];
    }
    return self;
}

- (void)setUpLayOut{
    _contentView = [[ContentView alloc] initWithFrame:CGRectMake(10, 10, 300, 425)];
    _contentView.userInteractionEnabled = YES;
    [self addSubview:_contentView];
    
    _contentView.posterImage.image = [UIImage imageNamed:@"p1910907404.jpg"];
    UIPanGestureRecognizer *panGesture   = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan1:)];
    [_contentView.posterImage addGestureRecognizer:panGesture];
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
        [self bringSubviewToFront:_contentView.posterImage];
    }
    
    //    if (recognizer.state == UIGestureRecognizerStateEnded) {
    //
    //
    //        y_coordinate = 0.0f;
    //    }
    
    
    CGFloat percent = (M_PI /self.initialLocation);
    
    if (location.x<=_initialLocation) {
        if([self isLocation:location InView:self] || location.x<0){
            
            CATransform3D move = CATransform3DMakeTranslation(0, 0, 0.1);
            CATransform3D back = CATransform3DMakeTranslation(0, 0, 0.1);
            
            CATransform3D rotate1 = CATransform3DMakeRotation((location.x-self.initialLocation)*percent, 0, 1, 0);
            CATransform3D rotate2 = CATransform3DMakeRotation(-M_PI+(location.x-self.initialLocation)*percent, 0, 1, 0);
            
            CATransform3D mat1 = CATransform3DConcat(CATransform3DConcat(move, rotate1), back);
            CATransform3D mat2 = CATransform3DConcat(CATransform3DConcat(move, rotate2), back);
            
            _contentView.posterImage.layer.transform = CATransform3DPerspect(mat1, CGPointMake(0, 0), 800);
            _contentView.backView.layer.transform = CATransform3DPerspect(mat2, CGPointMake(0, 0), 800);
            
            if ((location.x-self.initialLocation)*percent < -M_PI_2 ){
                _contentView.posterImage.hidden = YES;
                _contentView.backView.hidden = NO;
            }
            else {
                _contentView.posterImage.hidden = NO;
                _contentView.backView.hidden = YES;
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
                    [_contentView.posterImage.layer pop_addAnimation:recoverAnimation forKey:@"recoverAnimation"];
                    
                } else {
                    POPSpringAnimation *exAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewSize];
                    exAnimation.springBounciness = 18.0f;
                    exAnimation.dynamicsMass = 1.0f;
                    exAnimation.dynamicsTension = 300;
                    exAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(self.frame.size.width*1.1 , self.frame.size.height*1.6 )];
                    [_contentView.backView.layer pop_addAnimation:exAnimation forKey:@"exAnimation"];
                    
                    [UIView animateWithDuration:0.5 animations:^{
                        _contentView.backView.layer.transform = CATransform3DMakeRotation(0 , 0, 1, 0);
                        
                    }];
                    [self performSelector:@selector(changeScrollViewSize) withObject:nil afterDelay:0.1];
                    
                    _contentView.noticeLabel.hidden = NO;
                }
            }
        }
    }
    if (location.x>0) {
        //手指超出边界也自动复原
        if ( location.y<0 || location.y > self.bounds.size.height || (location.x - self.initialLocation)>(CGRectGetWidth(self.bounds))-(self.initialLocation)||location.x<0) {
            recognizer.enabled = NO;
            
            
            if ((location.x-self.initialLocation)*percent > -M_PI/2) {
                POPSpringAnimation *recoverAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerRotationY];
                recoverAnimation.springBounciness = 18.0f; //弹簧反弹力度
                recoverAnimation.dynamicsMass = 2.0f;
                recoverAnimation.dynamicsTension = 200;
                recoverAnimation.toValue = @(0);
                [_contentView.posterImage.layer pop_addAnimation:recoverAnimation forKey:@"recoverAnimation"];
                
            } else {
                POPSpringAnimation *exAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewSize];
                exAnimation.springBounciness = 18.0f;
                exAnimation.dynamicsMass = 1.0f;
                exAnimation.dynamicsTension = 300;
                exAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(self.frame.size.width*1.1 , self.frame.size.height*1.6 )];
                [_contentView.backView pop_addAnimation:exAnimation forKey:@"exAnimation"];
                
                [UIView animateWithDuration:0.5 animations:^{
                    _contentView.backView.layer.transform = CATransform3DMakeRotation(0 , 0, 1, 0);
                    
                }];
                [self performSelector:@selector(changeScrollViewSize) withObject:nil afterDelay:0.1];
                _contentView.noticeLabel.hidden = NO;
            }
            
        }
        
        recognizer.enabled = YES;
    }
    
}

- (void)changeScrollViewSize{
    _contentView.scrollView.frame = CGRectMake(20, 20, self.frame.size.width*1.1-40, self.frame.size.height+80);
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



@end
