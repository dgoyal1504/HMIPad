//
//  SWTextFieldController.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 6/12/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWStringTextViewItemController.h"
#import "SWStringTextViewItem.h"

#import "SWColor.h"

#import "SWEnumTypes.h"


@interface SWStringTextViewItemController()<UITextViewDelegate>
    @property (strong, nonatomic) UITextView *textView;
@end


@implementation SWStringTextViewItemController
{
}

@synthesize textView = _textView;


- (void)loadView
{
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 138, 31)];
    _textView.keyboardType = UIKeyboardTypeASCIICapable;
    //old [_textView setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [_textView setDelegate:self];
    self.view = _textView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    _textView = nil;
    [super viewDidUnload];
}

#pragma mark - Overriden Methods

- (void)refreshViewFromItem
{
    [super refreshViewFromItem];
    
    [self _setEnabledState];
    [self _updateText];
    [self _updateTextAlignment];
//    [self _updateSecureInput];
//    [self _updateStyle];
    [self _updateTextColor];
    [self _updateTextFont];
    
//    _isScanner = YES;
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
    [_textView resignFirstResponder];
}

- (SWStringTextViewItem*)_textViewItem
{
    if ([self.item isKindOfClass:[SWStringTextViewItem class]])
        return (SWStringTextViewItem*)self.item;
    
    return nil;
}

- (void)_updateText
{
    SWStringTextViewItem *item = [self _textViewItem];
    
    NSString *format = [item.format valueAsStringWithFormat:nil];
    NSString *text = [item.value valueAsStringWithFormat:format];
    _textView.text = text;
}

- (void)_updateTextColor
{
    SWStringTextViewItem *item = [self _textViewItem];
    _textView.textColor = item.textColor.valueAsColor;
}

- (void)_updateBackgroundTextColor
{
    SWStringTextViewItem *item = [self _textViewItem];
    _textView.backgroundColor = item.backgroundColor.valueAsColor;
}

- (void)_updateTextFont
{
    SWStringTextViewItem *item = [self _textViewItem];
    
    UIFont *font = [UIFont fontWithName:item.font.valueAsString size:item.fontSize.valueAsDouble];
    _textView.font = font;
}


- (void)_updateTextAlignment
{
    SWStringTextViewItem *item = [self _textViewItem];
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
    _textView.textAlignment = aligment;
}

//- (void)_updateSecureInput
//{
//    SWStringTextViewItem *item = [self _textViewItem];
//    BOOL secureInput = item.secureInput.valueAsBool;
//    _textView.secureTextEntry = secureInput;
//}


//- (void)_updateStyle
//{
//    SWStringTextViewItem *item = [self _textViewItem];
//    SWTextFieldStyle style = item.style.valueAsInteger;
//    
//    switch ( style )
//    {
//        case SWTextFieldStyleBezel:
//            _textView.borderStyle = UITextBorderStyleRoundedRect;
//            break;
//            
//        case SWTextFieldStylePlain:
//            _textView.borderStyle = UITextBorderStyleNone;
//            break;
//    }
//}



- (void)_setEnabledState
{
//    SWStringTextFieldItem *item = [self _textFieldItem];
//    BOOL enabled = item.enabled.valueAsBool;
//    [_textField setEnabled:enabled];
//
//      ^ comentat fora perque igualment filtrem en textFieldShouldBeginEditing i no hi ha cap diferencia visual
}

- (void)_evalItemValueWithText:(NSString*)text
{
    SWStringTextViewItem *item = [self _textViewItem];
    [item.value evalWithStringConstant:(CFStringRef)text];
}

- (void)_evalItemContinuousValueWithText:(NSString*)text
{
    SWStringTextViewItem *item = [self _textViewItem];
    [item.continuousValue evalWithString:text];
}


- (void)_checkPointForText:(NSString*)text
{
    SWStringTextViewItem *item = [self _textViewItem];
    __weak id theSelf = self;
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

#pragma mark - TextView Delegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    SWStringTextViewItem *item = [self _textViewItem];
    return item.enabled.valueAsBool;
}

- (void)delayedSelectAll
{
    UITextPosition *beg = _textView.beginningOfDocument;
    UITextPosition *end = _textView.endOfDocument;
    UITextRange *range = [_textView textRangeFromPosition:beg toPosition:end];
    _textView.selectedTextRange = range;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    SWStringTextViewItem *item = [self _textViewItem];
    item.controlIsEditing = YES;
    
    SWTextSelectionStyle selectionStyle = [item.textSelectionStyle valueAsInteger];
    if ( selectionStyle == SWTextSelectionStyleAll )
        [self performSelector:@selector(delayedSelectAll) withObject:nil afterDelay:0.1];  // 0.2 aprox el temps de surtir el teclat
}

//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    BOOL valid = YES;
    
    if ( valid )
    {
        NSString *resultString = [textView.text stringByReplacingCharactersInRange:range withString:text];
        [self _evalItemContinuousValueWithText:resultString];
    }
    
    return valid;
}


- (void)textViewDidEndEditing:(UITextView *)textView
{
    NSString *text = [textView text];
    
    if (textView == _textView)
    {
        [self _checkPointForText:text];
    }
}

//- (BOOL)textFieldShouldReturn:(UITextField *)textField
//{
//    [textField resignFirstResponder];
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
    SWStringTextViewItem *item = [self _textViewItem];
    
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
    
//    else if (value == item.secureInput)
//        [self _updateSecureInput];
//    
//    else if (value == item.style)
//        [self _updateStyle];
    
    else if (value == item.enabled )
        [self _setEnabledState];
        
    else
    {
        [super value:value didEvaluateWithChange:changed];
    }
}



@end
