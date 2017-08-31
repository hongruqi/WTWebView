//
//  XYCustomNavigationBar.m
//  Pods
//
//  Created by hongru qi on 2016/12/29.
//
//

#import "WTNavigationBar.h"
#import "UIView+WTExtend.h"
#import "NSBundle+WTWebView.h"

#define maxItemCount 2

//iPhone 默认导航条高度
static const CGFloat kNavigationBarHeight = 44;
/**
 1、图片按钮宽度固定35，icon建议20x20，居中显示；
 2、左右第一个按钮距边缘7.5，多个按钮连续靠在一起摆放
 3、text按钮宽度为：text的宽度 + 15.0
 */
static const CGFloat imageButtonWidth = 70.0 / 2;
static const CGFloat textButtonMargin = 30.0 / 2;
static const CGFloat edgeSpace =  15.0 / 2;


@implementation WTBarItem

@end


@interface WTNavigationBar ()

@property (nonatomic, strong) UIButton *rightImgButton;

@end

@implementation WTNavigationBar

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        // Initialization code
        self.rightItems = [NSMutableArray new];
        self.leftItems = [NSMutableArray new];
        self.clipsToBounds = NO;
        //导航条下方加阴影
        // [self dropShadowWithOffset:CGSizeMake(0, 0.6) radius:0.6 color:[UIColor blackColor] opacity:0.3];
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height - 0.6, frame.size.width, 0.6)];
        line.hidden = YES;
        
        NSNumber *isHiddenBottomLine = [[NSUserDefaults standardUserDefaults] objectForKey:@"isHideBottomLineOfNavigationBar"];
        if (isHiddenBottomLine) {
            line.hidden = isHiddenBottomLine.boolValue;
        }
        
        [self addSubview:line];
        _bottomLine = line;
        
        [self addSubview:self.titleLabel];
    }
    return self;
}

- (void)setBarTitle:(NSString *)title
{
    [self setBarTitle:title textSize:18.0];
}

// 设置导航条标题
- (void)setBarTitle:(NSString *)title textSize:(CGFloat)size
{
    [self setBarTitle:title textSize:size textColor:[UIColor blackColor]];
}

- (void)setBarTitle:(NSString *)title textSize:(CGFloat)size textColor:(UIColor *)color
{
    if (_titleLabel == nil) {
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.backgroundColor = [UIColor clearColor];
        
        titleLabel.frame = CGRectMake(80, self.height - kNavigationBarHeight, self.width - 160, kNavigationBarHeight);
        titleLabel.centerX = self.width / 2;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.adjustsFontSizeToFitWidth = YES;
        titleLabel.minimumScaleFactor = (size - 2) / [UIFont labelFontSize];
        [self addSubview:titleLabel];
        _titleLabel = titleLabel;
    }
    
    _titleLabel.textColor = color;
    _titleLabel.font = [UIFont systemFontOfSize:size];
    _titleLabel.minimumScaleFactor = (size - 2)/ [UIFont labelFontSize];
    _titleLabel.text = title;
}

/**
 *  按钮图标大小为40x40，为了扩大点击区域，按钮实际大小为70x88，图标居中显示，按钮间间距为30
 *
 */

// 设置导航条左按钮
- (void)setBarLeftButtonItem:(id)target selector:(SEL)sel imageKey:(NSString *)image
{
    if (_leftButton) {
        [_leftButton removeFromSuperview];
    }
    NSBundle *bundle = [NSBundle wt_webViewBundle];
    UIImage *normalImage = [UIImage imageNamed:image inBundle:bundle compatibleWithTraitCollection:nil];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(edgeSpace, self.height - kNavigationBarHeight, imageButtonWidth, kNavigationBarHeight)];
    [button setImage:normalImage forState:UIControlStateNormal];
    if (target && sel) {
        [button addTarget:target action:sel forControlEvents:UIControlEventTouchUpInside];
    }
    [self addSubview:button];
    _leftButton = button;
}

