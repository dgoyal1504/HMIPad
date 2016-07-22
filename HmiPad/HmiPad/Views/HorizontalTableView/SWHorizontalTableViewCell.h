//
//  SWHorizontalTableViewCell.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 3/27/12.
//  Copyright (c) 2012 Sweet William SL. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SWCrossView;

typedef enum {
    SWHorizontalTableViewCellStyleDefault,
    SWHorizontalTableViewCellStyleImage
    //SWHorizontalTableViewCellStyleValue1,
    //SWHorizontalTableViewCellStyleValue2,
    //SWHorizontalTableViewCellStyleSubtitle
} SWHorizontalTableViewCellStyle;   

typedef enum {
    SWHorizontalTableViewCellSelectionStyleNone,
    SWHorizontalTableViewCellSelectionStyleBlue,
    SWHorizontalTableViewCellSelectionStyleGray
} SWHorizontalTableViewCellSelectionStyle;

typedef enum {
    SWHorizontalTableViewCellEditingStyleNone,
    SWHorizontalTableViewCellEditingStyleDelete,
    SWHorizontalTableViewCellEditingStyleInsert
} SWHorizontalTableViewCellEditingStyle;

@interface SWHorizontalTableViewCell : UIView {
    UIColor *_lastColor;
    SWCrossView *_crossButton;
}

- (id)initWithStyle:(SWHorizontalTableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@property(nonatomic,readonly,copy) NSString *reuseIdentifier;

- (void)prepareForReuse;

@property(nonatomic, readonly, assign) SWHorizontalTableViewCellStyle style;
@property(nonatomic) SWHorizontalTableViewCellSelectionStyle selectionStyle; // default is SWHorizontalTableViewCellSelectionStyleBlue.
@property(nonatomic,getter=isSelected) BOOL selected;

- (void)setSelected:(BOOL)selected animated:(BOOL)animated;

@property(nonatomic,getter=isEditing) BOOL editing;
- (void)setEditing:(BOOL)editing animated:(BOOL)animated;

@property (nonatomic, readonly, strong) UIImageView *imageView;
@property (nonatomic, readonly, strong) UILabel *textLabel;

@end
