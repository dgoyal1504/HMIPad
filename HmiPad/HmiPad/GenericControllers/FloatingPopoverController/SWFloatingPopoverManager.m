//
//  SWFloatingPopoverManager.m
//  HmiPad
//
//  Created by Joan Martin on 8/6/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWFloatingPopoverManager.h"
//#import "SWKeyboardListener.h"
#import "SWTableView.h"
#import "SWColor.h"

typedef enum
{
    FPNodeStateUnknown = 0,
    FPNodeStateVisible,
    FPNodeStateHidden,
    FPNodeStateClosed,
} FloatingPopoverNodeState;



@interface _SWFloatingPopoverNode : NSObject
{
    @public
    id _key;
    //__weak id _parentKey;
    FloatingPopoverNodeState _state;
    CGPoint _position;  // la posicio (centre) del popover en el contenidor
    CGPoint _offset;    // el offset del contingut, sp si es un tableView
    //NSInteger _order;      // valor per gestionar la profunditat de visualitzacio en el contenidor
}

- (id)initWithKey:(id)key position:(CGPoint)position offset:(CGPoint)offset;
@property (nonatomic, strong) SWFloatingPopoverController *fpc;

@end

@implementation _SWFloatingPopoverNode
@synthesize fpc = _fpc;

- (id)initWithKey:(id)key position:(CGPoint)position offset:(CGPoint)offset
{
    self = [super init];
    if (self)
    {
        _fpc = nil;
        _key = key;
//        _parentKey = nil;
        _position = position;
        _offset = offset;
        _state = FPNodeStateUnknown;
    }
    return self;
}

- (id)initWithKey:(id)key
{
    return [self initWithKey:key position:CGPointZero offset:CGPointZero];
}

- (BOOL)isEqual:(id)object
{
    // ens poden comparar amb qualsevol altre, no podem assumir que object->_key funcionara
    if ( ![object isKindOfClass:[self class]] )
        return NO;
    
    return [_key isEqual:((_SWFloatingPopoverNode*)object)->_key];
}

- (NSUInteger)hash
{
    return [_key hash];
}

@end
 




@implementation SWFloatingPopoverManager
{
    __weak UIViewController *_presentingController;   // weak !!
    NSMutableArray *_nodes;
}

- (id)initWithPresentingController:(UIViewController *)presentingController
{
    self = [super init];
    if (self)
    {
        _presentingController = presentingController;
        _nodes = [NSMutableArray array];
        _showsInFullScreen = NO;
    }
    return self;
}


- (void)dealloc
{
    //NSLog( @"SWFloatingPopoverManager dealloc" );
}

- (void)_presentFloatingPopoverWithNode:(_SWFloatingPopoverNode*)node animationKind:(SWFloatingPopoverAnimationKind)animationKind
{
    if ( node == nil )
        return;

    id key = node->_key;
    
    UIViewController *vc = nil;
    if ( [_dataSource respondsToSelector:@selector(floatingPopoverManager:viewControllerForKey:)] )
        vc = [_dataSource floatingPopoverManager:self viewControllerForKey:key];
    
    if ( vc == nil )
        return;
    
    //[self _prepareViewController:vc forContentOffset:node->_offset];
    [self _prepareViewController:vc forNode:node];

    SWFloatingPopoverController *fpc = [[SWFloatingPopoverController alloc] initWithContentViewController:vc
        withKey:key forPresentingInController:_presentingController];
    
//    UIColor *color = DarkenedUIColorWithRgb(SystemDarkerBlueColor,1.2f);
//    fpc.tintColor = color;
    
    fpc.showsInFullScreen = _showsInFullScreen;
    fpc.showsCloseButton = YES;
    fpc.delegate = self;
    
    node->_state = FPNodeStateVisible;
    node.fpc = fpc;
    
    id parentKey = [self _getParentKeyForKey:key];
    
   
//    if ([_dataSource floatingPopoverManager:self needsCenterForKey:key])
//    {
//        const CGPoint center = [_dataSource floatingPopoverManager:self centerForKey:key];
//        [fpc presentFloatingPopoverWithFixedCenter:center withAnimation:animationKind];
//    }
    
    CGRect rect = CGRectNull;
    if ( [_dataSource respondsToSelector:@selector(floatingPopoverManager:centerRectForKey:)] )
        rect = [_dataSource floatingPopoverManager:self centerRectForKey:key];
    
    if ( ! CGRectIsNull(rect) )
    {
        CGPoint center = CGPointMake(rect.origin.x + (rect.size.width/2), rect.origin.y + (rect.size.height/2));
        
        // presenta en el lloc determinat per el punt
        [fpc presentFloatingPopoverAtFixedPoint:center withAnimation:animationKind];
    }
    else if ( parentKey /*node->_parentKey*/ )
    {
        // presenta depenent del revealRect
        [fpc presentChildFloatingPopoverAtPoint:node->_position withAnimation:animationKind];
    }
    else
    {
        // presenta en un lloc que no tapi els nodes de sota
        [fpc presentFloatingPopoverAtPoint:node->_position withAnimation:animationKind];
    }
}

