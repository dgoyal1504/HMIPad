//
//  SWVerticalPipeItemController.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 4/17/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWVerticalPipeItemController.h"
#import "SWVerticalPipeItem.h"
#import "SWPipeView.h"

@interface SWVerticalPipeItemController ()
{
    SWPipeView *_pipeView;
}
@end

@implementation SWVerticalPipeItemController


- (void)loadView
{
    _pipeView = [[SWPipeView alloc] initWithFrame:CGRectMake(0,0,100,100)];
    _pipeView.verticalPipe = YES;
    self.view = _pipeView;
}


- (SWVerticalPipeItem*)_pipeItem
{
    if ([self.item isKindOfClass:[SWVerticalPipeItem class]]) {
        return (SWVerticalPipeItem*)self.item;
    }
    return nil;
}

- (void)refreshViewFromItem
{
    [super refreshViewFromItem];
    
    SWVerticalPipeItem *item = [self _pipeItem];
    
    //[self _updateColorExpression];
    _pipeView.color = item.color.valueAsColor;
}

//- (void)_updateColorExpression
//{
//    SWVerticalPipeItem *item = [self _pipeItem];
//    _pipeView.color = item.color.valueAsColor;
//    //self.view.backgroundColor = item.color.valueAsColor;
//}

- (void)value:(SWValue *)value didEvaluateWithChange:(BOOL)changed
{
    SWVerticalPipeItem *item = [self _pipeItem];
    
    if (value == item.color)
    {
        //[self _updateColorExpression];
        _pipeView.color = item.color.valueAsColor;
    }
    else
    {
        [super value:value didEvaluateWithChange:changed];
    }
}

@end
