//
//  SWExpressionInputController.m
//  HmiPad
//
//  Created by Joan on 13/02/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//


#import "SWExpressionInputController.h"
#import "RpnBuilder.h"

#import "RoundedTextView.h"
#import "RoundedTextViewDelegate.h"
#import "ColoredButton.h"

#import "SWObject.h"
#import "SWDocumentModel.h"
#import "SWModelManager.h"
#import "SWExpressionCompleter.h"
#import "SWExpressionKeyboardView.h"
#import "SWKeyboardListener.h"
#import "SWTableFieldsController.h"
#import "SWTableFieldsControllerDelegate.h"

#import "SWColor.h"
#import <QuartzCore/QuartzCore.h>


@class ExpressionInputTextView;


#pragma mark ExpressionInputTextView

@protocol ExpressionInputTextViewDelegate

- (void)inputTextViewDidChangeWidth:(ExpressionInputTextView*)contentView;

@end


@interface ExpressionInputTextView : RoundedTextView

@property (nonatomic, weak) id<ExpressionInputTextViewDelegate> inputControllerDelegate;

@end


@implementation ExpressionInputTextView
{
    CGFloat _oldWidth;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat newWidth = self.bounds.size.width;
    
    if ( newWidth != _oldWidth )
    {
        _oldWidth = newWidth;
        [_inputControllerDelegate inputTextViewDidChangeWidth:self];
    }
}


//- (NSArray*)keyCommands
//{
//    return @
//    [
//        [UIKeyCommand keyCommandWithInput:UIKeyInputUpArrow modifierFlags:0 action:@selector(upArrow:)],
//        [UIKeyCommand keyCommandWithInput:UIKeyInputDownArrow modifierFlags:0 action:@selector(downArrow:)],
//        [UIKeyCommand keyCommandWithInput:UIKeyInputEscape modifierFlags:0 action:@selector(swescape:)],
//        //[UIKeyCommand keyCommandWithInput:UIKeyInputLeftArrow modifierFlags:0 action:@selector(swleftArrow:)],
//        //[UIKeyCommand keyCommandWithInput:UIKeyInputRightArrow modifierFlags:0 action:@selector(swrightArrow:)],
//        //[UIKeyCommand keyCommandWithInput:@"\r" modifierFlags:0 action:@selector(enter:)],
//        [UIKeyCommand keyCommandWithInput:@"\t" modifierFlags:0 action:@selector(tab:)],
//    ];
//}
//
//
//
//- (void)upArrow:(UIKeyCommand *)keyCommand
//{
//    NSLog( @"up");
//}
//
//- (void)downArrow:(UIKeyCommand *)keyCommand
//{
//    NSLog( @"down");
//}
//
//- (void)swleftArrow:(UIKeyCommand *)keyCommand
//{
//    NSLog( @"left");
//}
//
//- (void)swrightArrow:(UIKeyCommand *)keyCommand
//{
//    NSLog( @"right");
//}
//
//- (void)enter:(UIKeyCommand *)keyCommand
//{
//    NSLog( @"enter");
//}
//
//- (void)tab:(UIKeyCommand *)keyCommand
//{
//    NSLog( @"tab");
//}
//
//- (void)swescape:(UIKeyCommand *)keyCommand
//{
//    NSLog( @"escape");
//}

@end


#pragma mark HitTestView

@interface HitTestView:UIView

@end


@implementation HitTestView


// considerem que el punt es dins si el punt es dins de ell mateix o de qualsevol subview
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    BOOL isInside = [super pointInside:point withEvent:event];
    if ( isInside == NO )
    {
        for ( UIView *sub in [self.subviews reverseObjectEnumerator] )
        {
            CGPoint pt = [self convertPoint:point toView:sub];
            isInside = [sub pointInside:pt withEvent:event];
            if ( isInside )
                return isInside;
        }
    }
    return isInside;
}

@end


#pragma mark SWInputBaseView

@interface SWInputBaseView : HitTestView
@property (nonatomic, weak) IBOutlet ExpressionInputTextView *captionTextView;
@property (nonatomic, weak) IBOutlet UIButton *toggleButton;
@property (nonatomic, weak) IBOutlet UIToolbar *toolbar;

- (CGFloat)heightThatFits;
@end

@implementation SWInputBaseView

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext() ;
    
    UIColor *linecolor1 = [UIColor colorWithWhite:0.0f alpha:1.0f];
//    UIColor *linecolor2 = [UIColor colorWithWhite:0.8f alpha:1.0f];
    
    CGContextMoveToPoint( context, rect.origin.x, rect.origin.y+0.5 ) ;
    CGContextAddLineToPoint( context, rect.origin.x + rect.size.width, rect.origin.y+0.5 ) ;
    CGContextSetLineWidth( context, 1 ) ;
    CGContextSetStrokeColorWithColor( context, [linecolor1 CGColor]) ;
    CGContextStrokePath( context ) ;
    
//    CGContextMoveToPoint( context, rect.origin.x, rect.origin.y+rect.size.height-0.5 ) ;
//    CGContextAddLineToPoint( context, rect.origin.x + rect.size.width, +rect.size.height-0.5 ) ;
//    CGContextSetLineWidth( context, 1 ) ;
//    CGContextSetStrokeColorWithColor( context, [linecolor2 CGColor]) ;
//    CGContextStrokePath( context ) ;
    
    [super drawRect:rect] ;
}



- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    CGRect tButtonFrame = _toggleButton.frame;
    CGRect tViewFrame = _captionTextView.frame;
    CGRect tBarFrame = _toolbar.frame;
    
    if ( bounds.size.width <= 320 )
    {
        tViewFrame.origin.x = 10;
        tViewFrame.size.width = bounds.size.width - (10+10);
        tViewFrame.origin.y = 10;
        tViewFrame.size.height = bounds.size.height - (10+56);
    }
    else
    {
        tViewFrame.origin.x = tButtonFrame.origin.x + tButtonFrame.size.width + 5;
        tViewFrame.size.width = tBarFrame.origin.x - tViewFrame.origin.x - 5;
        tViewFrame.origin.y = 10;
        tViewFrame.size.height = bounds.size.height - (10+10);
    }
    [_captionTextView setFrame:tViewFrame];
}


- (CGFloat)heightThatFits
{
    UITextView *textView = _captionTextView.textView;
    [textView layoutSubviews];  // <-- aixo fa que el contentSize sigui el correcte per el texte actual
    
    CGSize size = textView.contentSize;
    CGFloat textHeight = size.height;
    
    CGRect bounds = self.bounds;
    CGFloat height;
    if ( bounds.size.width <= 320 )
    {
        height = textHeight + (10+56);
    }
    else
    {
        height = textHeight + (10+10);
    }
    return height;
}

