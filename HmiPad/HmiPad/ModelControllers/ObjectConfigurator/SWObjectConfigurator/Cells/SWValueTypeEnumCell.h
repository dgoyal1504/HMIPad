//
//  SWValueTypeEnumCell.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 6/20/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWValueCell.h"

extern NSString * const SWValueTypeEnumCellIdentifier;
extern NSString * const SWValueTypeEnumCellNibName;
extern NSString * const SWValueTypeEnumCellNibName6;

@class SWValueTypeEnumCell;

@protocol SWValueTypeEnumCellDelegate <SWValueCellDelegate>

- (NSArray*)optionsForEnumCell:(SWValueTypeEnumCell*)enumCell;

@end


@interface SWValueTypeEnumCell : SWValueCell <UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIButton *valueButton;
@property (nonatomic, weak) id<SWValueTypeEnumCellDelegate> delegate;

- (IBAction)valueButtonPushed:(id)sender;

@end
