//
//  SWTextFieldController.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 6/12/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWAbstractTextFieldItemController.h"
#import "SWAbstractTextFieldItem.h"

#import "SWColor.h"

#import "SWEnumTypes.h"

//#import "SWViewControllerNotifications.h"
#import "SWDocumentController.h"

@implementation SWAbstractTextFieldItemController

@synthesize textField = _textField;


- (void)loadView
{
    _textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 138, 31)];
    [_textField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [_textField setDelegate:self];
    self.view = _textField;
}

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
    
    //[self _refreshViewFromInputType];
    [self _updateText];
    [self _updateTextAlignment];
    [self _updateSecureInput];
    [self _refreshViewFromTextColorExpression];
    [self _refreshViewFromFontsExpressions];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(_didStartEditing) name:SWDocumentDidBeginEditingNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
  //  [nc removeObserver:self name:SWDocumentDidBeginEditingNotification object:nil];
}

#pragma mark - Private Methods



- (void)_didStartEditing
{
    [_textField resignFirstResponder];
}

- (SWAbstractTextFieldItem*)_textFieldItem
{
    if ([self.item isKindOfClass:[SWAbstractTextFieldItem class]])
        return (SWAbstractTextFieldItem*)self.item;
    
    return nil;
}

- (void)_updateText
{
    SWAbstractTextFieldItem *item = [self _textFieldItem];
    
    NSString *format = [item.format valueAsStringWithFormat:nil];
    NSString *text = [item.value valueAsStringWithFormat:format];
    _textField.text = text;
}

- (void)_refreshViewFromTextColorExpression
{
    SWAbstractTextFieldItem *item = [self _textFieldItem];
    _textField.textColor = item.textColor.valueAsColor;
}

- (void)_refreshViewFromFontsExpressions
{
    SWAbstractTextFieldItem *item = [self _textFieldItem];
    
    UIFont *font = [UIFont fontWithName:item.font.valueAsString size:item.fontSize.valueAsDouble];
    _textField.font = font;
}

//- (void)_refreshViewFromInputType
//{
//    //SWAbstractTextFieldItem *item = [self _textFieldItem];
//    SWEnumInputType inputType = self.inputType;
//    
//    UIKeyboardType keyboardType;
//    
//    switch (inputType)
//    {
//        case SWTextFieldInputTypeNumeric:
//            keyboardType = UIKeyboardTypeNumberPad;
//            break;
//        case SWTextFieldInputTypeString:
//            keyboardType = UIKeyboardTypeDefault;
//            break;
//        default:
//            keyboardType = UIKeyboardTypeDefault;
//            break;
//    }
//    
//    _textField.keyboardType = keyboardType;
//}

- (void)_updateTextAlignment
{
    SWAbstractTextFieldItem *item = [self _textFieldItem]; 
    SWTextAlignment textAlignment = [item.textAlignment valueAsInteger];
    
    UITextAlignment aligment;
    
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
}

- (void)_updateSecureInput
{
    SWAbstractTextFieldItem *item = [self _textFieldItem]; 
    BOOL secureInput = item.secureInput.valueAsBool;
    _textField.secureTextEntry = secureInput;
}

- (void)_evalItemValueWithText:(NSString*)text
{
    SWAbstractTextFieldItem *item = [self _textFieldItem]; 
    
    switch ( self.inputType )
    {
        case SWTextFieldInputTypeNumeric:
            [item.value evalWithConstantValue:[text doubleValue]];
            break;
        case SWTextFieldInputTypeString:
            [item.value evalWithStringConstant:(CFStringRef)text];
            break;
        default:
            break;
    }
}

- (void)_evalItemContinuousValueWithText:(NSString*)text
{
    SWAbstractTextFieldItem *item = [self _textFieldItem]; 
    
    switch (self.inputType)
    {
        case SWTextFieldInputTypeNumeric:
            [item.continuousValue evalWithDouble:[text doubleValue]];
            break;
        case SWTextFieldInputTypeString:
            [item.continuousValue evalWithString:text];
            break;
        default:
            break;
    }
}


- (void)_checkPointForText:(NSString*)text
{
    SWAbstractTextFieldItem *item = [self _textFieldItem];
    __weak id theSelf = self;
    [theSelf checkPointVerification:nil completion:^(BOOL success)
    {
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




#pragma mark - Protocol SWValueObserver

- (void)value:(SWValue *)value didEvaluateWithChange:(BOOL)changed
{
    SWAbstractTextFieldItem *item = [self _textFieldItem]; 
    
    if (value == item.value || value == item.format) 
        [self _updateText];
        
    else if (value == item.textColor)
        [self _refreshViewFromTextColorExpression];
    
    else if (value == item.font || value == item.fontSize)
        [self _refreshViewFromFontsExpressions];
    
//    else if (value == item.inputType) 
//    {
//        [self _refreshViewFromInputType];
//        [self textFieldDidEndEditing:self.textField];
//    }
    else if (value == item.textAlignment)
        [self _updateTextAlignment];
    
    else if (value == item.secureInput)
        [self _updateSecureInput];
        
    else
    {
        [super value:value didEvaluateWithChange:changed];
    }
}

#pragma mark - TextField Delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    SWAbstractTextFieldItem *item = [self _textFieldItem];
    return item.enabled.valueAsBool;
}

//- (void)textFieldDidBeginEditing:(UITextField *)textField
//{
//
//}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL valid = YES;
    
    //SWAbstractTextFieldItem *item = [self _textFieldItem];
    SWEnumInputType inputType = self.inputType;

    if ( inputType == SWTextFieldInputTypeNumeric )
    {
        if ( [string length] > 0 )
        {
            NSMutableCharacterSet *validSet = [NSMutableCharacterSet decimalDigitCharacterSet ];

            [validSet addCharactersInString:@"+-.eE"];
    
            NSScanner *scanner = [[NSScanner alloc] initWithString:string];
            NSString *filtered = nil;
            [scanner scanCharactersFromSet:validSet intoString:&filtered];
    
            valid = [string isEqualToString:filtered];
        }
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

@end
