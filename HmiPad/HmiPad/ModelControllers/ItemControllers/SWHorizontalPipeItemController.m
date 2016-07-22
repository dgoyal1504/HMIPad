//
//  SWHorizontalPipeItemController.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 4/17/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWHorizontalPipeItemController.h"
#import "SWHorizontalPipeItem.h"
#import "SWPipeView.h"

@interface SWHorizontalPipeItemController ()
{
    SWPipeView *_pipeView;
}
@end

@implementation SWHorizontalPipeItemController


- (void)loadView
{
    _pipeView = [[SWPipeView alloc] initWithFrame:CGRectMake(0,0,100,100)];
    _pipeView.verticalPipe = NO;
    self.view = _pipeView;
}


- (SWHorizontalPipeItem*)_pipeItem
{
    if ([self.item isKindOfClass:[SWHorizontalPipeItem class]]) {
        return (SWHorizontalPipeItem*)self.item;
    }
    return nil;
}

- (void)refreshViewFromItem
{
    [super refreshViewFromItem];
    
    SWHorizontalPipeItem *item = [self _pipeItem];
    //[self _updateColorExpression];
    _pipeView.color = item.color.valueAsColor;
}

//- (void)_updateColorExpression
//{
//    SWHorizontalPipeItem *item = [self _pipeItem];
//    self.view.backgroundColor = item.color.valueAsColor;
//}

- (void)value:(SWValue *)value didEvaluateWithChange:(BOOL)changed
{
    SWHorizontalPipeItem *item = [self _pipeItem];
    
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
