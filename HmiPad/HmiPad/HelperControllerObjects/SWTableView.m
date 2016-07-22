//
//  SWTableView.m
//  HmiPad
//
//  Created by Joan on 25/02/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import "SWTableView.h"
#import "SWKeyboardListener.h"


@implementation SWTableView
{
    UIEdgeInsets _swBaseInsets;
    UIEdgeInsets _swScrollInsets;
    CGPoint _tableViewOffset;
    BOOL _needsAdjustOffset;
}


//- (id)init
//{
//    self = [super init];
//    if ( self )
//    {
//        NSLog( @"Init SWTableView");
//    }
//    return self;
//}
//
//- (id)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if ( self )
//    {
//        NSLog( @"Init SWTableView");
//    }
//    return self;
//}
//
//- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
//{
//    self = [super initWithFrame:frame style:style];
//    if ( self )
//    {
//        NSLog( @"Init SWTableView");
//    }
//    return self;
//
//}
//
//
//- (id)initWithCoder:(NSCoder *)aDecoder
//{
//    self = [super initWithCoder:aDecoder];
//    if ( self )
//    {
//        NSLog( @"InitWithCoder SWTableView");
//    
//    }
//    return self;
//}



- (void)setTableViewOffset:(CGPoint)tableViewOffset
{
    _needsAdjustOffset = YES;
    _tableViewOffset = tableViewOffset;
    if ( self.superview )
    {
        _needsAdjustOffset = NO;
        self.contentOffset = _tableViewOffset;
    }
        
}

- (CGPoint)tableViewOffset
{
    if ( self.superview )
        _tableViewOffset = self.contentOffset;

    CGPoint offset = _tableViewOffset;
    return offset;
}

- (void)setContentOffset:(CGPoint)contentOffset
{
    //NSLog( @"ContentOffset:%@", NSStringFromCGPoint(contentOffset));
    [super setContentOffset:contentOffset];
}

- (void)setContentInset:(UIEdgeInsets)contentInset
{
    _swBaseInsets = contentInset;
    [super setContentInset:contentInset];
}

- (void)setScrollIndicatorInsets:(UIEdgeInsets)scrollIndicatorInsets
{
    _swScrollInsets = scrollIndicatorInsets;
    [super setScrollIndicatorInsets:scrollIndicatorInsets];
}

- (void)internalSetContentInset:(UIEdgeInsets)contentInset
{
    [super setContentInset:contentInset];
}

- (void)internalSetScrollIndicatorInsets:(UIEdgeInsets)scrollIndicatorInsets
{
    [super setScrollIndicatorInsets:scrollIndicatorInsets];
}

- (void)adjustKeyboardInsetsIfNeeded
{
    SWKeyboardListener *keyb = [SWKeyboardListener sharedInstance];

    if (keyb.isVisible)
    {
        UIApplication *application = [UIApplication sharedApplication];
        UIWindow *applicationWindow = [application delegate].window;
        const BOOL belowKeyboard = [self isDescendantOfView:applicationWindow];
        
        if (belowKeyboard)
        {
            [self _swAdjustInsetsForKeyboard];
            return;
        }
    }
    [self _swResetInsets];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self adjustKeyboardInsetsIfNeeded];
}


//- (void)willMoveToWindow:(UIWindow *)newWindow
//{
//    [super willMoveToWindow:newWindow];
//    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
//    
//    UIWindow *window = newWindow;
//    
//    // added
//    if ( window  )
//    {
//        [nc addObserver:self selector:@selector(_swAdjustInsetsForKeyboardNotification:) name:SWKeyboardWillShowNotification object:nil];
//        [nc addObserver:self selector:@selector(_swAdjustInsetsForKeyboardNotification:) name:SWKeyboardWillHideNotification object:nil];
//        self.contentOffset = _tableViewOffset;
//    }
//    
//    // removed
//    else
//    {
//        [nc removeObserver:self name:SWKeyboardWillShowNotification object:nil];
//        [nc removeObserver:self name:SWKeyboardWillHideNotification object:nil];
//        _tableViewOffset = self.contentOffset;
//    }
//    
//    [self adjustKeyboardInsetsIfNeeded];
//}