@end


#pragma mark SWExpressionInputController


static NSString * const SWExpressionInputControllerPresentingControllerKey = @"SWExpressionKeyboard";

@interface SWExpressionInputController()<RoundedTextViewDelegate, SWExpressionCompleterDelegate,ExpressionInputTextViewDelegate, SWExpressionKeyboardViewDelegate, SWModelManagerDelegate, SWModelManagerDataSource, SWTableFieldsControllerDelegate, UITextInputDelegate, UITableViewDataSource,UITableViewDelegate>
{
    SWExpressionCompleter *_expressionCompleter;
    //SWExpressionKeyboardView *_keyboard;
    UIView *_keyboard;
    RoundedTextView *_interfaceTextView;
    
    UIBarButtonItem *_undoButtonItem;
    UIBarButtonItem *_redoButtonItem;
    UIBarButtonItem *_rightButtonItem;
    UIBarButtonItem *_fixedButtonItem;
    UIBarButtonItem *_flexibleButtonItem;
    
    SWTableFieldsController *_rightButton;
    
    SWInputBaseView *_baseView;
    UIView *_view;
    
    NSString *_suggestionText;   // tot
    NSInteger _suggestionPosition;  // posicio teorica del tot
    
    UIView *_suggestionView;
    UITableView *_suggestionTable;
    NSArray *_symbols;
    NSArray *_properties;
    NSArray *_classes;
    NSArray *_methods;
    NSInteger _position;
    
    //SWValue *_lastSelectedValue;
}

// outlets de SWExpressionInputAccessoryView
//@property (nonatomic, weak) IBOutlet ExpressionInputTextView *captionTextView;
//@property (nonatomic, weak) IBOutlet UIButton *toggleButton;
//@property (nonatomic, weak) IBOutlet UIToolbar *toolbar;

//- (IBAction)toggleButtonAction:(id)sender;

@end


@implementation SWExpressionInputController
{
    __weak SWModelManager *_modelManager;
    //SWRevealController *_seekerController;
    NSNumber *_modelBrowserArrayType;
    UIView *_modelBrowserRevealView;
    UIViewController *_rootSeekerViewController;
    UIView *_rootSeekerView;
    BOOL _isSeekerViewVisible;
    BOOL _isShowingExpressionKeyboard;
    BOOL _isObservingKeyboard;
    BOOL _isDismissingAccessory;
    BOOL _pendingAdjustHeight;
}


- (id)initWithModelManager:(SWModelManager*)manager
{
    self = [super init];
    if ( self )
    {
        _modelManager = manager;
    }
    return self;
}


- (void) dealloc
{
    [self stopObserving];
}


- (NSArray*)_barButtonItems
{
    NSArray *barButtonItems;
    
    if ( YES )
    {
        barButtonItems = @[_undoButtonItem,_fixedButtonItem,_redoButtonItem,_fixedButtonItem,_flexibleButtonItem,_rightButtonItem];
        
//        barButtonItems = @[_undoButtonItem,_redoButtonItem,_flexibleButtonItem,_rightButtonItem];
    }
    return barButtonItems;
}


- (void)reloadToolbarItemsAnimated:(BOOL)animated
{
    [_baseView.toolbar setItems:[self _barButtonItems] animated:animated];
}


- (UIViewController *)rootSeekerViewControllerV
{
    if ( _rootSeekerViewController == nil )
    {
        _rootSeekerViewController = [[UIViewController alloc] init]; // SWFloatingPopoverController needs a parent view controller
         [_modelManager registerPresentingController:_rootSeekerViewController withIdentifier:SWExpressionInputControllerPresentingControllerKey];
        
//        UIView *inputAccesoryViewSuperview = self.view.superview; // HACK: If we use _view directly the floating popover will be shown BELOW the text selection handles. Since we use the superview, we need to do this AFTER we make _view the inputAccesoryView.
//        _inputAccesoryViewController.view = inputAccesoryViewSuperview;
        
        // Note, the above causes sporadic crashes due to re-assigning a view to another controller
        // so we just use _baseView to prevent a crashing bug when using the superview. The selection handles will appear on top though :-(
        // Also note that by using self.view an -odd- additional problem would appear related with firstResponder status. I suppose this is because
        // self.view is used as inputAccessoryView and should not be associated to any controller
        _rootSeekerViewController.view = _baseView ;
    }
    return _rootSeekerViewController;
}


- (UIViewController *)rootSeekerViewController
{
    if ( _rootSeekerViewController == nil )
    {
        _rootSeekerView = [[HitTestView alloc] initWithFrame:CGRectMake(0,0, 200, 200)];
        [_rootSeekerView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin];
        
        //[self.view addSubview:_rootSeekerView];
        
        _rootSeekerViewController = [[UIViewController alloc] init]; // SWFloatingPopoverController needs a parent view controller
        [_modelManager registerPresentingController:_rootSeekerViewController withIdentifier:SWExpressionInputControllerPresentingControllerKey];

        _rootSeekerViewController.view = _rootSeekerView;
        
        
        [self.view addSubview:_rootSeekerView];
        [self _adjustSeekerViewVisible:NO];
    }
    return _rootSeekerViewController;
}


- (void)setView:(UIView*)view
{
    _view = view;
}


- (UIView *)view
{
    if ( _view == nil )
        [self loadView];

    return _view;
}

