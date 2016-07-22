//
//  SWExpressionKeyboardView.m
//  HmiPad
//
//  Created by Hermes Pique on 5/9/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import "SWExpressionKeyboardView.h"
#import "SWKeyboardKey.h"
#import "SWKeyboardTouchAndHoldKey.h"

typedef NS_ENUM(NSInteger, SWLeftKeypadMode)
{
    SWLeftKeypadModeLogical = 0,
    SWLeftKeypadModeAritmethic,
    SWLeftKeypadModeControl
};


@implementation SWExpressionKeyboardView
{
    SWLeftKeypadMode _leftKeypadMode;
}

static NSArray *leftKeypadSymbols;
static NSArray *modeButtonTitles;

+ (void)initialize
{
    NSArray *arithmethicSymbols = @[@"+", @"*", @"/", @"-", @"%", @"~", @"&", @"|", @"^"];
    NSArray *controlSymbols = @[@"(", @")", @",", @"[", @"]", @"?", @"{", @"}", @":"];
    if ( IS_IPHONE )
        controlSymbols = @[@"(", @")", @"[", @"]", @"{", @"}", @",",  @"?",  @":"];

    NSArray *logicalSymbols = @[@"!", @"&&", @"||", @"==", @">", @"<", @"!=", @">=", @"<="];
    leftKeypadSymbols = @[logicalSymbols, arithmethicSymbols, controlSymbols];
    modeButtonTitles = @[@"+ * /", @"( [ {", @"! && ||"];
}

- (id)init
{
	const UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	const CGRect frame = UIDeviceOrientationIsLandscape(orientation) ? CGRectMake(0, 0, 1024, 352) : CGRectMake(0, 0, 768, 264);
    
	self = [super initWithFrame:frame];
	if (self)
    {
        NSString *nibName = IS_IPHONE ? @"SWExpressionKeyboardViewPhone" : @"SWExpressionKeyboardView";
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
        SWExpressionKeyboardView *my = [nib objectAtIndex:0];
		[my setFrame:frame];
        
        my.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        
        self = my;
        
        [_leftButton addTouchAndHoldTarget:self action:@selector(leftAction)];
        [_rightButton addTouchAndHoldTarget:self action:@selector(rightAction)];
        [_backspaceButton addTouchAndHoldTarget:self action:@selector(backspaceAction)];
        [self setLeftKeypadMode:SWLeftKeypadModeLogical];
    }
    return self;
}

- (IBAction)customKeyTouchUp:(UIButton*)sender
{
    static NSInteger const seekerKeyTag = 9810;
    static NSInteger const connectorsKeyTag = 3621;
    switch (sender.tag)
    {
        case seekerKeyTag:
            [_delegate keyboard:self didTapSeekerKey:sender];
            break;
        case connectorsKeyTag:
            [_delegate keyboard:self didTapConnectorsKey:sender];
            break;
        default:
            break;
    }
    //[self.delegate keyboard:self touchUpInsideCustomKey:sender];
}

- (IBAction)introTouchUp:(id)sender
{
    static NSString* const text = @"\n";
    if (![self shouldChangeTextInRange:_textInput.selectedTextRange replacementText:text]) return;
	[_textInput insertText:text];
    [self notifyTextInputChange];
}

- (IBAction)keyTouchUp:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSString *text = button.titleLabel.text;
    if (![self shouldChangeTextInRange:_textInput.selectedTextRange replacementText:text]) return;

	[_textInput insertText:text];
    [self notifyTextInputChange];
}

- (IBAction)keyTouchDown:(id)sender
{
    [[UIDevice currentDevice] playInputClick];
}

//- (IBAction)modeTouchUp:(id)sender
//{
//    const SWLeftKeypadMode nextMode = (_leftKeypadMode + 1) % 3;
//    [self setLeftKeypadMode:nextMode];
//}

- (IBAction)modeTouchDown:(id)sender
{
    const SWLeftKeypadMode nextMode = (_leftKeypadMode + 1) % 3;
    [self setLeftKeypadMode:nextMode];
}

