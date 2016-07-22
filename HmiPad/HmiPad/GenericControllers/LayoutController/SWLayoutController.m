//
//  SWLayoutController.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 2/2/12.
//  Copyright (c) 2012 SweetWilliam SL. All rights reserved.
//

/******************************************************************/
/******************************************************************/
/**                                                              **/
/** WARNING: THIS CLASS IS ABOUT TO BE DEPRECATED. DO NOT USE IT **/
/**                                                              **/
/******************************************************************/
/******************************************************************/

#import "SWLayoutController.h"
#import "SWLayoutView.h"
#import "SWLayoutItemView.h"
#import "SWLayoutedView.h"

NSString * const SWLayoutedControllerIncompatibilityException = @"SWLayoutedControllerIncompatibilityException";

@interface SWLayoutController (Private)

- (UIViewController*)_viewControllerAtIndex:(NSInteger)index;

@end

@implementation SWLayoutController

@dynamic editing;
@synthesize layoutView = _layoutView;

@synthesize delegate = _delegate;
@synthesize dataSource = _dataSource;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _indexMapping = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
    
    _layoutView = [[SWLayoutView alloc] initWithFrame:self.view.bounds];
    _layoutView.dataSource = self;
    _layoutView.delegate = self;
    _layoutView.editing = NO;
    
    [self.view addSubview:_layoutView];
    [self.view sendSubviewToBack:_layoutView];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ( [_dataSource numberOfControllersInLayoutController:self] > 0) {
        [self.layoutView reloadData];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (BOOL)automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers
{
    return YES;
}

#pragma mark - Properties

- (NSArray*)viewControllers
{
    return self.childViewControllers;
}

- (void)setEditing:(BOOL)editing
{
    _layoutView.editing = editing;
}

- (BOOL)isEditing
{
    return _layoutView.isEditing;
}

#pragma mark - Public Methods

- (void)insertViewControllerAtIndexes:(NSIndexSet*)indexes withAnimation:(SWLayoutItemAnimation)animation
{
    NSInteger currentSize = self.childViewControllers.count;
    NSInteger newSize = [_dataSource numberOfControllersInLayoutController:self];
    
    if (currentSize+indexes.count != newSize) {
        NSException *e = [NSException exceptionWithName:SWLayoutedControllerIncompatibilityException 
                                                 reason:@"Incompatible number of controllers before and after insertion" 
                                               userInfo:[NSDictionary dictionary]];
        [e raise];
    }
    
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    
    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        
        UIViewController *viewController = [_dataSource layoutController:self controllerAtIndex:idx];
        
        if (![viewController isKindOfClass:[UIViewController class]]) {
            NSException *e = [NSException exceptionWithName:SWLayoutedControllerIncompatibilityException 
                                                     reason:@"The object added to a SWLayoutController is not a UIViewController." 
                                                   userInfo:[NSDictionary dictionary]];
            [e raise];
        }
        
        [self addChildViewController:viewController];
        [viewController didMoveToParentViewController:self];
        
         NSUInteger index = [self.childViewControllers indexOfObject:viewController];
        [_indexMapping setObject:[NSNumber numberWithInteger:index] forKey:[NSNumber numberWithInteger:idx]];
        
        [indexSet addIndex:index];
    }];
    
    [self.layoutView insertPageItemsAtIndexes:indexes withPageItemAnimation:animation completion:0];
}

- (void)deleteViewControllerAtIndexes:(NSIndexSet*)indexes withAnimation:(SWLayoutItemAnimation)animation
{
    NSInteger currentSize = self.childViewControllers.count;
    NSInteger newSize = [_dataSource numberOfControllersInLayoutController:self];
    
    if (currentSize-indexes.count != newSize) {
        NSException *e = [NSException exceptionWithName:SWLayoutedControllerIncompatibilityException 
                                                 reason:@"Incompatible number of controllers before and after deletion" 
                                               userInfo:[NSDictionary dictionary]];
        [e raise];
    }
    
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    
    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        
        NSNumber *key = [NSNumber numberWithInteger:idx];
        
        NSUInteger controllerIndex = [[_indexMapping objectForKey:key] integerValue];
        
        [_indexMapping removeObjectForKey:key];
        
        [indexSet addIndex:controllerIndex];
    }];
    
    NSMutableArray  *vcs = [NSMutableArray array];
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [vcs addObject:[self.childViewControllers objectAtIndex:idx]];
    }];
    
    [vcs makeObjectsPerformSelector:@selector(removeFromParentViewController)];
    
    [self.layoutView deletePageItemsAtIndexes:indexes withPageItemAnimation:animation completion:0];
}