- (void)loadView
{
    CGRect initialBounds = CGRectMake(0,0,200,100);
    
    UIView *view = [[HitTestView alloc] initWithFrame:initialBounds];
    view.clipsToBounds = NO;
    
    self.view = view;
    
    NSString *nibName;
    if ( IS_IOS7 ) nibName = @"SWExpressionInputAccessoryView";
    else nibName = @"SWExpressionInputAccessoryView6";
    UINib *nib = [UINib nibWithNibName:nibName bundle:nil];
    _baseView = [[nib instantiateWithOwner:self options:nil] objectAtIndex:0];
    [_baseView setContentMode:UIViewContentModeRedraw];
    [_baseView.toggleButton addTarget:self action:@selector(toggleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    _baseView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    //_baseView.backgroundColor = [UIColor colorWithWhite:0.7f alpha:0.7f];
    //_baseView.backgroundColor = [UIColor colorWithWhite:0.9f alpha:0.98f];
    _baseView.backgroundColor = [UIColor clearColor];
    
    CGRect baseViewBounds = _baseView.bounds;
    
    
    // THE MOST UNEXPECTED: http://stackoverflow.com/questions/17704240/ios-7-dynamic-blur-effect-like-in-control-center
        UIToolbar *tb = [[UIToolbar alloc] initWithFrame:baseViewBounds];
        tb.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        //toolbar.barTintColor = selfView.tintColor;
        tb.barTintColor = nil;
        [_baseView insertSubview:tb atIndex:0];
    
    
    CGRect viewFrame = baseViewBounds;
    //viewFrame.size.height += 20;
    view.frame = viewFrame;
    
    CGRect baseViewFrame = baseViewBounds;
    //baseViewFrame.origin.y += 20;
    _baseView.frame = baseViewFrame;
    
    [view addSubview:_baseView];
    
    
//    _baseView.backgroundColor = [UIColor greenColor];
//    view.backgroundColor = [UIColor yellowColor];
    
    
    if ( [_baseView.toggleButton respondsToSelector:@selector(setRgbTintColor:overWhite:)] )
        [(ColoredButton*)_baseView.toggleButton setRgbTintColor:rgbColorForUIcolor([UIColor grayColor]) overWhite:NO];
    
    
    _undoButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"1026-revert-toolbar-flip1.png"]
        style:UIBarButtonItemStylePlain target:self action:@selector(undoButtonAction:)];
    
//    _undoButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"undoarrow.png"]
//        style:UIBarButtonItemStylePlain target:self action:@selector(undoButtonAction:)];
    
    //// WARNING NO VA !
//    [_undoButtonItem setTitleTextAttributes:@{UITextAttributeTextColor:[UIColor whiteColor]} forState:UIControlStateNormal];
//    [_undoButtonItem setTitleTextAttributes:@{UITextAttributeTextColor:[UIColor whiteColor]} forState:UIControlStateDisabled];
    ////
    
    _redoButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"1026-revert-toolbar-flip2.png"]
        style:UIBarButtonItemStylePlain target:self action:@selector(redoButtonAction:)];
    
//    _redoButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"redoarrow.png"]
//        style:UIBarButtonItemStylePlain target:self action:@selector(redoButtonAction:)];

    _rightButtonItem = [[UIBarButtonItem alloc] init];
    
    _fixedButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
        target:nil action:0];
    _fixedButtonItem.width = 4;
    
    _flexibleButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
        target:nil action:0];
    
    UIImage *emptyImage = [[UIImage alloc] init];
    UIToolbar *toolbar = _baseView.toolbar;
    [toolbar setBackgroundImage:emptyImage forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    [toolbar setShadowImage:emptyImage forToolbarPosition:UIToolbarPositionAny];
    [toolbar setBackgroundColor:[UIColor clearColor]];
    [self reloadToolbarItemsAnimated:NO];
    
    SWExpressionKeyboardView *keyboardView = [[SWExpressionKeyboardView alloc] init];
    keyboardView.textInput = [_baseView.captionTextView textView];
    keyboardView.delegate = self;
    

//#if USE_UIINPUTVIEW
////    [keyboardView setBackgroundColor:[UIColor clearColor]];
//    UIColor *baseColor = [UIColor colorWithRed:0.81 green:0.82 blue:0.84 alpha:0.667];
//    [keyboardView setBackgroundColor:baseColor];
////    _keyboard = [[UIInputView alloc] initWithFrame:keyboardView.bounds inputViewStyle:UIInputViewStyleKeyboard];
////    [_keyboard addSubview:keyboardView];
//    
//    _keyboard = keyboardView;
//#else
//    UIColor *baseColor = [UIColor colorWithRed:0.81 green:0.82 blue:0.84 alpha:1];
//    [keyboardView setBackgroundColor:baseColor];
//    _keyboard = keyboardView;
//#endif


#if USE_UIINPUTVIEW
//    [keyboardView setBackgroundColor:[UIColor clearColor]];
    UIColor *baseColor = [UIColor colorWithRed:0.81 green:0.82 blue:0.84 alpha:0.667];
    [keyboardView setBackgroundColor:baseColor];
    _keyboard = [[UIInputView alloc] initWithFrame:keyboardView.bounds inputViewStyle:UIInputViewStyleKeyboard];
    //_keyboard.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [_keyboard addSubview:keyboardView];
    
//    _keyboard = keyboardView;
#else
//
    UIColor *baseColor = nil;
    
    if ( IS_IOS8 )
        baseColor = [UIColor clearColor];
    else
        baseColor = [UIColor colorWithRed:0.81 green:0.82 blue:0.84 alpha:0.667];
    
    [keyboardView setBackgroundColor:baseColor];
    _keyboard = keyboardView;
#endif




    _isShowingExpressionKeyboard = YES;
    
    [self setupCaptionTextView];
    [self _adjustHeightAnimated:NO];
}



-(void)setupCaptionTextView
{
    ExpressionInputTextView *captionTextView = _baseView.captionTextView;
    
    captionTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    captionTextView.borderStyle = UITextBorderStyleBezel;
    captionTextView.wantsFixedOffset = YES;
    captionTextView.delegate = self;
    captionTextView.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:0.96f alpha:1.0f];
    captionTextView.clipsToBounds = NO;

    captionTextView.acceptNewlines = YES;
    captionTextView.inputControllerDelegate = self;
    [captionTextView setBorderColor:[UIColor darkGrayColor]];
    
    UITextView *textView = captionTextView.textView;
    [textView setFont:[UIFont fontWithName:@"Verdana" size:14]];
    [textView setTextColor:UIColorWithRgb(TextDefaultColor)];
    
    if ( IS_IOS7 )
        [textView setScrollEnabled:YES];
    else
        [textView setScrollEnabled:NO];
}


-(void)setDelegate:(id<SWExpressionInputControllerDelegate>)delegate
{
    _delegate = delegate;
}

#pragma mark responder cycle

- (BOOL)shouldPrepareForTextResponder:(RoundedTextView *)textResponder
{
    if ( _isDismissingAccessory )
        return NO;
    
    textResponder.textView.inputAccessoryView = self.view;

    UIView *tmpInputView = nil;
    if ( _isShowingExpressionKeyboard ) tmpInputView = _keyboard;
    textResponder.textView.inputView = tmpInputView;
    return YES;
}


- (void)setTextResponder:(RoundedTextView *)textResponder
{
    [self performSelector:@selector(delayedSetTextResponder:) withObject:textResponder afterDelay:0];
}


