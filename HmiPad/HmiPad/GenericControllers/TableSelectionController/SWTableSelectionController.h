//
//  SWTableSelectionController.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 3/22/12.
//  Copyright (c) 2012 Sweet William SL. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SWTableSelectionController;

@protocol SWTableSelectionControllerDelegate <NSObject>

@optional
- (void)tableSelection:(SWTableSelectionController*)controller didSelectOptionAtIndex:(NSInteger)index;
- (void)tableSelection:(SWTableSelectionController*)controller didSelectOption:(NSString*)option;

@end

@interface SWTableSelectionController : UITableViewController

//- (id)initWithStyle:(UITableViewStyle)style andOptions:(NSArray*)options;
- (id)initWithStyle:(UITableViewStyle)style options:(NSArray*)options;
- (void)setPreferredContentSizeForViewInPopover;

@property (nonatomic, readonly, strong) NSArray *swoptions;
@property (nonatomic, assign) NSInteger swtag0;   // normalment hi posarem la section
@property (nonatomic, assign) NSInteger swtag1;   // normalment hi posarem la row
@property (nonatomic, assign) NSInteger swselectedOptionIndex;
@property (nonatomic, weak) id <SWTableSelectionControllerDelegate> delegate;

@end