- (void)_dismissFloatingPopoverWithNode:(_SWFloatingPopoverNode*)node animationKind:(SWFloatingPopoverAnimationKind)animationKind;
{
    SWFloatingPopoverController *fpc = node.fpc;
    [fpc dismissFloatingPopoverWithAnimation:animationKind];
}


//- (void)presentFloatingPopoverWithKeyV:(id)key forParentWithKey:(id)parentKey animationKind:(SWFloatingPopoverAnimationKind)animationKind
//{
//
//    if ( parentKey != nil )  // si parentKey no es nil hi ha d'haver un pare
//    {
//        _SWFloatingPopoverNode *parentNode = [self _nodeForKey:parentKey];
//        if ( parentNode == nil )
//            return;
//    }
//    
//   _SWFloatingPopoverNode *node = [self _nodeForKey:key];
//    if ( node == nil )
//    {
//        [self _purgeOldNodes];
//    
//        node = [[_SWFloatingPopoverNode alloc] initWithKey:key];
//    
//        _SWFloatingPopoverNode *topNode = [_nodes lastObject];
//        if ( topNode )
//        {
//            CGPoint point = topNode->_position;
//            
//            node->_position.x = point.x + 60;
//            node->_position.y = point.y + 60;
//            BOOL again = YES;
//            
//            while ( again )
//            {
//                again = NO ;
//                for ( _SWFloatingPopoverNode *otherNode in _nodes )
//                {
//                    if ( node != otherNode && CGPointEqualToPoint(otherNode->_position, node->_position) )
//                    {
//                        node->_position.x += 60;
//                        node->_position.y += 60;
//                        again = YES;
//                        break;
//                    }
//                }
//            }
//        }
//        else
//        {
//            CGRect presentingBounds = _presentingController.view.bounds;
//            node->_position.x = presentingBounds.size.width/2.0f;
//            node->_position.y = presentingBounds.size.height/2.0f;
//        }
//        
//        [_nodes addObject:node];
//    }
//    
//    if ( node->_state != FPNodeStateVisible )
//    {
//        if ( parentKey ) node->_parentKey = parentKey;  // nomes canviem parentKey si es no nil
//        node->_key = key;   // tornem a posar la key perque pot haver canviat pero encara ser igual des del punt de vista del isEqual
////        node->_order = _orderCount;
////        _orderCount += 1;
//        
//        [self _moveNodeToFront:node];
//        [self _presentFloatingPopoverWithNode:node animationKind:animationKind];
//    }
//    else
//    {
//        [node.fpc bringToFront];
//    }
//}


