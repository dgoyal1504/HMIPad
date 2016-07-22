//
//  SWTextFieldController.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 6/12/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWTextFieldItemController.h"
#import "SWTextFieldItem.h"

#import "SWColor.h"

#import "SWEnumTypes.h"

#import "SWViewControllerNotifications.h"
#import "SWDocumentController.h"

@implementation SWTextFieldItemController

@synthesize textField = _textField;


- (void)loadView
{
    _textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 138, 31)];
    [_textField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
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
    
    [self _refreshViewFromInputType];
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

- (SWTextFieldItem*)_textFieldItem
{
    if ([self.item isKindOfClass:[SWTextFieldItem class]])
        return (SWTextFieldItem*)self.item;
    
    return nil;
}

- (void)_updateText
{
    SWTextFieldItem *item = [self _textFieldItem];
    
    NSString *format = [item.format valueAsStringWithFormat:nil];
    NSString *text = [item.value valueAsStringWithFormat:format];
    _textField.text = text;
}

- (void)_refreshViewFromTextColorExpression
{
    SWTextFieldItem *item = [self _textFieldItem];
    _textField.textColor = item.textColor.valueAsColor;
}

- (void)_refreshViewFromFontsExpressions
{
    SWTextFieldItem *item = [self _textFieldItem];
    
    UIFont *font = [UIFont fontWithName:item.font.valueAsString size:item.fontSize.valueAsDouble];
    _textField.font = font;
}

- (void)_refreshViewFromInputType
{
    SWTextFieldItem *item = [self _textFieldItem]; 
    SWEnumInputType inputType = [item.inputType valueAsInteger];
    
    UIKeyboardType keyboardType;
    
    switch (inputType) {
        case SWTextFieldInputTypeNumeric:
            keyboardType = UIKeyboardTypeNumberPad;
            break;
        case SWTextFieldInputTypeString:
            keyboardType = UIKeyboardTypeDefault;
            break;
        default:
            keyboardType = UIKeyboardTypeDefault;
            break;
    }
    
    _textField.keyboardType = keyboardType;
}

- (void)_updateTextAlignment
{
    SWTextFieldItem *item = [self _textFieldItem]; 
    SWTextAlignment textAlignment = [item.textAlignment valueAsInteger];
    
    UITextAlignment aligment;
    
    switch ( textAlignment )
    {
        case SWTextAlignmentLeft:
            aligment = UITextAlignmentLeft;
            break;
        case SWTextAlignmentCenter:
            aligment = UITextAlignmentCenter;
            break;
        case SWTextAlignmentRight:
            aligment = UITextAlignmentRight;
            break;
        default:
            aligment = UITextAlignmentLeft;
            break;
    }
    _textField.textAlignment = aligment;
}

- (void)_updateSecureInput
{
    SWTextFieldItem *item = [self _textFieldItem]; 
    BOOL secureInput = item.secureInput.valueAsBool;
    _textField.secureTextEntry = secureInput;
}

#pragma mark - Protocol SWValueObserver

- (void)value:(SWValue *)value didEvaluateWithChange:(BOOL)changed
{
    SWTextFieldItem *item = [self _textFieldItem]; 
    
    if (value == item.value || value == item.format) 
        [self _updateText];
        
    else if (value == item.textColor)
        [self _refreshViewFromTextColorExpression];
    
    else if (value == item.font || value == item.fontSize)
        [self _refreshViewFromFontsExpressions];
    
    else if (value == item.inputType) 
    {
        [self _refreshViewFromInputType];
        [self textFieldDidEndEditing:self.textField];
    }
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
    SWTextFieldItem *item = [self _textFieldItem];
    return item.enabled.valueAsBool;
}

//- (void)textFieldDidBeginEditing:(UITextField *)textField
//{
//    
//}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSError *error = nil;
    BOOL pass = YES;
    NSString *text = [textField text];
    
    SWTextFieldItem *item = [self _textFieldItem]; 
    
    if (textField == _textField) 
    {
        switch (item.inputType.valueAsInteger) 
        {
            case SWTextFieldInputTypeNumeric:
                [item.value evalWithConstantValue:[text doubleValue]];
                break;
            case SWTextFieldInputTypeString:
                //[item.value evalWithStringConstant:(CFStringRef)[NSString stringWithFormat:@"%@",text]];
                [item.value evalWithStringConstant:(CFStringRef)text];
                break;
            default:
                break;
        }
    }
    
    if (!pass)
        NSLog(@"error :%@", [error localizedDescription]);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
