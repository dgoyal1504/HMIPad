//
//  SWFlowController.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 2/8/12.
//  Copyright (c) 2012 SweetWilliam SL. All rights reserved.
//


/******************************************************************/
/******************************************************************/
/**                                                              **/
/** WARNING: THIS CLASS IS ABOUT TO BE DEPRECATED. DO NOT USE IT **/
/**                                                              **/
/******************************************************************/
/******************************************************************/

#import <UIKit/UIKit.h>

#import "SWFlowControllerDelegate.h"
#import "SWFlowControllerDataSource.h"
#import "SWFlowViewDelegate.h"
#import "SWFlowViewDataSource.h"
#import "SWFlowControllerTypes.h"

@class SWFlowView;

@interface SWFlowController : UIViewController <SWFlowViewDataSource, SWFlowViewDelegate> {
    SWFlowView *_flowView;
    UIBarButtonItem *_backItem;
    
    NSInteger _numberOfViewControllers;
    NSInteger _selectedViewControllerIndex;
}

- (IBAction)dismissCurrentViewController:(id)sender;
- (IBAction)moveToRightViewController:(id)sender;
- (IBAction)moveToLeftViewController:(id)sender;

- (void)insertControllersAtIndexes:(NSIndexSet*)indexes withAnimation:(SWFlowControllerAnimation)animation;
- (void)deleteControllersAtIndexes:(NSIndexSet*)indexes withAnimation:(SWFlowControllerAnimation)animation;

@property (strong,nonatomic) NSMutableArray *viewControllers;
//@property (nonatomic,assign) NSInteger selected;

@property (weak,nonatomic) id<SWFlowControllerDelegate> delegate;
@property (weak,nonatomic) id<SWFlowControllerDataSource> dataSource;

@end