- (void)_presentFloatingPopoverWithKey:(id)key animationKind:(SWFloatingPopoverAnimationKind)animationKind
{
   _SWFloatingPopoverNode *node = [self _nodeForKey:key];
    if ( node == nil )
    {
        [self _purgeOldNodes];
    
        node = [[_SWFloatingPopoverNode alloc] initWithKey:key];
    
        _SWFloatingPopoverNode *topNode = [_nodes lastObject];
        if ( topNode )
        {
            CGPoint point = topNode->_position;
            
            node->_position.x = point.x + 60;
            node->_position.y = point.y + 60;
            BOOL again = YES;
            
            while ( again )
            {
                again = NO ;
                for ( _SWFloatingPopoverNode *otherNode in _nodes )
                {
                    if ( node != otherNode && CGPointEqualToPoint(otherNode->_position, node->_position) )
                    {
                        node->_position.x += 60;
                        node->_position.y += 60;
                        again = YES;
                        break;
                    }
                }
            }
        }
        else
        {
            CGRect presentingBounds = _presentingController.view.bounds;
            node->_position.x = presentingBounds.size.width/2.0f;
            node->_position.y = presentingBounds.size.height/2.0f;
        }
        
        [_nodes addObject:node];
    }
    
    if ( node->_state != FPNodeStateVisible )
    {
        node->_key = key;   // tornem a posar la key perque pot haver canviat pero encara ser igual des del punt de vista del isEqual
//        node->_order = _orderCount;
//        _orderCount += 1;
        
        [self _moveNodeToFront:node];
        [self _presentFloatingPopoverWithNode:node animationKind:animationKind];
    }
    else
    {
        [node.fpc bringToFront];
    }
}


- (id)_getParentKeyForKey:(id)key
{
    id parentKey = nil;
    
    if ( [_dataSource respondsToSelector:@selector(floatingPopoverManager:parentKeyForViewControllerWithKey:)] )
        parentKey = [_dataSource floatingPopoverManager:self parentKeyForViewControllerWithKey:key];

    return parentKey;
}


//- (void)setParentKey:(id)parentKey toFloatingPopoverWithKey:(id)key
//{
//    // hi ha d'haver un pare
//    _SWFloatingPopoverNode *parentNode = [self _nodeForKey:parentKey];
//    if ( parentNode == nil )
//        return;
//    
//    _SWFloatingPopoverNode *node = [self _nodeForKey:key];
//    if ( node != nil )
//        node->_parentKey = parentKey;
//}


- (void)presentFloatingPopoverWithKey:(id)key animationKind:(SWFloatingPopoverAnimationKind)animationKind
{
    //[self presentFloatingPopoverWithKey:key forParentWithKey:nil animationKind:animationKind];
    [self _presentFloatingPopoverWithKey:key animationKind:animationKind];
}


- (void)dismissFloatingPopoverWithKey:(id)key animationKind:(SWFloatingPopoverAnimationKind)animationKind
{
    _SWFloatingPopoverNode *node = [self _nodeForKey:key];
    [self _dismissFloatingPopoverWithNode:node animationKind:animationKind];
}


- (void)removeAllPopoversAnimationKind:(SWFloatingPopoverAnimationKind)animationKind
{    
    for ( _SWFloatingPopoverNode *node in _nodes )   // cucut
    {
        if ( node->_state == FPNodeStateVisible )
            [self _dismissFloatingPopoverWithNode:node animationKind:(SWFloatingPopoverAnimationKind)animationKind];
    }
    [_nodes removeAllObjects];
}


- (void)removeFloatingPopoverWithKey:(id)key animationKind:(SWFloatingPopoverAnimationKind)animationKind
{
    _SWFloatingPopoverNode *node = [self _nodeForKey:key];
    if ( node  )
    {
        if ( node->_state == FPNodeStateVisible )
            [self _dismissFloatingPopoverWithNode:node animationKind:animationKind];

        [_nodes removeObject:node];
    }
}


- (SWFloatingPopoverController*)floatingPopoverControllerWithKey:(id)key
{
    _SWFloatingPopoverNode *node = [self _nodeForKey:key];
    return node.fpc; // tornara nil si no esta visible
}


