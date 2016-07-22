//
//  SWTextFieldController.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 6/12/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWNumberTextFieldItemController.h"
#import "SWNumberTextFieldItem.h"

#import "SWColor.h"

#import "SWEnumTypes.h"

#import "RoundedTextView.h"

//#import "SWViewControllerNotifications.h"
//#import "SWDocumentController.h"



@interface SWNumberTextFieldItemController()<UITextFieldDelegate /*,RoundedTextViewDelegate*/>
    @property (strong, nonatomic) UITextField *textField;
    //@property (strong, nonatomic) RoundedTextView *textField;
@end


@implementation SWNumberTextFieldItemController



- (void)loadView
{
    _textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 138, 31)];
    _textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    [_textField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [_textField setDelegate:self];
    self.view = _textField;
}


//- (void)loadView
//{
//    _textField = [[RoundedTextView alloc] initWithFrame:CGRectMake(0, 0, 138, 31)];
//    UITextView *textView = _textField.textView;
//    textView.keyboardType = UIKeyboardTypeNumberPad;
//    //[textView setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
//    [_textField setDelegate:self];
//    self.view = _textField;
//}



- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    _textField = nil;
    [super viewDidUnload];
}

#pragma mark - Overriden Methods

- (void)refreshViewFromItem
{
    [super refreshViewFromItem];
    
    [self _setEnabledState];
    [self _updateText];
    [self _updateTextAlignment];
    [self _updateSecureInput];
    [self _updateStyle];
    [self _updateTextColor];
    [self _updateTextFont];
}

- (void)refreshBackgroundColorFromItem
{
    [super refreshBackgroundColorFromItem];
    [self _updateBackgroundTextColor];
}

- (void)refreshZoomScaleFactor:(CGFloat)contentScaleFactor
{
    [super refreshZoomScaleFactor:contentScaleFactor];
    [self setZoomScaleFactorDeep];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (UIColor*)itemBackColor
{
    UIColor *color = [UIColor clearColor];
    return color;
}

#pragma mark - Private Methods



- (void)_didStartEditing
{
    [_textField resignFirstResponder];
}

- (SWNumberTextFieldItem*)_textFieldItem
{
    if ([self.item isKindOfClass:[SWNumberTextFieldItem class]])
        return (SWNumberTextFieldItem*)self.item;
    
    return nil;
}

- (void)_updateText
{
    SWNumberTextFieldItem *item = [self _textFieldItem];
    
    NSString *format = [item.format valueAsStringWithFormat:nil];
    NSString *text = [item.value valueAsStringWithFormat:format];
    _textField.text = text;
}

- (void)_updateTextColor
{
    SWNumberTextFieldItem *item = [self _textFieldItem];
    _textField.textColor = item.textColor.valueAsColor;
}

- (void)_updateBackgroundTextColor
{
    SWNumberTextFieldItem *item = [self _textFieldItem];
    _textField.backgroundColor = item.backgroundColor.valueAsColor;
}

//- (void)_refreshViewFromTextColorExpression
//{
//    SWNumberTextFieldItem *item = [self _textFieldItem];
//    _textField.textView.textColor = item.textColor.valueAsColor;
//}

- (void)_updateTextFont
{
    SWNumberTextFieldItem *item = [self _textFieldItem];
    
    UIFont *font = [UIFont fontWithName:item.font.valueAsString size:item.fontSize.valueAsDouble];
    _textField.font = font;
}

//- (void)_refreshViewFromFontsExpressions
//{
//    SWNumberTextFieldItem *item = [self _textFieldItem];
//    
//    UIFont *font = [UIFont fontWithName:item.font.valueAsString size:item.fontSize.valueAsDouble];
//    _textField.textView.font = font;
//}


- (void)_updateTextAlignment
{
    SWNumberTextFieldItem *item = [self _textFieldItem]; 
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
    _textField.textAlignment = aligment;
//    _textField.textView.textAlignment = aligment;
}

- (void)_updateSecureInput
{
    SWNumberTextFieldItem *item = [self _textFieldItem]; 
    BOOL secureInput = item.secureInput.valueAsBool;
    _textField.secureTextEntry = secureInput;
//    _textField.textView.secureTextEntry = secureInput;
}

- (void)_updateStyle
{
    SWNumberTextFieldItem *item = [self _textFieldItem];
    SWTextFieldStyle style = item.style.valueAsInteger;
    
    switch ( style )
    {
        case SWTextFieldStyleBezel:
            _textField.borderStyle = UITextBorderStyleRoundedRect;
            break;
            
        case SWTextFieldStylePlain:
            _textField.borderStyle = UITextBorderStyleNone;
            break;
    }
}

- (void)_setEnabledState
{
//    SWNumberTextFieldItem *item = [self _textFieldItem];
//    BOOL enabled = item.enabled.valueAsInteger;
//    [_textField setEnabled:enabled];
//
//      ^ comentat fora perque igualment filtrem en textFieldShouldBeginEditing i no hi ha cap diferencia visual
}

- (void)_evalItemValueWithText:(NSString*)text
{
    SWNumberTextFieldItem *item = [self _textFieldItem];
    double value = [text doubleValue];
    double min = [item.minValue valueAsDouble];
    double max = [item.maxValue valueAsDouble];
    
    if ( min <= max && (min != 0 || max != 0 ) )
    {
        if ( value < min ) value = min;
        if ( value > max ) value = max;
    }
    
    [item.value evalWithConstantValue:value];
}


- (void)_evalItemContinuousValueWithText:(NSString*)text
{
    SWNumberTextFieldItem *item = [self _textFieldItem];
    double value = [text doubleValue];
    [item.continuousValue evalWithDouble:value];
}


- (void)_checkPointForText:(NSString*)text
{
    SWNumberTextFieldItem *item = [self _textFieldItem];
    __weak SWNumberTextFieldItemController *theSelf = self;
    [theSelf checkPointVerification:nil completion:^(BOOL verified, BOOL success)
    {
        item.controlIsEditing = NO;
        if ( success )
        {
            [theSelf _evalItemValueWithText:text];
        }
        else
        {
            [item.continuousValue evalWithValue:item.value];    // tornem al valor original
            [theSelf _updateText];                              // updatem el view
        }
    }];
}


#pragma mark - TextField Delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    SWNumberTextFieldItem *item = [self _textFieldItem];
    return item.enabled.valueAsBool;
}