- (void)delayedSetTextResponder:(RoundedTextView *)textResponder
{
    _interfaceTextView = textResponder;
    
    [self rootSeekerViewController];

    [self _clearUndoManager];
    
    ExpressionInputTextView *captionTextView = _baseView.captionTextView;
    
    UIView *inputView = nil;
    if ( _isShowingExpressionKeyboard ) inputView = _keyboard;
    [captionTextView.textView setInputView:inputView];
    
    NSString *text = _interfaceTextView.text;
    captionTextView.text = text;
    
    [captionTextView.textView becomeFirstResponder];
    
    [self _adjustHeightAnimated:YES]; //$$$
    [self _searchSuggestions]; //$$$
    
    [self.rightButton startAnimated:YES];
    [_rightButton recordTextResponder:captionTextView];
    
    [self startObserving];
}


- (void)resignResponder
{
    [self stopObserving];
    [self dismissModelBrowser:NO];
    
    ExpressionInputTextView *captionTextView = _baseView.captionTextView;
    [captionTextView.textView resignFirstResponder];
}


- (void)delayedDismiss
{
    _isDismissingAccessory = NO;
    [self _clearUndoManager];
}

#pragma mark suggestion completer

- (SWExpressionCompleter *)expressionCompleter
{
    if ( _expressionCompleter == nil )
    {
        RpnBuilder *builder = _modelManager.documentModel.builder;
        _expressionCompleter = [[SWExpressionCompleter alloc] initWithBuilder:builder interpreter:nil];
        _expressionCompleter.delegate = self;
    }
    
    return _expressionCompleter;
}


- (UITableView*)suggestionTable
{
    if ( _suggestionTable == nil || _suggestionView == nil )
    {
        _suggestionView = [[UIView alloc] initWithFrame:CGRectMake(20,-200,200,200)];
        
        CALayer *layer = _suggestionView.layer;
        //UIBezierPath *path = [UIBezierPath bezierPathWithRect:_suggestionView.bounds];
        
        layer.masksToBounds = NO;
        //layer.shadowPath = path.CGPath;
        layer.shadowOffset = CGSizeMake(0, 1);
        layer.shadowColor = [UIColor colorWithWhite:0.0 alpha:1.0].CGColor;
        
        layer.cornerRadius = 4;
        layer.shadowRadius = 2.5 /*5*/ ;
        layer.shadowOpacity = 0.7;
        
        //_suggestionView.clipsToBounds = YES;
        
        UITableViewStyle tableStyle = UITableViewStyleGrouped;
        _suggestionTable = [[UITableView alloc] initWithFrame:_suggestionView.bounds style:tableStyle];
        _suggestionTable.sectionHeaderHeight = 0;
        _suggestionTable.sectionFooterHeight = 0;
        _suggestionTable.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _suggestionTable.delegate = self;
        _suggestionTable.dataSource = self;
        
        if ( IS_IOS7 )
        {
            [_suggestionTable setSeparatorInset:UIEdgeInsetsMake(0, 15, 0, 15)];
            [_suggestionTable setContentInset:UIEdgeInsetsZero];     // <- no te efecte aqui
            [_suggestionTable setScrollIndicatorInsets:UIEdgeInsetsZero];  // << no te efecte
        }
        
        //_suggestionTable.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:0.96f alpha:1.0f];
        //_suggestionTable.rowHeight = 30;
        //_suggestionTable.bounces = NO;
        
        [_suggestionView addSubview:_suggestionTable];
    }
    return _suggestionTable;
}


- (void)_setSuggestionViewFrame
{
    CGFloat height = [self _tableTotalHeight];
    
    ExpressionInputTextView *captionTextView = _baseView.captionTextView;
    UITextView *textView = captionTextView.textView;
    
    CGRect rect = [textView caretRectForPosition:textView.endOfDocument];
    UITextRange *selectedRange = textView.selectedTextRange;
    CGRect rect1 = [textView caretRectForPosition:selectedRange.end];

    if ( rect1.origin.x < rect.origin.x ) rect = rect1;
    
    CGPoint point = [self.view convertPoint:rect.origin fromView:textView];
    point.x = floorf(point.x);
    point.y = floorf(point.y);
    
    CGRect bounds = self.view.bounds;
    
    CGRect frame;
    frame.size.width = 200;
    frame.origin.x = MIN(point.x, bounds.size.width-frame.size.width-10);
    frame.size.height = MIN( height, 200 );
    frame.origin.y = -frame.size.height+point.y-5;
    
    _suggestionView.frame = frame;
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:_suggestionView.bounds];
    _suggestionView.layer.shadowPath = path.CGPath;
}


#pragma mark height adjustment

- (void)_adjustHeightAnimated:(BOOL)animated
{
    if ( _pendingAdjustHeight == NO )
    {
        [self performSelector:@selector(_delayedAdjustHeightAnimated:) withObject:@(animated) afterDelay:0.0];
    }
}


- (void)_delayedAdjustHeightAnimated:(NSNumber*)animatedNumber
{
    _pendingAdjustHeight = NO;
    
    ExpressionInputTextView *captionTextView = _baseView.captionTextView;
    if ( captionTextView )
    {
        BOOL animated = [animatedNumber boolValue];
        [self _doAdjustHeightAnimated:animated];
        [self _showSuggestions];
    }
}


//- (void)_doAdjustHeightAnimatedV:(BOOL)animated
//{
//    UIView *view = self.view;
//
//    CGRect rect = view.bounds;
//    
//    ExpressionInputTextView *captionTextView = _baseView.captionTextView;
//    UITextView *textView = captionTextView.textView;
//    [textView layoutSubviews];  // <-- aixo fa que el contentSize sigui el correcte per el texte actual
//    
////    UITextRange *textRange = [textView textRangeFromPosition:textView.beginningOfDocument toPosition:textView.endOfDocument];
////    CGRect textViewRect = [textView firstRectForRange:textRange];
////    CGFloat textHeight = textViewRect.size.height;
//    
//    CGSize size = textView.contentSize;
//    CGFloat textHeight = size.height;
//    
//    CGRect baseViewRect = rect;
//    baseViewRect.size.height = textHeight + (10+10);
//    
//    CGSize oldBaseSize = _baseView.bounds.size;
//    CGSize newBaseSize = baseViewRect.size;
//    
//    if ( CGSizeEqualToSize( oldBaseSize, newBaseSize) )
//        return;
//    
//    CGRect newViewRect = rect;
//    newViewRect.size.height = textHeight + (10+10);
//    view.frame = newViewRect;
//    
//    void (^block)() = ^
//    {
//        _baseView.frame = baseViewRect;
//    };
//    
//    if ( animated )
//    {
//        [UIView animateWithDuration:0.3 animations:block completion:nil];
//    }
//    else
//    {
//        block();
//    }
//}