- (IBAction)quoteTouchUp:(id)sender
{
    static NSString* const text = @"\"\"";
    if (![self shouldChangeTextInRange:_textInput.selectedTextRange replacementText:text]) return;

	[_textInput insertText:text];

    // Get current position AFTER inserting text. If not, the selected text range behaves strangely.
    UITextRange *currentRange = [_textInput selectedTextRange];
    UITextPosition *currentPosition = currentRange.start;
    
    [self setSelectedPosition:currentPosition offset:-1];
    [self notifyTextInputChange];
}

#pragma mark - UIInputViewAudioFeedback

- (BOOL)enableInputClicksWhenVisible
{
    return YES;
}

#pragma mark - UIView

//- (void)drawRectNO:(CGRect)rect
//{
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSaveGState(context);
//    
//    
//    if ( IS_IOS7 )
//    {
//        UIColor *baseColor = [UIColor colorWithRed:0.81 green:0.82 blue:0.84 alpha:1];
//        CGContextSetFillColorWithColor( context, baseColor.CGColor );
//        CGContextFillRect( context, rect );
//    }
//    
//    else
//    {
//        { // Gradient
//            UIColor *topColor = [UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:167.0/255 alpha:1];
//            UIColor *bottomColor = [UIColor colorWithRed:67.0/255.0 green:67.0/255.0 blue:75.0/255 alpha:1];
//        
//            CGFloat locations[2] = { 0.0, 1.0 };
//            NSArray *colors = @[(__bridge id)topColor.CGColor, (__bridge id)bottomColor.CGColor];
//        
//            CGGradientRef gradient = CGGradientCreateWithColors(NULL, (__bridge CFArrayRef)colors, locations);
//        
//            CGRect currentBounds = self.bounds;
//            CGPoint topCenter = CGPointMake(CGRectGetMidX(currentBounds), 0.0f);
//            CGPoint midCenter = CGPointMake(CGRectGetMidX(currentBounds), CGRectGetMaxY(currentBounds));
//        
//            CGContextDrawLinearGradient(context, gradient, topCenter, midCenter, 0);
//            CGGradientRelease(gradient);
//        }
//        { // Top bevel
//            UIColor *color = [UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255 alpha:1];
//            [color setFill];
//            CGContextFillRect(context, CGRectMake(0, 0, rect.size.width, 1));
//        }
//        { // Bottom bevel
//            UIColor *color = [UIColor colorWithRed:191.0/255.0 green:191.0/255.0 blue:191.0/255 alpha:1];
//            [color setFill];
//            CGContextFillRect(context, CGRectMake(0, 1, rect.size.width, 1));
//        }
//    }
//    CGContextRestoreGState(context);
//}

#pragma mark - Private

- (void)backspaceAction
{
    [[UIDevice currentDevice] playInputClick];
    if ([_textInput hasText])
    {
        if (![self shouldDelete]) return;
        
        [_textInput deleteBackward];
        [self notifyTextInputChange];
    }
    else
    {
        [_backspaceButton cancelHold];
    }
}

- (void)dismiss
{
    if ([_textInput isKindOfClass:[UIResponder class]])
    {
        [(UIResponder*)_textInput resignFirstResponder];
    }
}

- (void)leftAction
{
    [[UIDevice currentDevice] playInputClick];
    UITextRange *currentRange = [_textInput selectedTextRange];
    UITextPosition *currentPosition = currentRange.start;
    if ([_textInput comparePosition:_textInput.beginningOfDocument toPosition:currentPosition] != NSOrderedAscending)
    {
        [_leftButton cancelHold];
    }
    else
    {
        [self setSelectedPosition:currentPosition offset:-1];        
    }
    
}

/* See: http://stackoverflow.com/questions/7010547/uitextfield-text-change-event#comment19243817_7010765 */
- (void)notifyTextInputChange
{
    if ([_textInput isKindOfClass:[UITextView class]])
    {
		[[NSNotificationCenter defaultCenter] postNotificationName:UITextViewTextDidChangeNotification object:_textInput];
        // See: http://stackoverflow.com/questions/13300176/uitextview-delegate-not-called-using-custom-keyboard
        UITextView *textView = (UITextView*)_textInput;
        if ([textView.delegate respondsToSelector:@selector(textViewDidChange:)])
        {
            return [textView.delegate textViewDidChange:textView];
        }
    }
	else if ([_textInput isKindOfClass:[UITextField class]])
    {
		[[NSNotificationCenter defaultCenter] postNotificationName:UITextFieldTextDidChangeNotification object:_textInput];
    }
}

