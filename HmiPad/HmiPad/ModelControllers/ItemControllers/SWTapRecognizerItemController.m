//
//  SWTapRecognizerItemController.m
//  HmiPad
//
//  Created by Joan on 26/05/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import "SWTapRecognizerItemController.h"
#import "SWTapRecognizerItem.h"


@interface SWTapRecognizerItemController()<UIGestureRecognizerDelegate>
{
    UIView *_tapView;
    UITapGestureRecognizer *_tapRecognizer;
}

@end


@implementation SWTapRecognizerItemController


#pragma mark - view 

- (void)loadView
{
    _tapView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_gestureRecognized:)];
    _tapRecognizer.delegate = self;
    [_tapView addGestureRecognizer:_tapRecognizer];
    self.view = _tapView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    _tapView = nil;
    _tapRecognizer = nil;
    [super viewDidUnload];
}


#pragma mark - Overriden Methods

- (void)refreshViewFromItem
{
    [super refreshViewFromItem];
    
    SWTapRecognizerItem *item = [self _tapItem];
    
    _tapRecognizer.numberOfTapsRequired = item.numberOfTaps.valueAsInteger;
    _tapRecognizer.numberOfTouchesRequired = item.numberOfTouches.valueAsInteger;
    
    [self _updateEditingMode];
}

- (void)refreshBackgroundColorFromItem
{
    SWTapRecognizerItem *item = [self _tapItem];
    UIColor *color = item.backgroundColor.valueAsColor;
    _tapView.backgroundColor = color;
}

- (UIColor*)itemBackColor
{
    UIColor *backColor = [UIColor clearColor];
    return backColor;
}


#pragma mark - Private


- (SWTapRecognizerItem*)_tapItem
{
    return (SWTapRecognizerItem*)self.item;
}

- (void)_updateEditingMode
{
    UIColor *color = nil;
    
    SWTapRecognizerItem *item = [self _tapItem];
    SWDocumentModel *docModel = item.docModel;
    BOOL isEditing = docModel.editMode;
    
    if ( isEditing ) color = item.backgroundColor.valueAsColor;
    else color = [UIColor clearColor];

    _tapView.backgroundColor = color;
}

#pragma mark - Recognizer


- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return YES;
}


- (void)_delayedNormalEnd:(id)dummy
{
    SWTapRecognizerItem *item = [self _tapItem];
    [item.tap evalWithDouble:0.0];
}


- (void)_gestureRecognized:(UIGestureRecognizer*)gestureRecognizer
{
    SWTapRecognizerItem *item = [self _tapItem];
    
    [item.tap evalWithDouble:1.0];
    [self performSelector:@selector(_delayedNormalEnd:) withObject:nil afterDelay:0.0];
}




#pragma mark - Document model Observer

- (void)refreshEditingStateFromModel
{
    [super refreshEditingStateFromModel];
    [self _updateEditingMode];
}


//- (void)documentModel:(SWDocumentModel *)docModel editingModeDidChangeAnimated:(BOOL)animated
//{
//    [self _updateEditingMode];
//}


#pragma mark - Protocol SWExpressionObserver

- (void)value:(SWValue *)value didEvaluateWithChange:(BOOL)changed
{
    SWTapRecognizerItem *item = [self _tapItem];
    
    if (value == item.numberOfTaps )
    {
        _tapRecognizer.numberOfTapsRequired = value.valueAsInteger;
    }
    
    else if ( value == item.numberOfTouches )
    {
        _tapRecognizer.numberOfTouchesRequired = value.valueAsInteger;
    }

    [super value:value didEvaluateWithChange:changed];
}











@end