//- (void)hidePresentedPopoversAnimationKindVV:(SWFloatingPopoverAnimationKind)animationKind
//{
//    // primer els posem tots a hidden
//    for ( _SWFloatingPopoverNode *node in _nodes )
//    {
//        if ( node->_state == FPNodeStateVisible )
//            node->_state = FPNodeStateHidden;
//    }
//    
//    NSMutableArray *deleteNodes = nil;
//    
//    // despres els dismisem
//    for ( _SWFloatingPopoverNode *node in _nodes )
//    {
//        if ( node->_state == FPNodeStateHidden )
//        {
//            [self _dismissFloatingPopoverWithNode:node animationKind:animationKind];
//            
//            if ( node->_parentKey != nil )  // els que tenen un pare els eliminem
//            {
//                if ( deleteNodes == nil ) deleteNodes = [NSMutableArray array];
//                [deleteNodes addObject:node];
//            }
//        }
//    }
//    
//    // ara els eliminem
//    for ( _SWFloatingPopoverNode *node in deleteNodes )
//    {
//        [_nodes removeObject:node];
//    }
//}



- (void)hidePresentedPopoversAnimationKind:(SWFloatingPopoverAnimationKind)animationKind
{
    // primer els posem tots a hidden
    for ( _SWFloatingPopoverNode *node in _nodes )
    {
        if ( node->_state == FPNodeStateVisible )
            node->_state = FPNodeStateHidden;
    }
    
    // despres els dismisem
    //NSMutableIndexSet *indexSet = nil;
    NSInteger count = _nodes.count;
    for ( NSInteger i=0; i<count; i++ )
    {
        _SWFloatingPopoverNode *node = [_nodes objectAtIndex:i];
        if ( node->_state == FPNodeStateHidden )
        {
            [self _dismissFloatingPopoverWithNode:node animationKind:animationKind];
            
//            if ( node->_parentKey != nil )  // els que tenen un pare els eliminarem
//            {
//                if ( indexSet == nil ) indexSet = [NSMutableIndexSet indexSet];
//                [indexSet addIndex:i];
//            }
        }
    }
    
    // ara els eliminem
//    if ( indexSet )
//        [_nodes removeObjectsAtIndexes:indexSet];
}






//- (void)presentHiddenPopoversAnimationKind:(SWFloatingPopoverAnimationKind)animationKind
//{
//    NSMutableArray *hiddenNodes = nil;
//    for ( _SWFloatingPopoverNode *node in _nodes )
//    {
//        if ( node->_state == FPNodeStateHidden )
//        {
//            if ( hiddenNodes == nil ) hiddenNodes = [NSMutableArray array];
//            [hiddenNodes addObject:node];
//        }
//    }
//    
//    [hiddenNodes sortUsingComparator:^NSComparisonResult(_SWFloatingPopoverNode* node1, _SWFloatingPopoverNode* node2)
//    {
//        NSInteger dif = node1->_order - node2->_order;
//        if ( dif < 0 ) return NSOrderedAscending;
//        if ( dif > 0 ) return NSOrderedDescending;
//        return NSOrderedSame;
//    }];
//    
//    for ( _SWFloatingPopoverNode *node in hiddenNodes )
//    {
//        [self _presentFloatingPopoverWithNode:node animationKind:animationKind];
//    }
//}



- (void)presentHiddenPopoversAnimationKind:(SWFloatingPopoverAnimationKind)animationKind
{
    for ( _SWFloatingPopoverNode *node in _nodes )
    {
        if ( node->_state == FPNodeStateHidden )
        {
            [self _presentFloatingPopoverWithNode:node animationKind:animationKind];
        }
    }

}


#pragma mark Protocol SWFloatingPopoverControllerDelegate


- (void)floatingPopoverControllerWillPresentPopover:(SWFloatingPopoverController *)fpc
{
    if ( [_delegate respondsToSelector:@selector(floatingPopoverManager:willPresentViewController:withKey:)] )
    {
        UIViewController *vc = fpc.contentViewController;
        [_delegate floatingPopoverManager:self willPresentViewController:vc withKey:fpc.key];
    }
}



