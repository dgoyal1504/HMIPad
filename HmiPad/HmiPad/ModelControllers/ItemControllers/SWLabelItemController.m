//
//  SWLabelItemController.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 4/16/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWLabelItemController.h"
#import "SWLabelItem.h"
#import "SWColor.h"
#import "SWEnumTypes.h"

#import "VerticallyAlignedLabel.h"


@interface SWLabelItemController ()

- (SWLabelItem*)_labelItem;

- (void)_refreshViewFromTextExpression;
- (void)_refreshViewFromTextColorExpression;
- (void)_refreshViewFromFontsExpressions;

@end

@implementation SWLabelItemController


- (void)loadView
{
    _label = [[VerticallyAlignedLabel alloc] initWithFrame:CGRectMake(0,0,100,40)];
    [_label setNumberOfLines:0];
    [_label setLineBreakMode:NSLineBreakByWordWrapping];
    
    
    self.view = _label;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    _label = nil;
    [super viewDidUnload];
}

#pragma mark - Overriden Methods

- (void)refreshViewFromItem
{
    [super refreshViewFromItem];
        
    [self _refreshViewFromTextExpression];
    [self _refreshViewFromTextColorExpression];
    [self _refreshViewFromFontsExpressions];
    [self _updateTextAlignment];
    [self _updateVerticalTextAlignment];
}

#pragma mark - Private Methods

- (SWLabelItem*)_labelItem
{
    if ([self.item isKindOfClass:[SWLabelItem class]]) {
        return (SWLabelItem*)self.item;
    }
    
    return nil;
}

- (void)_refreshViewFromTextExpression
{
    SWLabelItem *item = [self _labelItem];
    
    NSString *format = [item.format valueAsStringWithFormat:nil];
    NSString *text = [item.value valueAsStringWithFormat:format];
    _label.text = text;
}

- (void)_refreshViewFromTextColorExpression
{
    SWLabelItem *item = [self _labelItem];
    _label.textColor = item.textColor.valueAsColor;
}

- (void)_refreshViewFromFontsExpressions
{
    SWLabelItem *item = [self _labelItem];
    
    UIFont *font = [UIFont fontWithName:[item.font valueAsString] size:[item.fontSize valueAsDouble]];
    _label.font = font;
}

- (void)_updateTextAlignment
{
    SWLabelItem *item = [self _labelItem]; 
    SWTextAlignment textAlignment = [item.textAlignment valueAsInteger];
    
    NSTextAlignment aligment;
    
    switch ( textAlignment )
    {
        case SWTextAlignmentLeft:
            aligment = NSTextAlignmentLeft;
            break;
        case SWTextAlignmentCenter:
            aligment = NSTextAlignmentCenter;
            break;
        case SWTextAlignmentRight:
            aligment = NSTextAlignmentRight;
            break;
        default:
            aligment = NSTextAlignmentLeft;
            break;
    }
    _label.textAlignment = aligment;
}


- (void)_updateVerticalTextAlignment
{
    SWLabelItem *item = [self _labelItem]; 
    SWVerticalTextAlignment textAlignment = [item.verticalTextAlignment valueAsInteger];
    
    VerticalAlignment aligment;
    
    switch ( textAlignment )
    {
        case SWVerticalTextAlignmentTop:
            aligment = VerticalAlignmentTop;
            break;
            
        default:
        case SWVerticalTextAlignmentCenter:
            aligment = VerticalAlignmentMiddle;
            break;
            
        case SWVerticalTextAlignmentBottom:
            aligment = VerticalAlignmentBottom;
            break;
    }
    
    [_label setVerticalAlignment:aligment];
}


#pragma mark - Protocol SWExpressionObserver

- (void)value:(SWValue*)value didEvaluateWithChange:(BOOL)changed
{
    SWLabelItem *item = [self _labelItem];
    
    if (value == item.value || value == item.format) 
    {
        [self _refreshViewFromTextExpression];
    } 
    
    else if (value == item.textColor)
    {
        [self _refreshViewFromTextColorExpression];
    } 
    
    else if (value == item.font || value == item.fontSize)
    {
        [self _refreshViewFromFontsExpressions];
    }
    
    else if (value == item.textAlignment)
    {
        [self _updateTextAlignment];
    }
    
    else if (value == item.verticalTextAlignment)
    {
        [self _updateVerticalTextAlignment];
    }
    
    else
    {
        [super value:value didEvaluateWithChange:changed];
    }
}

@end