//- (void)_doAdjustHeightAnimatedVV:(BOOL)animated
//{
//    UIView *view = self.view;
//
//    CGRect rect = view.bounds;
//    
//    ExpressionInputTextView *captionTextView = _baseView.captionTextView;
//    UITextView *textView = captionTextView.textView;
//    [textView layoutSubviews];  // <-- aixo fa que el contentSize sigui el correcte per el texte actual
//    
//    CGSize size = textView.contentSize;
//    CGFloat textHeight = size.height;
//    
//    CGRect baseViewRect = rect;
//    baseViewRect.size.height = textHeight + (10+10);
//    
//    CGSize oldBaseSize = _baseView.bounds.size;
//    CGSize newBaseSize = baseViewRect.size;
//    
//    if ( CGSizeEqualToSize( oldBaseSize, newBaseSize) )
//        return;
//    
//    CGRect newViewRect = rect;
//    newViewRect.size.height = textHeight + (10+10);
//    view.frame = newViewRect;
//    
//    void (^block)() = ^
//    {
//        _baseView.frame = baseViewRect;
//    };
//    
//    if ( animated )
//    {
//        [UIView animateWithDuration:0.3 animations:block completion:nil];
//    }
//    else
//    {
//        block();
//    }
//}


- (void)_doAdjustHeightAnimatedV:(BOOL)animated
{
    UIView *view = self.view;

    CGRect rect = view.bounds;
    
//    ExpressionInputTextView *captionTextView = _baseView.captionTextView;
//    UITextView *textView = captionTextView.textView;
//    [textView layoutSubviews];  // <-- aixo fa que el contentSize sigui el correcte per el texte actual
//    
//    CGSize size = textView.contentSize;
//    CGFloat textHeight = size.height;
    
    CGFloat heightThatFits = [_baseView heightThatFits];
    
    CGRect baseViewRect = rect;
    baseViewRect.size.height = heightThatFits;
    
    CGSize oldBaseSize = _baseView.bounds.size;
    CGSize newBaseSize = baseViewRect.size;
    
    if ( CGSizeEqualToSize( oldBaseSize, newBaseSize) )
        return;
    
    // set the frame of the input accessory view;
    CGRect newViewRect = rect;
    newViewRect.size.height = heightThatFits;
    view.frame = newViewRect;
    [view.superview setNeedsLayout];  // xxx
    
    NSLog( @"viewFrame: %@", NSStringFromCGRect(newViewRect));
    
    // set the frame of the baseView
    void (^block)() = ^
    {
        _baseView.frame = baseViewRect;
    };
    
    if ( animated )
    {
        [UIView animateWithDuration:0.3 animations:block completion:nil];
    }
    else
    {
        block();
    }
}


- (void)_doAdjustHeightAnimated:(BOOL)animated
{
    UIView *view = self.view;
    
    CGRect rect = view.bounds;
    
    CGFloat heightThatFits = [_baseView heightThatFits];
    
    CGRect baseViewRect = rect;
    baseViewRect.size.height = heightThatFits;
    baseViewRect.origin.y = rect.size.height-heightThatFits;
    
    CGSize oldBaseSize = _baseView.bounds.size;
    CGSize newBaseSize = baseViewRect.size;
    
    if ( CGSizeEqualToSize( oldBaseSize, newBaseSize) )
        return;
    
    // set the frame of the input accessory view;
//    CGRect newViewRect = rect;
//    newViewRect.size.height = heightThatFits;
//    view.frame = newViewRect;
//    [view.superview setNeedsLayout];  // xxx
    
//    NSLog( @"viewFrame: %@", NSStringFromCGRect(view.frame));
    
    // set the frame of the baseView
    void (^block)() = ^
    {
        _baseView.frame = baseViewRect;
    };
    
    if ( animated )
    {
        [UIView animateWithDuration:0.3 animations:block completion:nil];
    }
    else
    {
        block();
    }
}



//- (void)_adjustSeekerViewVisibleX:(BOOL)visible
//{
//    CGFloat gap = 1;
//    if ( IS_IPHONE && visible )
//    {
//        SWKeyboardListener *keyb = [SWKeyboardListener sharedInstance];
//        gap = [keyb gap];
//    }
//    
//    _isSeekerViewVisible = visible;
//    
//    CGRect frame = self.view.bounds;
//    frame.origin.y = -gap;
//    frame.size.height = gap;
//    
//    _rootSeekerView.frame = frame;
//}


- (void)_adjustSeekerViewVisible:(BOOL)visible
{
    UIView *view = self.view;
    CGRect frame;
    if ( IS_IPHONE && visible )
    {
        CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
        //frame = [view convertRect:appFrame fromView:nil];

        UIWindow *window = view.window;
        CGRect rect0 = [window convertRect:appFrame fromWindow:nil];
        // ^- fa la rotacio del rect si cal
        frame = [window convertRect:rect0 toView:view];
    }
    else
    {
        frame = view.bounds;
        frame.origin.y = 0;
        frame.size.height = 1;
    }
    
    _isSeekerViewVisible = visible;
    
    _rootSeekerView.frame = frame;
}


#pragma mark UndoRedo


- (void)_clearUndoManager
{
    UITextView *textView = [_baseView.captionTextView textView];
    NSUndoManager *undoMgr = [textView undoManager];
    [undoMgr removeAllActions];
    [self _updateUndoButtons];
}

- (void)_updateUndoButtons
{
    UITextView *textView = [_baseView.captionTextView textView];
    NSUndoManager *undoMgr = [textView undoManager];
    [_undoButtonItem setEnabled:[undoMgr canUndo]];
    [_redoButtonItem setEnabled:[undoMgr canRedo]];
}


- (void)undoButtonAction:(id)sender
{
    UITextView *textView = [_baseView.captionTextView textView];
    NSUndoManager *undoMgr = [textView undoManager];
    [undoMgr undo];
}


- (void)redoButtonAction:(id)sender
{
    UITextView *textView = [_baseView.captionTextView textView];
    NSUndoManager *undoMgr = [textView undoManager];
    [undoMgr redo];
}



- (IBAction)toggleButtonAction:(id)sender
{
    UITextView *textView = [_baseView.captionTextView textView];
    UIButton *toggleButton = _baseView.toggleButton;
    if ( _isShowingExpressionKeyboard )
    {
        // Show system keyboard
        [self dismissModelBrowser:NO];
        [toggleButton setTitle:NSLocalizedString(@"1 2 3", @"") forState:UIControlStateNormal];
        [textView setInputView:nil];
        _isShowingExpressionKeyboard = NO;
    }
    else
    {
        // Show expression keyboard
        [toggleButton setTitle:NSLocalizedString(@"a b c", @"") forState:UIControlStateNormal];
        [textView setInputView:_keyboard];
        _isShowingExpressionKeyboard = YES;
    }
    [textView reloadInputViews];
}