//- (void)floatingPopoverControllerWillDismissPopover:(SWFloatingPopoverController *)fpc
//{
//    id key = fpc.key;
//    _SWFloatingPopoverNode *node = [self _nodeForKey:key];
//    
//    if ( node )
//    {
//        node.fpc = nil;
//        node->_position = fpc.presentationPosition;
//        node->_offset = [self _contentOffsetFromViewController:fpc.contentViewController];
//        if ( node->_state == FPNodeStateVisible ) node->_state = FPNodeStateClosed;
//    }
//    
//    // dismisem els fills que pugui tenir i l'eliminem com a pare dels seus fills
//    for ( _SWFloatingPopoverNode *child in _nodes)
//    {
//        if ( child->_parentKey == node->_key )
//        {
//            if ( child->_state == FPNodeStateVisible )
//                child->_parentKey = nil;
//            
//            [self _dismissFloatingPopoverWithNode:child animationKind:SWFloatingPopoverAnimationFade];
//        }
//    }
//    
//    if ( [_delegate respondsToSelector:@selector(floatingPopoverManager:willDismissViewController:withKey:)] )
//    {
//        UIViewController *vc = fpc.contentViewController;
//        [_delegate floatingPopoverManager:self willDismissViewController:vc withKey:key];
//    }
//}


- (void)floatingPopoverControllerWillDismissPopover:(SWFloatingPopoverController *)fpc
{
    id key = fpc.key;
    _SWFloatingPopoverNode *node = [self _nodeForKey:key];
    
    if ( node )
    {
        node.fpc = nil;
        node->_position = fpc.presentationPosition;
        node->_offset = [self _contentOffsetFromViewController:fpc.contentViewController];
        if ( node->_state == FPNodeStateVisible ) node->_state = FPNodeStateClosed;
    }
    
    // dismisem els fills que pugui tenir i l'eliminem com a pare dels seus fills
    for ( _SWFloatingPopoverNode *child in _nodes)
    {
        id parentKey = [self _getParentKeyForKey:child->_key];
        if ( parentKey == node->_key )
        {
            [self _dismissFloatingPopoverWithNode:child animationKind:SWFloatingPopoverAnimationFade];
        }
    }
    
    if ( [_delegate respondsToSelector:@selector(floatingPopoverManager:willDismissViewController:withKey:)] )
    {
        UIViewController *vc = fpc.contentViewController;
        [_delegate floatingPopoverManager:self willDismissViewController:vc withKey:key];
    }
}




- (void)floatingPopoverControllerDidDismissPopover:(SWFloatingPopoverController *)fpc
{
    id key = fpc.key;
    
    if ( [_delegate respondsToSelector:@selector(floatingPopoverManager:didDismissViewController:withKey:)] )
    {
        UIViewController *vc = fpc.contentViewController;
        [_delegate floatingPopoverManager:self didDismissViewController:vc withKey:key];
    }
}


//- (void)floatingPopoverControllerWillMoveToFrontV:(SWFloatingPopoverController *)fpc
//{
//    id key = fpc.key;
//    _SWFloatingPopoverNode *node = [self _nodeForKey:key];
//    
//    if ( node )
//    {
//        node->_order = _orderCount;
//        _orderCount += 1;
//    }
//}


- (void)floatingPopoverControllerDidMoveToFront:(SWFloatingPopoverController *)fpc
{
    id key = fpc.key;
    _SWFloatingPopoverNode *node = [self _nodeForKey:key];
    [self _moveNodeToFront:node];
}


- (void)floatingPopoverController:(SWFloatingPopoverController *)fpc didMoveToPoint:(CGPoint)point
{
    id key = fpc.key;
    _SWFloatingPopoverNode *node = [self _nodeForKey:key];
    node->_position = fpc.presentationPosition;
    
    UIViewController *contentController = fpc.contentViewController;
    NSArray *visibleViewControllers = [contentController visibleViewControllers];
    
    for ( UIViewController *controller in visibleViewControllers )
    {
        [controller adjustKeyboardInsetsIfNeeded];
    }
}


- (void)floatingPopoverControllerCloseButton:(SWFloatingPopoverController *)fpc
{
    id key = fpc.key;
    if ( [_delegate respondsToSelector:@selector(floatingPopoverManager:closeViewController:withKey:)] )
    {
        UIViewController *vc = fpc.contentViewController;
        [_delegate floatingPopoverManager:self closeViewController:vc withKey:key];
    }
}


