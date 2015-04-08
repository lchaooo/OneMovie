//
//  ContentView.m
//  OneMovie
//
//  Created by 李超 on 15/3/22.
//  Copyright (c) 2015年 李超. All rights reserved.
//

#import "ContentView.h"
#import <POP.h>
#import <YTKKeyValueStore.h>


@implementation ContentView
@synthesize scrollView;

- (id)initWithFrame:(CGRect)frame  {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpLabelAndImageView];
    }
    return self;
}

- (void)setUpLabelAndImageView{
    
    
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
    _backView.backgroundColor = [UIColor grayColor];
    [self addSubview:_backView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap1:)];
    _backView.hidden = YES;
    
    [self bringSubviewToFront:_posterImage];
    
    _noticeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.bounds.size.height+130, self.bounds.size.width, 100)];
    _noticeLabel.textAlignment = NSTextAlignmentCenter;
    _noticeLabel.text = @"   点 击 返 回";
    _noticeLabel.font = [UIFont systemFontOfSize:24];
    _noticeLabel.backgroundColor = [UIColor clearColor];
    _noticeLabel.textColor = [UIColor whiteColor];
    _noticeLabel.hidden = YES;
    [self.backView addSubview:_noticeLabel];
    _noticeLabel.userInteractionEnabled = YES;
    //[_noticeLabel addGestureRecognizer:tapGesture];
    [_backView addGestureRecognizer:tapGesture];
    
    _detailLabel = [[UILabel alloc]init];
    _detailLabel.backgroundColor = [UIColor clearColor];
    _detailLabel.textColor =  [UIColor whiteColor]  ;
    _detailLabel.numberOfLines = 0;
    
    YTKKeyValueStore *store = [[YTKKeyValueStore alloc] initDBWithName:@"details.db"];
    NSDictionary *movieDetails = [store getObjectById:@"movie" fromTable:@"detailsTable"];
    NSArray *castsArray= [NSArray arrayWithArray:[movieDetails objectForKey:@"casts"]];
    _detailLabel.text = movieDetails[@"summary"];
    _detailLabel.text = [NSString stringWithFormat:@"%@\n\n主演:",_detailLabel.text];
    for (NSDictionary *dic in castsArray) {
        _detailLabel.text = [NSString stringWithFormat:@"%@%@/",_detailLabel.text,dic[@"name"]];
    }
    _detailLabel.text = [_detailLabel.text substringToIndex:[_detailLabel.text length]-1];
    _detailLabel.numberOfLines = 0;
    UIFont *tfont = [UIFont systemFontOfSize:16.0];
    _detailLabel.font = tfont;
    NSDictionary * dic = [NSDictionary dictionaryWithObjectsAndKeys:tfont,NSFontAttributeName,nil];
    CGSize sizeText = [_detailLabel.text boundingRectWithSize:CGSizeMake(self.frame.size.width*1.1-40, 2000) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
    
        scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(20, 20, self.frame.size.width*1.1-40, self.frame.size.height-80)];
        scrollView.delegate = self;
        scrollView.showsVerticalScrollIndicator = NO;
        [_backView addSubview:scrollView];
        scrollView.contentSize = CGSizeMake(self.frame.size.width*1.1-40, sizeText.height);
        _detailLabel.frame = CGRectMake(0, 0, self.frame.size.width*1.1-40, sizeText.height);
        [scrollView addSubview:_detailLabel];
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
    
    
    CGFloat percent = (M_PI /self.initialLocation);
    
    if (location.x<=_initialLocation) {
        if([self isLocation:location InView:self] || location.x<0){
            
            
            
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
                    POPSpringAnimation *exAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewSize];
                    exAnimation.springBounciness = 18.0f;
                    exAnimation.dynamicsMass = 1.0f;
                    exAnimation.dynamicsTension = 300;
                    exAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(self.frame.size.width*1.1 , self.frame.size.height*1.6 )];
                    [_backView.layer pop_addAnimation:exAnimation forKey:@"exAnimation"];
                    
                    [UIView animateWithDuration:0.5 animations:^{
                        _backView.layer.transform = CATransform3DMakeRotation(0 , 0, 1, 0);
                        
                    }];
                    [self performSelector:@selector(changeScrollViewSize) withObject:nil afterDelay:0.1];
                    
                    _noticeLabel.hidden = NO;
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
                [_posterImage.layer pop_addAnimation:recoverAnimation forKey:@"recoverAnimation"];
                
            } else {
                POPSpringAnimation *exAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewSize];
                exAnimation.springBounciness = 18.0f;
                exAnimation.dynamicsMass = 1.0f;
                exAnimation.dynamicsTension = 300;
                exAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(self.frame.size.width*1.1 , self.frame.size.height*1.6 )];
                [_backView pop_addAnimation:exAnimation forKey:@"exAnimation"];
                
                [UIView animateWithDuration:0.5 animations:^{
                    _backView.layer.transform = CATransform3DMakeRotation(0 , 0, 1, 0);
                    
                }];
                [self performSelector:@selector(changeScrollViewSize) withObject:nil afterDelay:0.1];
                _noticeLabel.hidden = NO;
            }

        }
        
        recognizer.enabled = YES;
    }
    
}

- (void)changeScrollViewSize{
    scrollView.frame = CGRectMake(20, 20, self.frame.size.width*1.1-40, self.frame.size.height+80);
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
    scrollView.frame = CGRectMake(20, 20, self.frame.size.width*1.1-40, self.frame.size.height-80);
    _noticeLabel.hidden = YES;
}



@end
