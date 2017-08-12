//
//  WTGoTopView.m
//  Pods
//
//  Created by walter on 11/08/2017.
//
//

#import "WTGoTopView.h"
#import "UIView+WTExtend.h"
#import "WTGoTopImage.h"

@interface WTGoTopView()
{
    UIImageView *_switchTopImageView;
}
@end

@implementation WTGoTopView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor colorWithWhite:1 alpha:0.9];
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.layer.borderWidth = 0.5;
        self.layer.cornerRadius = self.viewHeight / 2.0;
        
        _switchTopImageView = [[UIImageView alloc] initWithImage:[WTGoTopImage image]];
        _switchTopImageView.center = CGPointMake(self.viewWidth / 2.0, self.viewHeight / 2.0);
        [self addSubview:_switchTopImageView];
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToTopOfView)];
        [self addGestureRecognizer:recognizer];
    }
    return self;
}

-(void)goToTopOfView
{
    if (_delegate && [_delegate respondsToSelector:@selector(goTopViewClicked)])
    {
        [_delegate goTopViewClicked];
    }
    
}

@end