- (CGRect)floatingPopoverControllerGetRevealRect:(SWFloatingPopoverController *)fpc
{
    CGRect revealRect = CGRectZero;
    
    UIView *revealView = nil;
    if ( [_dataSource respondsToSelector:@selector(floatingPopoverManager:revealViewForKey:)] )
        revealView = [_dataSource floatingPopoverManager:self revealViewForKey:fpc.key];
        
    if ( revealView )
    {
        UIView *presentingView = fpc.mainViewController.view;
        revealRect = [revealView convertRect:revealView.bounds toView:presentingView];
    }

    return revealRect;
}


#pragma mark Private

- (_SWFloatingPopoverNode*)_nodeForKey:(id)key
{
    _SWFloatingPopoverNode *node = nil;
    
    NSInteger count = _nodes.count;
    for ( NSInteger i = count-1 ; i>=0  ; i-- )
    {
        _SWFloatingPopoverNode *aNode = [_nodes objectAtIndex:i];
        if ( [aNode->_key isEqual:key] )
        {
            node = aNode;
            break;
        }
    }
    return node;
}



- (void)_moveNodeToFront:(_SWFloatingPopoverNode*)node
{
//    NSInteger index = NSNotFound;
//    
//    NSInteger count = _nodes.count;
//    for ( NSInteger i = count-1 ; i>=0  ; i-- )
//    {
//        _SWFloatingPopoverNode *aNode = [_nodes objectAtIndex:i];
//        if ( aNode == node )
//        {
//            index = i;
//            break;
//        }
//    }
    
    NSInteger index = [_nodes indexOfObjectIdenticalTo:node];

    if ( index != NSNotFound )
    {
        [_nodes removeObjectAtIndex:index];
        [_nodes addObject:node];
    }
}


//- (void)_moveNodeWithKeyToFront:(id)key
//{
//    NSInteger index = NSNotFound;
//    _SWFloatingPopoverNode *node = nil;
//    
//    NSInteger count = _nodes.count;
//    for ( NSInteger i = count-1 ; i>=0  ; i-- )
//    {
//        _SWFloatingPopoverNode *aNode = [_nodes objectAtIndex:i];
//        if ( [aNode->_key isEqual:key] )
//        {
//            index = i;
//            node = aNode;
//            break;
//        }
//    }
//
//    if ( node )
//    {
//        [_nodes removeObjectAtIndex:index];
//        [_nodes addObject:node];
//    }
//}


//- (void)_purgeOldNodes
//{
//    NSMutableArray *closedNodes = nil;
//    for ( _SWFloatingPopoverNode *node in _nodes )
//    {
//        if ( node->_state == FPNodeStateClosed )
//        {
//            if ( closedNodes == nil ) closedNodes = [NSMutableArray array];
//            [closedNodes addObject:node];
//        }
//    }
//    
//    NSInteger count = closedNodes.count;
//    if ( count > 10 )
//    {
//        [closedNodes sortUsingComparator:^NSComparisonResult(_SWFloatingPopoverNode* node1, _SWFloatingPopoverNode* node2)
//        {
//            NSInteger dif = node1->_order - node2->_order;
//            if ( dif < 0 ) return NSOrderedAscending;
//            if ( dif > 0 ) return NSOrderedDescending;
//            return NSOrderedSame;
//        }];
//
//        // eliminem els que tenen el ordre mes baix
//        for ( NSInteger i=0 ; i<count-10 ; i++ )
//        {
//            _SWFloatingPopoverNode *node = [closedNodes objectAtIndex:i];
//            [_nodes removeObject:node];
//        }
//    }
//}