- (void)didMoveToWindow
{
    [super didMoveToWindow];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    UIWindow *window = self.window;
    
    // added
    if ( window  )
    {
        [nc addObserver:self selector:@selector(_swAdjustInsetsForKeyboardNotification:) name:SWKeyboardWillShowNotification object:nil];
        [nc addObserver:self selector:@selector(_swAdjustInsetsForKeyboardNotification:) name:SWKeyboardWillHideNotification object:nil];
        if ( _needsAdjustOffset )
        {
            _needsAdjustOffset = NO;
            self.contentOffset = _tableViewOffset;
        }
    }
    
    // removed
    else
    {
        [nc removeObserver:self name:SWKeyboardWillShowNotification object:nil];
        [nc removeObserver:self name:SWKeyboardWillHideNotification object:nil];
        _tableViewOffset = self.contentOffset;

    }
    
    [self adjustKeyboardInsetsIfNeeded];
}


- (void)_swAdjustInsetsForKeyboardNotification:(NSNotification*)note
{
    [self adjustKeyboardInsetsIfNeeded];
}


- (void)_swAdjustInsetsForKeyboard
{
    SWKeyboardListener *keyb = [SWKeyboardListener sharedInstance];
    
    UIWindow *window = self.window;
    CGRect rect0 = [window convertRect:keyb.frame fromWindow:nil];
        // ^- suposo que te efecte en cas que la mida del window no coincideixi amb la pantalla
    CGRect rect = [window convertRect:rect0 toView:self.superview];
        
    CGRect ownFrame = self.frame;
            
    CGFloat offset = ownFrame.origin.y + ownFrame.size.height - rect.origin.y;
    if ( offset < 0 ) offset = 0 ;
    
    UIEdgeInsets insets = _swBaseInsets;
    insets.bottom = offset;
    
    if ( !UIEdgeInsetsEqualToEdgeInsets(insets, self.contentInset) )
    {
        [UIView animateWithDuration:0.25 animations:^
        {
            [self internalSetContentInset:insets];
            [self internalSetScrollIndicatorInsets:insets];
        }];
    }
}


- (void)_swResetInsets
{
    UIEdgeInsets insets = _swBaseInsets;
    UIEdgeInsets sInsets = _swBaseInsets;
    if ( !UIEdgeInsetsEqualToEdgeInsets(insets, self.contentInset)  ||
        !UIEdgeInsetsEqualToEdgeInsets(sInsets, self.scrollIndicatorInsets))
    {
        [UIView animateWithDuration:0.25 animations:^
        {
            [self internalSetContentInset:insets];
            [self internalSetScrollIndicatorInsets:sInsets];
            //self.scrollIndicatorInsets = insets;
        }];
    }
}

@end



@implementation UIViewController(TableViewOffset)
@dynamic tableViewOffset;

- (void)setTableViewOffset:(CGPoint)tableViewOffset
{
    if ( [self respondsToSelector:@selector(tableView)] )
    {
        SWTableView *table = [self performSelector:@selector(tableView)];
        if ( [table isKindOfClass:[SWTableView class]] )
            table.tableViewOffset = tableViewOffset;
    }
}

- (CGPoint)tableViewOffset
{
    if ( [self respondsToSelector:@selector(tableView)] )
    {
        SWTableView *table = [self performSelector:@selector(tableView)];
        if ( [table isKindOfClass:[SWTableView class]] )
            return table.tableViewOffset;
    }
    return CGPointZero;
}


- (void)adjustKeyboardInsetsIfNeeded
{
    if ( [self respondsToSelector:@selector(tableView)] )
    {
        SWTableView *table = [self performSelector:@selector(tableView)];
        if ( [table isKindOfClass:[SWTableView class]] )
            [table adjustKeyboardInsetsIfNeeded];
    }
}


- (NSArray*)visibleViewControllers
{
    if ( [self respondsToSelector:@selector(visibleViewController)] )
    {
        UIViewController *controller = [self performSelector:@selector(visibleViewController)];
        return @[controller];
    }
    
    if ( self.isViewLoaded )
        return @[self];
    
    return nil;
}

@end