- (void)reloadData
{
    [self.layoutView reloadData];
}

@end

@implementation SWLayoutController (Private)

- (UIViewController*)_viewControllerAtIndex:(NSInteger)index
{
    if (index < self.childViewControllers.count) {
        return [self.childViewControllers objectAtIndex:index];
    }
    
    for (NSInteger i = self.childViewControllers.count; i <= index; ++i) {
        UIViewController *vc = [_dataSource layoutController:self controllerAtIndex:i];
        [self addChildViewController:vc];
        [vc didMoveToParentViewController:self];
    }
    
    return [self.childViewControllers objectAtIndex:index];
}

@end

@implementation SWLayoutController (layoutViewDataSource)

- (NSInteger)numberOfPagesForlayoutView:(SWLayoutView *)layoutView
{
    return [_dataSource numberOfControllersInLayoutController:self];
}

- (SWLayoutItemView*)layoutView:(SWLayoutView *)layoutView layoutViewAtIndex:(NSInteger)index
{
    UIViewController *viewController = [self _viewControllerAtIndex:index];
    
    if (![viewController isViewLoaded]) {
        //NSLog(@"1 VIEW IS NOT LOADED");
        //[viewController loadView];
    }
    
    SWLayoutItemView *layoutItemView = nil;
    
    if (!layoutItemView) {
        layoutItemView = [[SWLayoutItemView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    }
        
    layoutItemView.contentView = viewController.view;

    return layoutItemView;
}

- (CGRect)layoutView:(SWLayoutView*)layoutView frameForPageItemAtIndex:(NSInteger)index
{    
    CGRect frame = CGRectZero;
    
    UIViewController *vc = [self _viewControllerAtIndex:index];
    
    if ([vc conformsToProtocol:@protocol(SWLayoutedView)]) {
        frame.origin = [(id<SWLayoutedView>)vc position];
        frame.size = [(id<SWLayoutedView>)vc size];
    } else {
        if ([_delegate respondsToSelector:@selector(layoutController:positionForViewController:)]) {
            frame.origin = [_delegate layoutController:self positionForViewController:vc];
        }
        
        if ([_delegate respondsToSelector:@selector(layoutController:sizeForViewController:)]) {
            frame.size = [_delegate layoutController:self sizeForViewController:vc];
        }
    }
    
    return frame;
}

- (BOOL)layoutView:(SWLayoutView *)layoutView canDeletePageItemAtIndex:(NSInteger)index
{
    if ([_dataSource respondsToSelector:@selector(layoutController:canEditControllerAtIndex:)]) {
        return [_dataSource layoutController:self canEditControllerAtIndex:index];
    }
    
    return YES;
}

- (void)layoutView:(SWLayoutView *)layoutView commitDeletionForPageItemAtIndex:(NSInteger)index
{
    if ([_dataSource respondsToSelector:@selector(layoutController:commitEditingStyle:forControllerAtIndex:)]) {
        [_dataSource layoutController:self commitEditingStyle:SWLayoutControllerEditingStyleDelete forControllerAtIndex:index];
    }
}

@end

@implementation SWLayoutController (layoutViewDelegate) 

- (void)layoutView:(SWLayoutView *)layoutView didMovePageItemAtIndex:(NSInteger)index toPosition:(CGPoint)position
{
    //NSLog(@"Did Move %d To Position: %@", index, NSStringFromCGPoint(position));
    
    UIViewController *vc = [self _viewControllerAtIndex:index];
    
    if ([vc conformsToProtocol:@protocol(SWLayoutedView)]) {
        [(id<SWLayoutedView>)vc setPosition:position];
    } else {
        if ([_delegate respondsToSelector:@selector(layoutController:viewController:movedToPosition:)]) {
            [_delegate layoutController:self viewController:self movedToPosition:position];
        }
    }

}

- (void)layoutView:(SWLayoutView *)layoutView didResizePageItemAtIndex:(NSInteger)index toSize:(CGSize)size
{
   //NSLog(@"Did Resize %d To Size: %@", index, NSStringFromCGSize(size));
    
    UIViewController *vc = [self _viewControllerAtIndex:index];
    
    if ([vc conformsToProtocol:@protocol(SWLayoutedView)]) {
        [(id<SWLayoutedView>)vc setSize:size];
    } else {
        if ([_delegate respondsToSelector:@selector(layoutController:viewController:updatedToViewSize:)]) {
            [_delegate layoutController:self viewController:self updatedToViewSize:size];
        }
    }
}

- (void)layoutView:(SWLayoutView *)layoutView didDeletePageAtIndex:(NSInteger)index
{
        // do nothing
}

@end