- (void)_purgeOldNodes
{
    //NSInteger purgeCount = 0;
    NSInteger count = _nodes.count;
    const int ClosedCountMax = 10;
    
    if ( count < ClosedCountMax )  // <-- optimitzem el cas de pocs nodes doncs segur que no en volem eliminar cap!
        return;

    NSMutableIndexSet *indexSet = nil;
    for ( NSInteger i=0 ; i<count; i++ )
    {
        _SWFloatingPopoverNode *node = [_nodes objectAtIndex:i];
        if ( node->_state == FPNodeStateClosed )
        {
            if ( indexSet == nil ) indexSet = [NSMutableIndexSet indexSet];
            [indexSet addIndex:i];
            //purgeCount += 1;
        }
    }
    
    NSInteger closedCount = indexSet.count;
    __block NSInteger toRemoveCount = closedCount-ClosedCountMax;  // en volem deixar ClosedCountMax com a molt
    
    if ( toRemoveCount > 0 )
    {
        NSMutableIndexSet *toRemoveIndexes = [NSMutableIndexSet indexSet];
        [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop)
        {
            if ( toRemoveCount <= 0 )
                *stop = YES;
            else
                [toRemoveIndexes addIndex:idx];
            
            toRemoveCount -= 1;
        }];
        
        [_nodes removeObjectsAtIndexes:toRemoveIndexes];
    }
}



- (UIViewController *)_childTableViewControllerFromViewController:(UIViewController*)vc
{
    if ([vc respondsToSelector:@selector(topViewController)])
        vc = [vc performSelector:@selector(topViewController)];
    
    if ([vc respondsToSelector:@selector(tableView)])
        return vc;
    
    return nil;
}


//
//- (CGPoint)_contentOffsetFromViewControllerV:(UIViewController*)vc
//{
//    CGPoint offset = CGPointZero;
//    
//    UIViewController *tvc = [self _childTableViewControllerFromViewController:vc];
//    
//    UITableView *tableView = [(id)tvc tableView];
//    if ( tableView )
//    {
//        offset = tableView.contentOffset;
//    }
//    
//    return offset;
//}
//
//
//- (void)_prepareViewControllerV:(UIViewController*)vc forContentOffset:(CGPoint)offset
//{
//    UIViewController *tvc = [self _childTableViewControllerFromViewController:vc];
//    
//    UITableView *tableView = [(id)tvc tableView];
//    if ( tableView )
//    {
//        if (!tvc.isViewLoaded)  
//            (void)vc.view; // <-------- En cas de que la vista no estigui creada, obliguem a que es crei, ja que necessitem interactuar amb el seu tableView.
//        
//        [tableView setContentOffset:offset];
//    }
//}


- (CGPoint)_contentOffsetFromViewController:(UIViewController*)vc
{
    UIViewController *tvc = [self _childTableViewControllerFromViewController:vc];
    CGPoint offset = tvc.tableViewOffset;
    return offset;
}


//- (void)_prepareViewController:(UIViewController*)vc forContentOffset:(CGPoint)offset
//{
//    UIViewController *tvc = [self _childTableViewControllerFromViewController:vc];
//    tvc.tableViewOffset = offset;
//}

- (void)_prepareViewController:(UIViewController*)vc forNode:(_SWFloatingPopoverNode*)node
{
    UIViewController *tvc = [self _childTableViewControllerFromViewController:vc];
    if ( node->_state != FPNodeStateUnknown )
        tvc.tableViewOffset = node->_offset;
}


//- (CGPoint)_contentOffsetFromViewController:(UIViewController*)vc
//{
//    CGPoint offset;
//    
//    if ([vc isKindOfClass:[UINavigationController class]])
//        vc = [(UINavigationController*)vc topViewController];
//    
//    if ([vc respondsToSelector:@selector(tableView)])
//    {
//        UITableView *tableView = [(id)vc tableView];
//        offset = tableView.contentOffset;
//    }
//    
//    return offset;
//}
//
//
//- (void)_prepareViewController:(UIViewController*)vc forContentOffset:(CGPoint)offset
//{
//    if (!vc.isViewLoaded)
//        (void)vc.view; // <-------- En cas de que la vista no estigui creada, obliguem a que es crei, ja que necessitem interactuar amb el seu tableView.
//
//    if ([vc isKindOfClass:[UINavigationController class]])
//        vc = [(UINavigationController*)vc topViewController];
//    
//    if ([vc respondsToSelector:@selector(tableView)])
//    {
//        [[(id)vc tableView] setContentOffset:offset];
//        //NSLog( @"tableViewPVC\n:%@", [(id)vc tableView] );
//    }
//}

@end