//设置导航条左按钮 （图片+文案）
- (void)setBarLeftButtonItem:(id)target selector:(SEL)sel imageKey:(NSString *)image barText:(NSString *)barText
{
    if (_leftButton) {
        [_leftButton removeFromSuperview];
    }
    
    UIImage *normalImage = [UIImage imageNamed:image];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(15.0 / 2, self.height - kNavigationBarHeight, 100, kNavigationBarHeight)];
    button.clipsToBounds = NO;
    [button setImage:normalImage forState:UIControlStateNormal];
    if (target && sel) {
        [button addTarget:target action:sel forControlEvents:UIControlEventTouchUpInside];
    }
    [button setTitle:barText forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:15.0];
    button.titleEdgeInsets = UIEdgeInsetsMake(0, 6, 0, 0);
    [self addSubview:button];
    _leftButton = button;
}

//刷新leftbutton文案
- (void)refreshBarLeftButtonText:(NSString *)barText
{
    [_leftButton setTitle:barText forState:UIControlStateNormal];
}

- (void)setBarCloseTextButtonItem:(id)target selector:(SEL)sel title:(NSString *)title
{
    if (_closeButton) {
        [_closeButton removeFromSuperview];
    }
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectZero];
    CGSize size = [title sizeWithAttributes:@{NSFontAttributeName:button.titleLabel.font}];
    button.frame = CGRectMake(85.0 / 2, self.height - kNavigationBarHeight, size.width + textButtonMargin, kNavigationBarHeight);
    [button setTitle:title forState:UIControlStateNormal];
    if (target && sel) {
        [button addTarget:target action:sel forControlEvents:UIControlEventTouchUpInside];
    }
    [self addSubview:button];
    _closeButton = button;
    
    self.titleLabel.width = self.width - (button.right + 3) * 2;
    self.titleLabel.centerX = self.width / 2;
}

- (void)setBarRightButtonItem:(id)target selector:(SEL)sel imageKey:(NSString *)image
{
    if (_rightButton) {
        [_rightButton removeFromSuperview];
    }
    NSBundle *bundle = [NSBundle wt_webViewBundle];
    UIImage *normalImage = [UIImage imageNamed:image inBundle:bundle compatibleWithTraitCollection:nil];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake([[UIScreen mainScreen]bounds].size.width  - edgeSpace - imageButtonWidth, self.height - kNavigationBarHeight, imageButtonWidth, kNavigationBarHeight)];
    [button setImage:normalImage forState:UIControlStateNormal];
    [button setImageEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
    if (target && sel) {
        [button addTarget:target action:sel forControlEvents:UIControlEventTouchUpInside];
    }
    _rightButton = button;
    [self addSubview:_rightButton];
}

- (void)setBarRightTextButtonItem:(id)target selector:(SEL)sel title:(NSString *)title
{
    if (_rightButton) {
        [_rightButton removeFromSuperview];
    }
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectZero];
    CGSize size = [title sizeWithAttributes:@{NSFontAttributeName:button.titleLabel.font}];
    button.frame = CGRectMake([[UIScreen mainScreen]bounds].size.width - size.width - textButtonMargin - edgeSpace, self.height - kNavigationBarHeight, size.width + textButtonMargin, kNavigationBarHeight);
    
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:16.0];
    if (target && sel) {
        [button addTarget:target action:sel forControlEvents:UIControlEventTouchUpInside];
    }
    [self addSubview:button];
    _rightButton = button;
}

