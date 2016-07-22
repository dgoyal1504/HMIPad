//
//  SWValueTypeRectCell.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 6/8/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWValueCell.h"
#import "SWItem.h"

@class ValueTextView ;

extern NSString * const SWValueTypeRectCellIdentifier;
extern NSString * const SWValueTypeRectCellNibName;

@interface SWValueTypeRectCell : SWValueCell

@property (weak, nonatomic) IBOutlet ValueTextView *fieldX;
@property (weak, nonatomic) IBOutlet ValueTextView *fieldY;
@property (weak, nonatomic) IBOutlet ValueTextView *fieldWidth;
@property (weak, nonatomic) IBOutlet ValueTextView *fieldHeight;

@property (weak, nonatomic) IBOutlet UILabel *originLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;


//- (CGRect)rect;

@property (nonatomic, assign) SWItemResizeMask resizeMask;

@end
