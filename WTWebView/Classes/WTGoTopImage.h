//
//  StyleKit.h
//
//  Created on 11/08/2017.
//
//  Generated by PaintCode Plugin for Sketch
//  http://www.paintcodeapp.com/sketch
//

@import UIKit;

@interface WTGoTopImage : NSObject


#pragma mark - Resizing Behavior

typedef enum : NSInteger {
    StyleKitResizingBehaviorAspectFit, //!< The content is proportionally resized to fit into the target rectangle.
    StyleKitResizingBehaviorAspectFill, //!< The content is proportionally resized to completely fill the target rectangle.
    StyleKitResizingBehaviorStretch, //!< The content is stretched to match the entire target rectangle.
    StyleKitResizingBehaviorCenter, //!< The content is centered in the target rectangle, but it is NOT resized.
} StyleKitResizingBehavior;

extern CGRect StyleKitResizingBehaviorApply(StyleKitResizingBehavior behavior, CGRect rect, CGRect target);


#pragma mark - Canvas Drawings

//! Page 1
+ (void)drawPage1;

//! Symbols
+ (void)drawIc_go_top2x;
+ (void)drawIc_go_top2xWithFrame:(CGRect)targetFrame resizing:(StyleKitResizingBehavior)resizing;


#pragma mark - Canvas Images

//! Symbols
+ (UIImage *)image;


@end