- (void)delayedSelectAll
{
    UITextPosition *beg = _textField.beginningOfDocument;
    UITextPosition *end = _textField.endOfDocument;
    UITextRange *range = [_textField textRangeFromPosition:beg toPosition:end];
    _textField.selectedTextRange = range;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    SWNumberTextFieldItem *item = [self _textFieldItem];
    item.controlIsEditing = YES;
    
    SWTextSelectionStyle selectionStyle = [item.textSelectionStyle valueAsInteger];
    if ( selectionStyle == SWTextSelectionStyleAll )
        [self performSelector:@selector(delayedSelectAll) withObject:nil afterDelay:0.1]; // 0.2 aprox el temps de surtir el teclat
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL valid = YES;

    if ( [string length] > 0 )
    {
        NSMutableCharacterSet *validSet = [NSMutableCharacterSet decimalDigitCharacterSet ];

        [validSet addCharactersInString:@"+-.eE"];
    
        NSScanner *scanner = [[NSScanner alloc] initWithString:string];
        NSString *filtered = nil;
        [scanner scanCharactersFromSet:validSet intoString:&filtered];
    
        valid = [string isEqualToString:filtered];
    }
    
    if ( valid )
    {
        NSString *resultString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        [self _evalItemContinuousValueWithText:resultString];
    }
    
    return valid;
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSString *text = [textField text];
    
    if (textField == _textField) 
    {
        [self _checkPointForText:text];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}



//#pragma mark - RoundedTextView Delegate
//
//- (BOOL)roundedTextViewShouldBeginEditing:(RoundedTextView *)roundedTextView
//{
//    SWNumberTextFieldItem *item = [self _textFieldItem];
//    return item.enabled.valueAsBool;
//}
//
//- (void)roundedTextViewDidBeginEditing:(RoundedTextView *)roundedTextView
//{
//    SWNumberTextFieldItem *item = [self _textFieldItem];
//    item.controlIsEditing = YES;
//}
//
//- (BOOL)roundedTextView:(RoundedTextView *)roundedTextView shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
//{
//    BOOL valid = YES;
//
//    if ( [string length] > 0 )
//    {
//        NSMutableCharacterSet *validSet = [NSMutableCharacterSet decimalDigitCharacterSet ];
//
//        [validSet addCharactersInString:@"+-.eE"];
//    
//        NSScanner *scanner = [[NSScanner alloc] initWithString:string];
//        NSString *filtered = nil;
//        [scanner scanCharactersFromSet:validSet intoString:&filtered];
//    
//        valid = [string isEqualToString:filtered];
//    }
//    
//    if ( valid )
//    {
//        NSString *resultString = [roundedTextView.text stringByReplacingCharactersInRange:range withString:string];
//        [self _evalItemContinuousValueWithText:resultString];
//    }
//    
//    return valid;
//}
//
//
//- (void)roundedTextViewDidEndEditing:(RoundedTextView *)roundedTextView ;
//{
//    NSString *text = [roundedTextView text];
//    
//    if (roundedTextView == _textField) 
//    {
//        [self _checkPointForText:text];
//    }
//}
//
//- (BOOL)roundedTextViewShouldReturn:(RoundedTextView *)roundedTextView ;
//{
//    [roundedTextView resignFirstResponder];
//    return YES;
//}


#pragma mark - Document Model Observer


- (void)refreshEditingStateFromModel
{
    [super refreshEditingStateFromModel];
    if ( [self.item.docModel editMode] )
        [self _didStartEditing];
}


//- (void)documentModel:(SWDocumentModel *)docModel editingModeDidChangeAnimated:(BOOL)animated
//{
//    [super documentModel:docModel editingModeDidChangeAnimated:animated];
//    if ( docModel.editMode )
//        [self _didStartEditing];
//}


#pragma mark - Protocol SWValueObserver

- (void)value:(SWValue *)value didEvaluateWithChange:(BOOL)changed
{
    SWNumberTextFieldItem *item = [self _textFieldItem]; 
    
    if (value == item.value || value == item.format)
    {
        if ( !item.controlIsEditing )
            [self _updateText];
    }
    else if (value == item.textColor)
        [self _updateTextColor];
    
    else if (value == item.font || value == item.fontSize)
        [self _updateTextFont];
    
    else if (value == item.textAlignment) 
        [self _updateTextAlignment];
    
    else if (value == item.secureInput)
        [self _updateSecureInput];
    
    else if (value == item.style)
        [self _updateStyle];
    
    else if (value == item.enabled )
        [self _setEnabledState];
        
    else
    {
        [super value:value didEvaluateWithChange:changed];
    }
}


@end
