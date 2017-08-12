//
//  XYCustomNavigationBar.h
//  Pods
//
//  Created by hongru qi on 2016/12/29.
//
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, WTBarItemType) {
    WTBarItemType_Image,
    WTBarItemType_Text,
    WTBarItemType_View,
};

@interface WTBarItem : NSObject

@property (nonatomic, assign) WTBarItemType type;
@property (nonatomic, weak) id target;
@property (nonatomic, strong) NSValue *sel;
@property (nonatomic, strong) id content;

@end

@interface WTNavigationBar : UIView

@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UIImage* bgImage;
@property(nonatomic, strong) UILabel *leftLabel;
@property(nonatomic, strong) UIButton *leftButton;
@property(nonatomic, strong) UIButton *closeButton;
@property(nonatomic, strong) UIButton *rightButton;
@property(nonatomic, strong) UIView *bottomLine;

//用于存储多个按钮
@property (nonatomic, strong) NSMutableArray *rightItems;
@property (nonatomic, strong) NSMutableArray *leftItems;
@property (nonatomic, strong) UIColor *rightButtonTextColor;

- (void)setBarTitle:(NSString *) title textSize:(CGFloat) size;
- (void)setBarTitle:(NSString *) title;
- (void)setBarTitle:(NSString *) title textSize:(CGFloat) size textColor:(UIColor *)color;
- (void)setBarLeftButtonItem:(id)target selector:(SEL)sel imageKey:(NSString *)image;
//设置导航条左按钮 （图片+文案）
- (void)setBarLeftButtonItem:(id)target selector:(SEL)sel imageKey:(NSString *)image barText:(NSString *)barText;
//刷新leftbutton文案
- (void)refreshBarLeftButtonText:(NSString *)barText;

- (void)setBarCloseTextButtonItem:(id)target selector:(SEL)sel title:(NSString *)title;
- (void)setBarRightButtonItem:(id)target selector:(SEL)sel imageKey:(NSString *)image;
- (void)setBarRightTextButtonItem:(id)target selector:(SEL)sel title:(NSString *)title;

/**
 *  导航栏右侧设置多个控件， icon或者text
 *
 *  @param items description
 */

- (void)setBarRightItems:(NSArray *)items;

- (void)setBottomLineHidden:(BOOL)hidden;

@end
