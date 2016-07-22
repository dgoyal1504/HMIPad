//
//  SWFlowController.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 2/8/12.
//  Copyright (c) 2012 SweetWilliam SL. All rights reserved.
//

/******************************************************************/
/******************************************************************/
/**                                                              **/
/** WARNING: THIS CLASS IS ABOUT TO BE DEPRECATED. DO NOT USE IT **/
/**                                                              **/
/******************************************************************/
/******************************************************************/

#import "SWFlowController.h"
#import "SWFlowView.h"


@interface SWFlowController (Private)

- (void)_presentFlowView;
- (void)_insertNewViewController;
- (void)_deleteCurrentViewController;
- (UIViewController*)_viewControllerAtIndex:(NSInteger)index;

@end

@implementation SWFlowController

@synthesize viewControllers = _viewControllers;
//@synthesize selected=_selected;

@synthesize delegate=_delegate;
@synthesize dataSource=_dataSource;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.viewControllers = [[NSMutableArray alloc] init];

        _numberOfViewControllers = -1;
        _selectedViewControllerIndex = -1;
        
        UIBarButtonItem *next = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward 
                                                                              target:self 
                                                                              action:@selector(moveToRightViewController:)];
        
        UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind
                                                                              target:self 
                                                                              action:@selector(moveToLeftViewController:)];
        
        _backItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply 
                                                                  target:self 
                                                                  action:@selector(_presentFlowView)];
        
        UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                              target:self 
                                                                              action:@selector(_insertNewViewController)];
        
        UIBarButtonItem *remove = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
                                                                             target:self 
                                                                             action:@selector(_deleteCurrentViewController)];
        
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:back,next,_backItem,add,remove, nil];
    }
    return self;
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

    _flowView = [[SWFlowView alloc] initWithFrame:self.view.bounds];
    [_flowView setDelegate:self];
    [_flowView setDataSource:self];
    
    _flowView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    [self.view addSubview:_flowView];
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

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

#pragma mark - Main Methods
- (IBAction)dismissCurrentViewController:(id)sender
{
    [_flowView dismissCurrentView:sender];
}

- (IBAction)moveToRightViewController:(id)sender
{    
    if (_selectedViewControllerIndex == -1)
        return;
    
    if (_selectedViewControllerIndex+1 >= _numberOfViewControllers) {
        return;
    }
    
 
    UIViewController *currentViewController = [self _viewControllerAtIndex:_selectedViewControllerIndex];
    UIViewController *rightViewController = [self _viewControllerAtIndex:_selectedViewControllerIndex+1];
 
    rightViewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    rightViewController.view.frame = self.view.bounds;
 
    [rightViewController removeFromParentViewController];

    [self addChildViewController:rightViewController];

    [self transitionFromViewController:currentViewController 
                      toViewController:rightViewController
                              duration:0.30 
                               options:UIViewAnimationOptionTransitionFlipFromRight 
                            animations:^{
                                
                            } 
                            completion:^(BOOL finished) {
                                _selectedViewControllerIndex = _selectedViewControllerIndex + 1;
                                [rightViewController didMoveToParentViewController:self];
                                [currentViewController removeFromParentViewController];
                            }];
}

- (IBAction)moveToLeftViewController:(id)sender
{    
    if (_selectedViewControllerIndex == -1)
        return;
    
    if (_selectedViewControllerIndex-1 < 0) {
        return;
    }
    
    UIViewController *currentViewController = [self _viewControllerAtIndex:_selectedViewControllerIndex];
    UIViewController *leftViewController = [self _viewControllerAtIndex:_selectedViewControllerIndex-1];
    
    leftViewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    leftViewController.view.frame = self.view.bounds;
    
    [leftViewController removeFromParentViewController];
    
    [self addChildViewController:leftViewController];
    
    [self transitionFromViewController:currentViewController 
                      toViewController:leftViewController
                              duration:0.30 
                               options:UIViewAnimationOptionTransitionFlipFromLeft 
                            animations:^{
                                
                            } 
                            completion:^(BOOL finished) {
                                _selectedViewControllerIndex = _selectedViewControllerIndex - 1;
                                [leftViewController didMoveToParentViewController:self];
                                [currentViewController removeFromParentViewController];
                            }];
}


- (void)insertControllersAtIndexes:(NSIndexSet*)indexes withAnimation:(SWFlowControllerAnimation)animation
{   
    _numberOfViewControllers = [self.dataSource numberOfControllersInFlowController:self];
    
    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [_viewControllers insertObject:[NSNull null] atIndex:idx];
    }];
    
    [_flowView insertViewsAtIndexes:indexes withViewAnimation:(SWFlowViewAnimation)animation];
}

- (void)deleteControllersAtIndexes:(NSIndexSet*)indexes withAnimation:(SWFlowControllerAnimation)animation
{    
    _numberOfViewControllers = [self.dataSource numberOfControllersInFlowController:self];
    [_flowView deleteViewsAtIndexes:indexes withViewAnimation:(SWFlowViewAnimation)animation];
}

#pragma mark - SWFlowViewDelegate

- (void)flowView:(SWFlowView *)flowView didPresentViewAtIndex:(NSInteger)index
{    
    _selectedViewControllerIndex = index;
    UIViewController *currentViewController = [self _viewControllerAtIndex:_selectedViewControllerIndex];
    
    [currentViewController.view removeFromSuperview];
    
    [_flowView sleep];
    
    [self.view addSubview:currentViewController.view];
}