- (void)setBarRightItems:(NSArray *)items
{
    for (UIView *button in self.rightItems) {
        [button removeFromSuperview];
    }
    [self.rightItems removeAllObjects];
    
    for (int i = 0; i < items.count && i < maxItemCount; i++) {
        WTBarItem *item = items[i];
        switch (item.type) {
            case WTBarItemType_Text:
            {
                UIButton *button = [[UIButton alloc] initWithFrame:CGRectZero];
                CGSize size = [item.content sizeWithAttributes:@{NSFontAttributeName:button.titleLabel.font}];
                button.frame = CGRectMake([[UIScreen mainScreen]bounds].size.width - size.width - textButtonMargin - edgeSpace, self.height - kNavigationBarHeight, size.width + textButtonMargin, kNavigationBarHeight);
                
                [button setTitle:item.content forState:UIControlStateNormal];
                button.titleLabel.font = [UIFont systemFontOfSize:16.0];
                if (item.target && item.sel) {
                    [button addTarget:item.target action:(SEL)([item.sel pointerValue]) forControlEvents:UIControlEventTouchUpInside];
                }
                [self addSubview:button];
                [self.rightItems addObject:button];
            }
                break;
            case WTBarItemType_Image:
            {
                UIImage *normalImage = [UIImage imageNamed:item.content];
                UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake([[UIScreen mainScreen]bounds].size.width - edgeSpace - imageButtonWidth, self.height - kNavigationBarHeight, imageButtonWidth, kNavigationBarHeight)];
                [button setImage:normalImage forState:UIControlStateNormal];
                if (item.target && item.sel) {
                    [button addTarget:item.target action:(SEL)([item.sel pointerValue]) forControlEvents:UIControlEventTouchUpInside];
                }
                [self addSubview:button];
                [self.rightItems addObject:button];
            }
                break;
            default:
                break;
        }
    }
    if (self.rightItems.count > 1) {
        for (int i = 1; i < self.rightItems.count ; i++) {
            UIView *preView = self.rightItems[i - 1];
            UIView *curView = self.rightItems[i];
            curView.right = preView.left;
        }
    }
}

- (void)setBottomLineHidden:(BOOL)hidden
{
    self.bottomLine.hidden = hidden;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont systemFontOfSize:18];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.frame = CGRectMake(0, self.height - kNavigationBarHeight, [[UIScreen mainScreen]bounds].size.width / 2, kNavigationBarHeight);
        _titleLabel.centerX = [[UIScreen mainScreen]bounds].size.width / 2;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.adjustsFontSizeToFitWidth = YES;
        _titleLabel.minimumScaleFactor = 14 / [UIFont labelFontSize];
    }
    
    return _titleLabel;
}


- (void)dropShadowWithOffset:(CGSize)offset radius:(CGFloat)radius color:(UIColor *)color opacity:(CGFloat)opacity
{
    // Creating shadow path for better performance
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.bounds);
    self.layer.shadowPath = path;
    CGPathCloseSubpath(path);
    CGPathRelease(path);
    
    self.layer.shadowColor = color.CGColor;
    self.layer.shadowOffset = offset;
    self.layer.shadowRadius = radius;
    self.layer.shadowOpacity = opacity;
}

- (void)drawRect:(CGRect)rect {
    if (self.bgImage == nil) {
        [super drawRect:rect];
    } else {
        [self.bgImage drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        self.backgroundColor = [UIColor colorWithPatternImage:self.bgImage];
    }
}

// 绘制圆角
- (void)drawRoundedCorner:(CGPoint)point withRadius:(CGFloat)radius withTransformation:(CGAffineTransform)transform
{
    // create the path. has to be done this way to allow use of the transform
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, &transform, point.x, point.y);
    CGPathAddLineToPoint(path, &transform, point.x, point.y + radius);
    CGPathAddArc(path, &transform, point.x + radius, point.y + radius, radius, (180) * M_PI/180, (-90) * M_PI/180, 0);
    CGPathAddLineToPoint(path, &transform, point.x, point.y);
    
    // fill the path to create the illusion that the corner is rounded
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextAddPath(context, path);
    CGContextSetFillColorWithColor(context, [[UIColor blackColor] CGColor]);
    CGContextFillPath(context);
    
    // appropriate memory management
    CGPathRelease(path);
}
@end