#pragma mark - Input

- (void)insertAndSelectText:(NSString*)text
{
    UITextView *textView = [_baseView.captionTextView textView];
    [textView replaceRange:textView.selectedTextRange withText:text];
    UITextPosition *end = textView.selectedTextRange.end;
    UITextPosition *start = [textView positionFromPosition:end offset:-text.length];
    textView.selectedTextRange = [textView textRangeFromPosition:start toPosition:end];
}


#pragma mark - Model Browser

-(void)dismissModelBrowser:(BOOL)animated
{
    [_modelManager dismissModelSeekerFromControllerWithIdentifier:SWExpressionInputControllerPresentingControllerKey animated:animated];
}

//- (void)showModelBrowserWithStartingObject:(id)startingObject fromView:(UIView*)revealView
//{
//    _modelBrowserRevealView = revealView;
//    [_modelManager showRootModelPickerOnPresentingControllerWithIdentifier:SWExpressionInputControllerPresentingControllerKey context:nil delegate:self dataSource:self animated:YES];
//}

#pragma mark Suggestions

- (void)_showSuggestionTable
{
    [self suggestionTable];
    [_suggestionTable reloadData];
    
    [self _setSuggestionViewFrame];
    
    _suggestionView.alpha = 1.0f;
    [_baseView addSubview:_suggestionView];
}

- (void)_hideSuggestionTableAnimated:(BOOL)animated
{
    UIView *tmpView = _suggestionView;
    if ( animated )
    {
        [UIView animateWithDuration:0.25 animations:^
        {
            tmpView.alpha = 0.0f;
        }
        completion:^(BOOL finished)
        {
            [tmpView removeFromSuperview];
        }];
    }
    else
    {
        [tmpView removeFromSuperview];
    }
}


- (void)_showSuggestions
{
    ExpressionInputTextView *captionTextView = _baseView.captionTextView;
    
    [_rightButton dismisInfoMessageAnimated:YES];
    [_rightButton resetIndicatorForField:captionTextView animated:YES];

    NSString *text = captionTextView.text;
    NSRange selectedRange = captionTextView.selectedRange;
    
    if ( text.length < _suggestionPosition ||
        selectedRange.length > 0 ||
        selectedRange.location <= _suggestionPosition ||
        selectedRange.location != text.length ||
        NO == [_suggestionText hasPrefix:[text substringWithRange:NSMakeRange(_suggestionPosition, selectedRange.location-_suggestionPosition)]] )
        
    {
        [self _resetSuggestions];
    }
    else
    {
        [self _hideSuggestionTableAnimated:YES];
        [self _updateSuggestionString];
    }
    
    [self _searchSuggestions];
}


- (void)_searchSuggestions
{
    ExpressionInputTextView *captionTextView = _baseView.captionTextView;
 
    NSString *text = captionTextView.text;
    NSRange selectedRange = captionTextView.selectedRange;
    if ( selectedRange.length == 0 )
    {
        if ( selectedRange.location < text.length )
            text = [text substringToIndex:selectedRange.location];

        [self.expressionCompleter processSourceString:text];
    }
}

- (void)_resetSuggestions
{
    _suggestionText = @"";
    _suggestionPosition = 0;
    [self _updateSuggestionString];
    [self _hideSuggestionTableAnimated:YES];
}


- (void)_updateSuggestionString
{
    ExpressionInputTextView *captionTextView = _baseView.captionTextView;
    
    NSRange selectedRange = captionTextView.selectedRange;
    NSInteger position = selectedRange.location+selectedRange.length-_suggestionPosition;
    NSString *suggestionString = @"";
    
    if ( position < _suggestionText.length)
        suggestionString = [_suggestionText substringFromIndex:position];
    
    captionTextView.suggestionString = suggestionString;
}


#pragma mark Protocol SWTableFieldsController

- (SWTableFieldsController *)rightButton
{
    if (_rightButton == nil)
        _rightButton = [[SWTableFieldsController alloc] initWithOwner:self];
        
    return _rightButton;
}

#pragma mark Protocol SWTableFieldsController delegate

- (void)tableFieldsController:(SWTableFieldsController*)controller didProvideControl:(UIControl*)aControl animated:(BOOL)animated
{
    _rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:aControl];
    [self reloadToolbarItemsAnimated:animated];
}

- (UIView*)tableFieldsControllerBubblePresentingView:(SWTableFieldsController *)controller
{
    return self.view;
}

- (BOOL)tableFieldsController:(SWTableFieldsController*)controller validateField:(id)field 
        forCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath outErrorString:(NSString **)errorString
{
    UITextView *textView = field;
    NSString *text = textView.text;
    
    if ([text isEqualToString:@""])
        return  YES;   // el apply del controlador associat posara el valor per defecte
    
    RpnBuilder *builder = _modelManager.documentModel.builder;
    BOOL valid = [RpnBuilder isValidExpressionSource:text forBuilderInstance:builder outErrString:errorString];
    
    return valid;
}


- (void)tableFieldsControllerCancel:(SWTableFieldsController *)controller animated:(BOOL)animated
{
    [self resignResponder];
    [_delegate expressionInputControllerCancel:self];
    
}

- (void)tableFieldsControllerApply:(SWTableFieldsController*)controller animated:(BOOL)animated
{
    [self resignResponder];
    [_delegate expressionInputControllerApply:self];
}



#pragma mark inputDelegate

- (void)textWillChange:(id <UITextInput>)textInput
{
    //NSLog(@"textWillChange");
}

- (void)textDidChange:(id <UITextInput>)textInput
{
    //NSLog(@"textDidChange");
}


- (void)selectionWillChange:(id <UITextInput>)textInput
{

}


- (void)selectionDidChange:(id <UITextInput>)textInput
{

}


#pragma mark RoundedTextViewDelegate

- (BOOL)roundedTextViewShouldBeginEditing:(RoundedTextView *)roundedTextView
{
    // workaround to force text to show
    // http://stackoverflow.com/questions/11200726/text-in-uitextview-not-display-correctly-invisible-but-occupied-spaces
    //
    
    //UITextView
//    CGRect tempFrame = _captionTextView.frame;
//    [_captionTextView setFrame:CGRectZero];    // cucut
//    [_captionTextView setFrame:tempFrame];
    
//    CGRect tempFrame2 = _backTextView.frame;
//    [_backTextView setFrame:CGRectZero];
//    [_backTextView setFrame:tempFrame2];

    // NSLog( @"InputConfigurator ++ I shouldBeginEditing");

    
    return YES;
}

