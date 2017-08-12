//
//  WTGoTopView.h
//  Pods
//
//  Created by walter on 11/08/2017.
//
//

#import <UIKit/UIKit.h>

typedef enum {
    GO_TOP_TYPE,
    SHOW_LINE_TYPE,
}HBGoTopViewType;

@protocol WTGoTopViewDelegate <NSObject>

- (void)goTopViewClicked;

@end

@interface WTGoTopView : UIView

@property (nonatomic, weak) id<WTGoTopViewDelegate> delegate;

@property (nonatomic, assign) HBGoTopViewType type;
@property (nonatomic, assign) NSInteger       totalCount;

@property (nonatomic, assign) NSInteger       currentCount;
@end