- (void)rightAction
{
    [[UIDevice currentDevice] playInputClick];
    UITextRange *currentRange = [_textInput selectedTextRange];
    UITextPosition *currentPosition = currentRange.end;
    
    if ([_textInput comparePosition:currentPosition toPosition:_textInput.endOfDocument] != NSOrderedAscending)
    {
        [_rightButton cancelHold];
    }
    else
    {
        [self setSelectedPosition:currentPosition offset:1];
    }    
}

- (void)setLeftKeypadMode:(SWLeftKeypadMode)mode
{
    _leftKeypadMode = mode;
    const NSInteger count = _leftKeypadButtons.count;
    NSArray *buttonTitles = [leftKeypadSymbols objectAtIndex:_leftKeypadMode];
    for (int i = 0; i < count; i++)
    {
        UIButton *button = [_leftKeypadButtons objectAtIndex:i];
        NSString *title = [buttonTitles objectAtIndex:i];
        [button setTitle:title forState:UIControlStateNormal];
    }
    NSString *modeButtonTitle = [modeButtonTitles objectAtIndex:_leftKeypadMode];
    [_modeButton setTitle:modeButtonTitle forState:UIControlStateNormal];
}

- (void) setSelectedPosition:(UITextPosition*)position offset:(NSInteger)offset
{
    UITextPosition *nextPosition = [_textInput positionFromPosition:position offset:offset];
    UITextRange *nextRange = [_textInput textRangeFromPosition:nextPosition toPosition:nextPosition];
    [_textInput setSelectedTextRange:nextRange];
}

- (BOOL) shouldDelete
{
    UITextRange *selectedRange = _textInput.selectedTextRange;
    BOOL replace = [_textInput offsetFromPosition:selectedRange.start toPosition:selectedRange.end];
    UITextRange *deleteRange;
    if (replace)
    {
        deleteRange = selectedRange;
    }
    else
    { // Delete 1 character
        UITextPosition *start = [_textInput positionFromPosition:selectedRange.start offset:-1];
        deleteRange = [_textInput textRangeFromPosition:start toPosition:selectedRange.end];
    }
    return [self shouldChangeTextInRange:deleteRange replacementText:@""];
}

/* See: http://stackoverflow.com/questions/13300176/uitextview-delegate-not-called-using-custom-keyboard */
- (BOOL) shouldChangeTextInRange:(UITextRange*)textRange replacementText:(NSString *)text
{
    if ([_textInput isKindOfClass:[UITextView class]])
    {
        UITextView *textView = (UITextView*)_textInput;
        if ([textView.delegate respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementText:)])
        {
            const NSRange range = [SWExpressionKeyboardView rangeFromTextRange:textRange ofInputView:_textInput];
            return [textView.delegate textView:textView shouldChangeTextInRange:range replacementText:text];
        }
    }
	else if ([_textInput isKindOfClass:[UITextField class]])
    {
        UITextField *textField = (UITextField*)_textInput;
        if ([textField.delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)])
        {
            const NSRange range = [SWExpressionKeyboardView rangeFromTextRange:textRange ofInputView:_textInput];
            return [textField.delegate textField:textField shouldChangeCharactersInRange:range replacementString:text];
        }
    }
    return YES;
}

#pragma mark - Utils

+ (NSRange)rangeFromTextRange:(UITextRange*)textRange ofInputView:(id<UITextInput>)textInput
{
    UITextPosition *textRangeStart = textRange.start;
    
    const NSInteger location = [textInput offsetFromPosition:textInput.beginningOfDocument toPosition:textRangeStart];
    const NSInteger length = [textInput offsetFromPosition:textRangeStart toPosition:textRange.end];
    
    return NSMakeRange(location, length);
}

@end