- (void)roundedTextViewDidBeginEditing:(RoundedTextView *)roundedTextView
{
   // NSLog( @"InputConfigurator ++ I didBeginEditing");
}


- (void)roundedTextViewDidChange:(RoundedTextView *)roundedTextView
{
    NSString *text = roundedTextView.text;
    _interfaceTextView.text = text;

    [self _adjustHeightAnimated:YES];
    [self _updateUndoButtons];
}

- (void)roundedTextViewDidChangeSelection:(RoundedTextView *)roundedTextView
{    
    [self _showSuggestions];
}


- (BOOL)roundedTextView:(RoundedTextView *)roundedTextView shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}


- (BOOL)roundedTextViewShouldEndEditing:(RoundedTextView *)roundedTextView
{
    //NSLog( @"InputConfigurator -- I shouldEndEditing");
    
    _isDismissingAccessory = YES;
    return YES;
}


- (void)roundedTextViewDidEndEditing:(RoundedTextView *)textView
{
    //NSLog( @"InputConfigurator -- I didEndEditing");
    
    ExpressionInputTextView *captionTextView = _baseView.captionTextView;
    
    [captionTextView setText:nil];
    [self performSelector:@selector(delayedDismiss) withObject:nil afterDelay:0];
}


- (BOOL)roundedTextViewShouldReturn:(RoundedTextView *)roundedTextView
{
    [_interfaceTextView.delegate roundedTextViewShouldReturn:_interfaceTextView];
    return YES;
}



#pragma mark ExpressionInputContentViewDelegate


- (void)inputTextViewDidChangeWidth:(ExpressionInputTextView *)contentView
{
    [self _hideSuggestionTableAnimated:NO];
    [self _adjustHeightAnimated:YES /*postChanges:NO*/];
}



#pragma mark ExpressionCompleterDelegate


- (void)expressionCompleter:(SWExpressionCompleter *)completer didSuggestSymbols:(NSArray *)symbols
    properties:(NSArray *)properties classes:(NSArray*)classes methods:(NSArray *)methods atCharPosition:(NSInteger)position
{
//    NSLog( @"expressionCompleter didSuggestSymbols:\n%@", symbols);
//    NSLog( @"expressionCompleter didSuggestProperties:\n%@", properties);
//    NSLog( @"expressionCompleter didSuggestClasses:\n%@", classes);
//    NSLog( @"expressionCompleter didSuggestMethods:\n%@", methods);
//    NSLog( @"expressionCompleter atPosition: %d", position);
    
    _symbols = symbols;
    _properties = properties;
    _classes = classes;
    _methods = methods;
    _position = position;
    
    NSString *firstSuggestion = nil;
    if ( symbols.count > 0 ) firstSuggestion = [symbols objectAtIndex:0];
    else if ( properties.count > 0 ) firstSuggestion = [properties objectAtIndex:0];
    else if ( classes.count > 0 ) firstSuggestion = [classes objectAtIndex:0];
    else if ( methods.count > 0 ) firstSuggestion = [methods objectAtIndex:0];
    
    ExpressionInputTextView *captionTextView = _baseView.captionTextView;
    
    NSString *text = captionTextView.text;
    NSRange selectedRange = captionTextView.selectedRange;
    
    _suggestionPosition = position;
    if ( firstSuggestion )
    {
        if ( selectedRange.length == 0 && selectedRange.location == text.length )
        {
            _suggestionText = firstSuggestion;
        }
        else
        {
            _suggestionText = @"";
        }
    
        [self _updateSuggestionString];
        [self _showSuggestionTable];
    }
    else
    {
        [self _resetSuggestions];
    }
}


#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 0;
    switch ( section )
    {
        case 0 : rows = _symbols.count; break;
        case 1 : rows = _properties.count; break;
        case 2 : rows = _classes.count; break;
        case 3 : rows = _methods.count; break;
    }
    return rows;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    UITableViewCell *cell = nil;
    NSString *identifier = @"Cell";
    
    cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if ( cell == nil )
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        UILabel *textLabel = cell.textLabel;
        if ( IS_IOS7 )
        {
            textLabel.font = [UIFont systemFontOfSize:15];
            UIColor *tintColor = [tableView tintColor];
            textLabel.textColor = tintColor;
            textLabel.highlightedTextColor = [tintColor colorWithAlphaComponent:0.2];
        }
        else
        {
            textLabel.font = [UIFont boldSystemFontOfSize:14];
            textLabel.textColor = UIColorWithRgb(TextDefaultColor);
        }
    }
    
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    
    NSString *text = nil;
    switch ( section )
    {
        case 0 : text = [_symbols objectAtIndex:row]; break;
        case 1 : text = [_properties objectAtIndex:row]; break;
        case 2 : text = [_classes objectAtIndex:row]; break;
        case 3 : text = [_methods objectAtIndex:row]; break;
    }
    cell.textLabel.text = text;
    return cell;
}


#define ROWHEIGHT 30
#define SECTIONHEADERHEIGHT 36

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ROWHEIGHT;
}


- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *text = nil;
    switch ( section )
    {
        case 0 : text = _symbols.count ? @"OBJECTS" : nil; break;
        case 1 : text = _properties.count ? @"PROPERTIES" : nil; break;
        case 2 : text = _classes.count ? @"CLASSES" : nil; break;
        case 3 : text = _methods.count ? @"METHODS" : nil; break;
    }
    return text;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return SECTIONHEADERHEIGHT;
//}


//- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    NSString *text = nil;
//    switch ( section )
//    {
//        case 0 : text = _symbols.count ? @"   SYMBOLS" : nil; break;
//        case 1 : text = _properties.count ? @"   PROPERTIES" : nil; break;
//        case 2 : text = _classes.count ? @"   CLASSES" : nil; break;
//        case 3 : text = _methods.count ? @"   METHODS" : nil; break;
//    }
//    if ( text == nil )
//        return nil;
//    
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 10)];
//    label.text = text;
//    label.font = [UIFont boldSystemFontOfSize:10];
//    label.textAlignment = NSTextAlignmentLeft;
//    label.shadowColor = [UIColor blackColor];
//    label.shadowOffset = CGSizeMake(0, 1);
//    label.backgroundColor = UIColorWithRgb(DarkenedRgbColor(SystemDarkerBlueColor, 1.6f));
//    label.textColor = [UIColor whiteColor];
//
//    return label;
//}

