//
//  SWTableViewMessage.h
//  HmiPad
//
//  Created by Joan on 25/08/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    TableViewMessageStyleSectionFooter,
    TableViewMessageStylePlainSectionFooter,
    TableViewMessageStyleTableFooter,
    TableViewMessageStyleTableHeader,
}
TableViewMessageStyle;

@interface SWTableViewMessage : UIView
{
    NSString *_message;
    UILabel *_messageViewLabel;
    UIImageView *_imageView;
    UILabel *_emptyLabel;
}

@property (nonatomic, retain) NSString *emptyTitle;
@property (nonatomic, retain) NSString *emptyMessage;
@property (nonatomic, retain) NSString *message;
@property (nonatomic, readonly) UILabel *messageViewLabel;
@property (nonatomic) BOOL darkContext;

- (id)initForSectionFooter;
- (id)initForPlainSectionFooter;
- (id)initForTableFooter;
- (id)initForTableHeader;

- (id)initWithFooterStyle:(TableViewMessageStyle)style initialWidth:(CGFloat)width;

- (void)showForEmptyTable:(BOOL)empty;

- (CGFloat)getMessageHeight;

@end
