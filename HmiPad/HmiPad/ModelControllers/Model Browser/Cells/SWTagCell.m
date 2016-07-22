//
//  SWTagCell.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 3/23/12.
//  Copyright (c) 2012 Sweet William SL. All rights reserved.
//

#import "SWTagCell.h"
#import "SWSourceItem.h"
#import "SWSourceNode.h"
#import "SWPlcTag.h"
#import "SWReadExpression.h"
//#import "SWExpression.h"
#import "SWColor.h"

#import <QuartzCore/QuartzCore.h>


NSString *SWTagCellNibName = @"SWTagCell";
NSString *SWTagCellNibName6 = @"SWTagCell6";

NSString *SWTagCellIdentifier = @"sourceVariableCellIdentifier";

@implementation SWTagCell

//@synthesize variableNameField = _variableNameField;
//@synthesize expressionField = _expressionField;
//@synthesize memoryAddresField = _memoryAddresField;

@synthesize sourceNode = _sourceNode;
//@synthesize expressionFieldTextColor = _expressionFieldTextColor;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    _valueAsStringLabel.textColor = UIColorWithRgb(TextDefaultColorFixed);  // default color
    _valueAsStringLabel.font = [UIFont boldSystemFontOfSize:14]; // default font
}



- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
}


- (void)refreshSemanticType  // overriden
{
    _valueSemanticTypeLabel.text = [_sourceNode.plcTag addressAndTypeString];
    [self setNeedsLayout];
}


- (void)refreshValue  // overriden
{
    //BOOL state = _sourceNode.readExpression.state;
    ExpressionStateCode state = _value.state;
    BOOL showInfo = NO;
    NSString *valueAsString = nil;
    
    if ( state == ExpressionStateOk )
    {
        //_infoButton.hidden = YES;
        NSString *format = [_sourceNode.plcTag defaultFormatString];

        if ( format ) valueAsString = [_value valueAsStringWithFormat:format];
        else valueAsString = [_value getValuePrintableString];

//        _valueAsStringLabel.text = string;
//        _valueAsStringLabel.font = [UIFont boldSystemFontOfSize:14];
//        
//        UIColor *exprTextColor = _expressionFieldTextColor;
//        if ( exprTextColor == nil ) exprTextColor = UIColorWithRgb(TextDefaultColorFixed);
//        _valueAsStringLabel.textColor = exprTextColor;
    }
    
    else if ( state == ExpressionStatePendingSource )
    {
        //_infoButton.hidden = YES;
        //_valueAsStringLabel.text = nil;
    }
    
    else  // error
    {
        NSString *errorString = [_sourceNode tagErrorString];
        // ^ El torna nil si esta pendent de carregar
        
        showInfo =  errorString && [_delegate respondsToSelector:@selector(tagCell:presentMessage:fromView:)];
        // ^-- nomes mostrem el boto si implementem el delegat i hi ha una string a mostrar

        _valueAsStringLabel.text = nil;
    
//            _valueAsStringLabel.text = [_sourceNode tagErrorString];
//            _valueAsStringLabel.font = [UIFont systemFontOfSize:13];
//            _valueAsStringLabel.textColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:1];
        
    }
    
    _valueAsStringLabel.text = valueAsString;
    _infoButton.hidden = !showInfo;
    
    if ( ! showInfo && [_delegate respondsToSelector:@selector(tagCellDismissMessage:)] )
        [_delegate tagCellDismissMessage:self];
    
    [self setNeedsLayout];
}


- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
    if (newSuperview == nil)  // woraround al radar 12307048 (https://bugreport.apple.com/cgi-bin/WebObjects/RadarWeb.woa/64/wo/NNQKV55CzhEbX84Pld5bq0/2.1.5.11.0.2.1.1
    {
        [self endObservingModel];
    }
}


- (void)beginObservingModel
{
    if ( !_isObserving )
    {
        //NSLog( @"begin observing cell: %08x", (int)self);
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter] ;
        [nc addObserver:self selector:@selector(_sourceItemStatusChanged:) name:kFinsStateDidChangeNotification object:_sourceNode.sourceItem];
    }
    [super beginObservingModel];
}


- (void)endObservingModel
{
    if ( _isObserving )
    {
        //NSLog( @"end observing cell: %08x", (int)self);
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter] ;
        [nc removeObserver:self];
    }
    [super endObservingModel];
}

- (void)setSourceNode:(SWSourceNode *)sourceNode
{    
    _sourceNode = sourceNode;
    [self setValue:_sourceNode.readExpression];
}

- (void)setExpressionFieldTextColor:(UIColor *)expressionFieldTextColor
{
    _valueAsStringLabel.textColor = expressionFieldTextColor;
}


#pragma mark button action
- (IBAction)warningButtonPushed:(id)sender
{
    if ([_delegate respondsToSelector:@selector(tagCell:presentMessage:fromView:)])
    {
        NSString *msg = [_sourceNode tagErrorString];
        [_delegate tagCell:self presentMessage:msg fromView:sender];
    }
}

#pragma mark Expression observer

//- (void)expression:(SWExpression *)expression didChangeState:(UInt8)oldState
- (void)expressionStateDidChange:(SWExpression *)expression
{
    _valueAsStringLabel.alpha = 0.0f;
    [UIView animateWithDuration:0.25f delay:0.0f options:UIViewAnimationOptionCurveEaseOut
    animations:^
    {
        _valueAsStringLabel.alpha = 1.0f;
    }
    completion:nil];
}



#pragma mark SourceItemStatusChange Notification


- (void)_sourceItemStatusChanged:(NSNotification*)notification
{
    [self refreshValue];
}



@end