//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    return 0;
//
//    CGFloat height = 0;
//    switch ( section )
//    {
//        case 0 : height = _symbols.count ? SECTIONHEADERHEIGHT : 0; break;
//        case 1 : height = _properties.count ? SECTIONHEADERHEIGHT : 0; break;
//        case 2 : height = _classes.count ? SECTIONHEADERHEIGHT : 0; break;
//        case 3 : height = _methods.count ? SECTIONHEADERHEIGHT : 0; break;
//    }
//    return height;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height = 0;
    switch ( section )
    {
        case 0 : height = _symbols.count ? SECTIONHEADERHEIGHT : 0; break;
        case 1 : height = _properties.count ? SECTIONHEADERHEIGHT : 0; break;
        case 2 : height = _classes.count ? SECTIONHEADERHEIGHT : 0; break;
        case 3 : height = _methods.count ? SECTIONHEADERHEIGHT : 0; break;
    }
    return height;
}


//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    cell.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:0.96f alpha:1.0f];
//}

- (CGFloat)_tableTotalHeight;
{
//    CGFloat totalHeight = 0;
//    CGFloat count = 0;
//    if ( (count = _symbols.count) > 0 ) totalHeight += ROWHEIGHT*count + SECTIONHEADERHEIGHT;
//    if ( (count = _properties.count) > 0 ) totalHeight += ROWHEIGHT*count + SECTIONHEADERHEIGHT;
//    if ( (count = _classes.count) > 0 ) totalHeight += ROWHEIGHT*count + SECTIONHEADERHEIGHT;
//    if ( (count = _methods.count) > 0 ) totalHeight += ROWHEIGHT*count + SECTIONHEADERHEIGHT;
//    return totalHeight;
    
    
    [_suggestionTable layoutSubviews];
    CGSize size = [_suggestionTable contentSize];
    return size.height;
    
}

#pragma mark UITableViewDelegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    
    NSString *string = nil;
    switch ( section )
    {
        case 0 : string = [_symbols objectAtIndex:row]; break;
        case 1 : string = [_properties objectAtIndex:row]; break;
        case 2 : string = [_classes objectAtIndex:row]; break;
        case 3 : string = [_methods objectAtIndex:row]; break;
    }

    ExpressionInputTextView *captionTextView = _baseView.captionTextView;

    NSRange selectedRange = captionTextView.selectedRange;
    NSInteger position = selectedRange.location+selectedRange.length-_suggestionPosition;
    
    if ( string )
    {
        UITextView *textView = captionTextView.textView;
        
        UITextPosition *beginPosition = [textView beginningOfDocument];
        UITextPosition *locationPosition = [textView positionFromPosition:beginPosition offset:_suggestionPosition];
        UITextPosition *sizePosition = [textView positionFromPosition:beginPosition offset:_suggestionPosition+position];
        UITextRange *replaceRange = [textView textRangeFromPosition:locationPosition toPosition:sizePosition];
        
        NSInteger suggestionPositionStore = _suggestionPosition;
        
        [textView replaceRange:replaceRange withText:string];  // <--- aquest no es carrega el UndoManager pero crida didChangeSelection, no hauria!
        captionTextView.selectedRange = NSMakeRange(suggestionPositionStore+string.length, 0);  // crida didChangeSelection, no hauria!
    }
}

#pragma mark - SWExpressionKeyboardViewDelegate

- (void)keyboard:(SWExpressionKeyboardView *)keyboard didTapSeekerKey:(UIView *)revealView
{
    _modelBrowserRevealView = revealView;
    
    // abans de presentar el picker ens assegurem que el accessory view es a sobre de tot, si no el picker pot sortir a sota
    [self.view.superview bringSubviewToFront:self.view];
    
    [_modelManager showRootModelPickerOnPresentingControllerWithIdentifier:SWExpressionInputControllerPresentingControllerKey
        context:nil delegate:self dataSource:self animated:YES];
}


- (void)keyboard:(SWExpressionKeyboardView *)keyboard didTapConnectorsKey:(UIView *)revealView
{
    _modelBrowserRevealView = revealView;
    
    // abans de presentar el picker ens assegurem que el accessory view es a sobre de tot, si no el picker pot sortir a sota
    [self.view.superview bringSubviewToFront:self.view];
    
    [_modelManager showConnectorsPickerOnPresentingControllerWithIdentifier:SWExpressionInputControllerPresentingControllerKey
        context:nil delegate:self dataSource:self animated:YES];
}


#pragma mark - SWModelManagerDelegate

- (void)modelManager:(SWModelManager *)manager didSelectValue:(SWValue *)value context:(id)context
{
    NSString *bindableValue = [value getBindableString];
    [self insertAndSelectText:bindableValue];
}

#pragma mark - SWModelManagerDataSource

- (UIView*)modelManager:(SWModelManager *)manager revealViewForObject:(id)object value:(SWValue *)value context:(id)context
{
    return _modelBrowserRevealView;
}


- (CGRect)modelManager:(SWModelManager *)manager popoverCenterRectForObject:(id)object value:(SWValue *)value context:(id)context
{
    static CGFloat const modelBrowserWidth = 320;
//    const CGPoint origin = _modelBrowserRevealView.frame.origin;
//    return CGPointMake(origin.x - (modelBrowserWidth/2), 0);
    
    CGRect rect = _modelBrowserRevealView.frame;
    rect.origin.x -= (modelBrowserWidth/2);
    rect.origin.y = 0;
    rect.size = CGSizeZero;
    
    return rect;
}

- (void)modelManager:(SWModelManager *)manager willBeginPickerForObject:(id)object value:(SWValue *)value context:(id)context
{
    [self _adjustSeekerViewVisible:YES];
}

- (void)modelManager:(SWModelManager *)manager willEndPickerForObject:(id)object value:(SWValue *)value context:(id)context
{
    [self _adjustSeekerViewVisible:NO];
}

#pragma mark - Notifications

- (void)keyboardDidChangeFrame:(NSNotification*)note
{
    [self _adjustSeekerViewVisible:_isSeekerViewVisible];
}


- (void)keyboardWillHide:(NSNotification*)note
{
    [self dismissModelBrowser:YES];
}

- (void)startObserving
{
    if ( !_isObservingKeyboard )
    {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(keyboardWillHide:) name:SWKeyboardWillHideNotification object:nil];
        [nc addObserver:self selector:@selector(keyboardDidChangeFrame:) name:SWKeyboardDidChangeFrameNotification object:nil];
        _isObservingKeyboard = YES;
    }
}

- (void)stopObserving
{
    if ( _isObservingKeyboard )
    {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc removeObserver:self];
        _isObservingKeyboard = NO;
    }
}


@end