- (void)flowView:(SWFlowView *)flowView willDismissViewAtIndex:(NSInteger)index
{        
    _selectedViewControllerIndex = -1;
}

- (void)flowView:(SWFlowView *)flowView willAppearViewAtIndex:(NSInteger)index
{
    UIViewController *controller = [self _viewControllerAtIndex:index];
    [self addChildViewController:controller];
    [controller didMoveToParentViewController:self];
}

- (void)flowView:(SWFlowView *)flowView didDisappearViewAtIndex:(NSInteger)index
{
    if (index != _selectedViewControllerIndex) {
        UIViewController *controller = [self _viewControllerAtIndex:index];
        [controller removeFromParentViewController];
    }
}


#pragma mark - SWFlowViewDataSource

// -- Configuring a Flow View -- //
- (NSInteger)numberOfViewsInFlowView:(SWFlowView*)flowView
{
    _numberOfViewControllers = [self.dataSource numberOfControllersInFlowController:self];
    return _numberOfViewControllers;
}

- (UIView*)flowView:(SWFlowView*)flowview contentForViewAtIndex:(NSInteger)index
{
    UIViewController *controller = [self _viewControllerAtIndex:index];
    return controller.view;
}

- (NSString*)flowView:(SWFlowView*)flowView titleForViewAtIndex:(NSInteger)index
{
    if ([_dataSource respondsToSelector:@selector(flowController:titleForViewAtIndex:)]) {
        return [_dataSource flowController:self titleForViewAtIndex:index];
    }
    
    return [NSString stringWithFormat:@"Title %d",index];
}

- (NSString*)flowView:(SWFlowView*)flowView subtitleForViewAtIndex:(NSInteger)index
{
    if ([_dataSource respondsToSelector:@selector(flowController:subtitleForViewAtIndex:)]) {
        return [_dataSource flowController:self subtitleForViewAtIndex:index];
    }
    
    return [NSString stringWithFormat:@"Subtitle %d",index];
}

// -- Inserting or Deleting Views -- //
- (BOOL)flowView:(SWFlowView*)flowView canEditViewAtIndex:(NSInteger)index
{
    // TODO
    return YES;
}

- (void)flowView:(SWFlowView*)flowView commitEditingStyle:(SWFlowViewItemEditingStyle)editingStyle forViewAtIndex:(NSInteger)index
{
    // TODO
}

// -- Reordering Views -- //
- (BOOL)flowView:(SWFlowView*)flowView canMoveViewAtIndex:(NSInteger)index
{
    // TODO
    return NO;
}

- (void)flowView:(SWFlowView*)flowView moveViewAtIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex
{
    // TODO
}

@end

@implementation SWFlowController (Private)

- (void)_presentFlowView
{
    if (_selectedViewControllerIndex == -1 || _selectedViewControllerIndex >= _numberOfViewControllers)
        return;
    
    [_flowView awakeAtIndex:_selectedViewControllerIndex inFullScreen:YES];
    
    [_flowView dismissCurrentView:nil];
}

- (void)_insertNewViewController
{
    BOOL canEdit = YES;
    
    NSInteger index = [_flowView indexForSelectedView];//_numberOfViewControllers;

    if (index == -1)
        index = 0;
    
    
    if ([_dataSource respondsToSelector:@selector(flowController:canEditControllerAtIndex:)]) {
        canEdit = [_dataSource flowController:self canEditControllerAtIndex:index];
    }
    
    if (!canEdit) return;
    
    if ([_dataSource respondsToSelector:@selector(flowController:commitEditingStyle:forControllerAtIndex:)]) {
        [_dataSource flowController:self commitEditingStyle:SWFlowControllerEditingStyleInsert forControllerAtIndex:index];
    }
}

- (void)_deleteCurrentViewController
{
    BOOL canEdit = YES;
    
    if ([_dataSource respondsToSelector:@selector(flowController:canEditControllerAtIndex:)]) {
        canEdit = [_dataSource flowController:self canEditControllerAtIndex:_numberOfViewControllers];
    }
    
    if (!canEdit) return;
    
    if ([_dataSource respondsToSelector:@selector(flowController:commitEditingStyle:forControllerAtIndex:)]) {
        [_dataSource flowController:self commitEditingStyle:SWFlowControllerEditingStyleDelete forControllerAtIndex:[_flowView indexForSelectedView]];
    }
}

- (UIViewController*)_viewControllerAtIndex:(NSInteger)index
{
    if (index >= _numberOfViewControllers)
        return nil;
    
    BOOL isNull = NO;
    
    if (index < _viewControllers.count) {
        UIViewController *vc = [_viewControllers objectAtIndex:index];
        if ((id)vc != [NSNull null]) {
            return vc;
        } else {
            isNull = YES;
        }
    }
    
    UIViewController *vc = [self.dataSource flowController:self controllerAtIndex:index];
    
    if (isNull) {
        [_viewControllers replaceObjectAtIndex:index withObject:vc];
        
    } else {
        if (index < _viewControllers.count) {
            NSLog(@"[WARNING] [2kffw2] Unstable application state");
            return nil;
            
        } else if (index == _viewControllers.count) {
            [_viewControllers addObject:vc];
            
        } else if (index > _viewControllers.count) {
            
            for (NSInteger i=0; i<index-_viewControllers.count; ++i) {       // ???? (no acava mai)
                [_viewControllers addObject:[NSNull null]];
            }
            
            [_viewControllers addObject:vc];
        }
    }
    
    return vc;
}

@end
