//
//  SWFlowViewItem.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 2/8/12.
//  Copyright (c) 2012 SweetWilliam SL. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    SWFlowViewItemEditingStyleNone,
    SWFlowViewItemEditingStyleInsert,
    SWFlowViewItemEditingStyleDelete
} SWFlowViewItemEditingStyle;

typedef enum {
    SWFlowViewItemStyleDefault
} SWFlowViewItemStyle;

@interface SWFlowViewItem : UIView

// -- Initializers -- //
- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier;
@property (nonatomic, readonly, strong) NSString *reuseIdentifier;

// -- Reusing Items -- //
- (void)prepareForReuse;

- (void)enableUserInteraction;
- (void)disableUserInteraction;

// -- Accessing Views of the Item Object -- //
@property (strong, nonatomic) UIView *contentView;

// -- Editing the Item -- //
@property (assign, nonatomic, getter = isEditing) BOOL editing;
@property(nonatomic, readonly) SWFlowViewItemEditingStyle editingStyle;


@end
