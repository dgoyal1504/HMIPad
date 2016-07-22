//
//  SWTableFieldsController.m
//  HmiPad
//
//  Created by Joan on 24/04/09.
//  Copyright 2009 SweetWilliam, S.L.. All rights reserved.
//

#import "SWTableFieldsController.h"
#import "SWTableFieldsControllerDelegate.h"
#import "BubbleView.h"
#import "SWTouchUpSegmentedControl.h"
#import "RoundedTextViewDelegate.h"

#import "Drawing.h"
#import "SWColor.h"


// comment out one of the two
#define NSLog1(...) {}
//#define NSLog1(args...) NSLog(args)

///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark IntegerPair
///////////////////////////////////////////////////////////////////////////////////////////


enum IndicatorMask
{
    IndicatorNone           = 0,
    IndicatorPending        = 1 << 1,
    IndicatorError          = 1 << 2,
};
typedef enum IndicatorMask IndicatorMask;

@interface SWCellWrapper()

-(id)initWithCell:(UITableViewCell*)aCell atIndexPath:(NSIndexPath*)path;

@end

//----------------------------------------------------------------------------------
@implementation SWCellWrapper


//----------------------------------------------------------------------------------
-(id)initWithCell:(UITableViewCell*)aCell atIndexPath:(NSIndexPath*)path
{
    if ( (self = [self init] ) )
    {
        cell = aCell;
        indexPath = path;
    }
    return self;
}

@end





///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark SWTableFieldsController
///////////////////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------------
@implementation SWTableFieldsController
{

}

//----------------------------------------------------------------------------------
@synthesize isStarted = _isStarted;
@synthesize owner = _owner;
@synthesize currentTextResponder = _currentTextResponder;
@synthesize currentResponderCell = _currentResponderCell;

//----------------------------------------------------------------------------------
- (id)initWithOwner:(id<SWTableFieldsControllerDelegate>)theOwner // navigationItem:(UINavigationItem*)theNavigationItem
{
    if ( (self = [self init]) )
    {
    	//navigationItem = theNavigationItem;
        _owner = theOwner;
        _isStarted = NO;
        _currentTextResponder = nil;
        _currentResponderCell = nil;
        _textResponders = [[NSMutableArray alloc] init];
        _textResponderErrors = [[NSMutableArray alloc] init];
        _textResponderTexts = [[NSMutableArray alloc] init];
    }
    return self;
}


//----------------------------------------------------------------------------------
- (NSArray*)textResponders
{
    return _textResponders;
}

//----------------------------------------------------------------------------------
- (NSArray*)cellWrappers
{
    return _cellWrappers;
}

//----------------------------------------------------------------------------------
- (void)startAnimated:(BOOL)animated
{
    if ( _isStarted ) return;
    _isStarted = YES;
    if ( [_owner respondsToSelector:@selector(tableFieldsControllerDidStart:)] )
    {
        [_owner tableFieldsControllerDidStart:self];
    }
    [self _provideMainControl:YES animated:animated];
}


//----------------------------------------------------------------------------------
- (void)stopWithCancel:(BOOL)shouldCancel animated:(BOOL)animated;
{

    if ( _isStarted == NO ) return;

    //[self _presentBubbleViewWithMessage:nil forView:nil];
    [self _dismissMessageViewAnimated:YES];
    
    //[_currentTextResponder resignFirstResponder];
    //_currentTextResponder = nil;
    //_currentResponderCell = nil;
    
    BOOL allValid = YES;
    
    if ( shouldCancel == NO )
    {
        // comprovem els errors si cal
        if ( [_owner respondsToSelector:@selector(tableFieldsController:validateField:forCell:atIndexPath:outErrorString:)] )
        {
            NSInteger index = 0;
            for ( id textResponder in _textResponders )
            {
                UITableViewCell *cell = [self _cellForView:textResponder];
                NSIndexPath *indexPath = [self _indexPathForCell:cell];
                NSString *errorString = @"";
                BOOL valid = [_owner tableFieldsController:self validateField:textResponder 
                                        forCell:cell atIndexPath:indexPath outErrorString:&errorString];
                if ( !valid )
                {
                    allValid = NO;
//#warning (aqui ja coneixem el index)
                    //NSInteger index = [_textResponders indexOfObjectIdenticalTo:textResponder];
                    [_textResponderErrors replaceObjectAtIndex:index withObject:errorString];
                    [self _setIndicator:IndicatorPending|IndicatorError forField:textResponder index:index animated:YES];
                }
                index++;
            }
        }
    }
    
    
    if ( allValid || shouldCancel )
    {
        //777[_currentTextResponder resignFirstResponder];
        
        if ( [_owner respondsToSelector:@selector(tableFieldsControllerWillStopWithCancel:)] )
            [_owner tableFieldsControllerWillStopWithCancel:shouldCancel];
        
        if ( [_currentTextResponder respondsToSelector:@selector(textView)] )
            [[_currentTextResponder performSelector:@selector(textView)] resignFirstResponder];
        else [_currentTextResponder resignFirstResponder];
        
        _currentTextResponder = nil;
        _currentResponderCell = nil;
    }
    
    if ( allValid )
    {
        // treiem els punts blaus si cal
        for ( id textResponder in _textResponders )
        {
            if ( [textResponder respondsToSelector:@selector(setHasBullet:)] ) [textResponder setHasBullet:NO];
            [self _setIndicator:IndicatorNone forField:textResponder index:0 animated:YES];
        }
    
        [self _provideMainControl:NO animated:animated];
    }
    else
    {
        // posar V disabled
    }
    
    if ( shouldCancel )
    {
        // tornem als valors inicials si cal
        int count = [_textResponders count];
        NSAssert( count == [_textResponderTexts count], @"textReponders i textResponderTexts no tenen la mateixa longitud!");
        for ( int i=0; i<count; i++ )
        {
            id text = [_textResponderTexts objectAtIndex:i];
            if ( text == [NSNull null] ) text = nil;
            [[_textResponders objectAtIndex:i] setText:text];
        }
        
        // informem el delegate
        _isStarted = NO;
        [_owner tableFieldsControllerCancel:self animated:animated];
    }
    else
    {
        if ( allValid == NO ) return;
        
        // informem que tot ha anat be
        _isStarted = NO;
        [_owner tableFieldsControllerApply:self animated:animated];
    }
    
    [_textResponders removeAllObjects];
    [_textResponderTexts removeAllObjects];
    [_textResponderErrors removeAllObjects];
    [_cellWrappers removeAllObjects];
}



//----------------------------------------------------------------------------------
- (void)recordTextResponder:(UIView*)textResponder
{
    //[self _presentBubbleViewWithMessage:nil forView:nil];
    if ( textResponder == nil )
        return;
    
    [self _dismissMessageViewAnimated:YES];
    [self _recordTextResponder:textResponder];
    
    UITableViewCell *cell = [self _cellForView:textResponder];
    UITableView *tableView = [self _tableViewForView:cell];
    NSIndexPath *indexPath = [tableView indexPathForCell:cell];
    if ( indexPath )
    {
        [self _recordTableViewCell:cell withIndexPath:indexPath];
    }
    
    if ( tableView )
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
        });
       // [self performSelector:@selector(delayedScroll:) withObject:cell afterDelay:1.0];
    }
    
}

//- (void)delayedScroll:(UITableViewCell*)cell
//{
//    UITableView *tableView = [self _tableViewForView:cell];
//    NSIndexPath *indexPath = [tableView indexPathForCell:cell];
//    [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
//} 

//----------------------------------------------------------------------------------
- (UITableViewCell*)dequeueRegisteredCellAtIndexPath:(NSIndexPath*)indexPath
{
    if ( _isStarted == NO || _cellWrappers == nil ) 
        return nil;
    
    for ( SWCellWrapper *pair in _cellWrappers )
    {
        if ( [pair->indexPath compare:indexPath] == NSOrderedSame )
        {
            // ens han passat un indexpath registrat, tornem la celda
            NSLog1 (@"SWTableFieldsController dismissProvidedCell:%x dequeueCell:%x AtIndexPath:%@", (unsigned int)cell, (unsigned int)pair->cell, indexPath);
            return pair->cell;
        }
    }
    
    return nil;
}

//----------------------------------------------------------------------------------
- (UITableViewCell*)amendedCellFromCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    if ( _isStarted == NO || _cellWrappers == nil ) return cell;

    for ( SWCellWrapper *pair in _cellWrappers )
    {
        if ( [pair->indexPath compare:indexPath] == NSOrderedSame )
        {
            // ens han passat un indexpath registrat, tornem la celda
            NSLog1 (@"SWTableFieldsController dismissProvidedCell:%x dequeueCell:%x AtIndexPath:%@", (unsigned int)cell, (unsigned int)pair->cell, indexPath);
            return pair->cell;
        }
    }
        
    if ( cell ) for ( SWCellWrapper *pair in _cellWrappers )
    {
        if ( pair->cell == cell )
        {
            // ens han passat una celda que ja estava registrada en un indexpath diferent, tornem nil
            NSLog1 (@"SWTableFieldsController dismissProvidedCell:%x AtIndexPath:%@", (unsigned int)cell, indexPath);
            return nil;
        }
    }

    NSLog1 (@"SWTableFieldsController useProvidedCell:%x AtIndexPath:%@", (unsigned int)cell, indexPath);
    return cell;
}

- (void)presentInfoMessage:(NSString*)msg fromView:(UIView*)view animated:(BOOL)animated
{
    [self _presentMessage:msg fromView:view animated:animated];
}

- (void)dismisInfoMessageAnimated:(BOOL)animated
{
    [self _dismissMessageViewAnimated:animated];
}

- (void)resetIndicatorForField:(id)field animated:(BOOL)animated
{
    [self _setIndicator:IndicatorPending forField:field index:0 animated:animated];
}


- (UITableViewCell*)cellForTextResponder:(UIView*)textResponder
{
    UITableViewCell *cell = [self _cellForView:textResponder];
    return cell;
}

// Torna el indexpath que es va registrar per textResponser
- (NSIndexPath*)indexPathforTextResponder:(UIView*)textResponder
{
    UITableViewCell *cell = [self _cellForView:textResponder];
    NSIndexPath *indexPath = [self _indexPathForCell:cell];
    return indexPath;
}

/*
//----------------------------------------------------------------------------------
- (UITableViewCell*)dequeueCellAtIndexPath:(NSIndexPath*)indexPath
{

    if ( isStarted == NO || cellWrappers == nil ) return nil;
    
    int section = [indexPath section];
    int row = [indexPath row];
    for ( SWCellWrapper *pair in cellWrappers )
    {
        if ( pair->section == section && pair->row == row )
        {
            return pair->cell;
        }
    }

    return nil;
}
*/

#pragma mark Metode delegat de BubbleView


//-----------------------------------------------------------------------------
- (void)bubbleViewTouched:(BubbleView*)sender
{
    //[self _presentBubbleViewWithMessage:nil forView:nil];
    [self _dismissMessageViewAnimated:YES];
}


#pragma mark Metodes privats

//----------------------------------------------------------------------------------
- (UITableViewCell *)_cellForView:(UIView *)aView
{
    Class cellClass = [UITableViewCell class];
    id view = aView;
    while ( ![view isKindOfClass:cellClass] && view != nil ) view = [view superview];
    return view;
}

//----------------------------------------------------------------------------------
- (UITableView *)_tableViewForView:(UIView *)aView
{
    Class cellClass = [UITableView class];
    id view = aView;
    while ( ![view isKindOfClass:cellClass] && view != nil ) view = [view superview];
    return view;
}

//----------------------------------------------------------------------------------
- (NSIndexPath *)_indexPathForCell:(UITableViewCell*)cell
{
    for ( SWCellWrapper *pair in _cellWrappers )
    {
        if ( pair->cell == cell ) 
        {
            return pair->indexPath;
        }
    }
    return nil;
}

//----------------------------------------------------------------------------------
- (UITableViewCell *)cellForIndexPath:(NSIndexPath*)indexPath
{
    for ( SWCellWrapper *pair in _cellWrappers )
    {
        if ( [pair->indexPath isEqual:indexPath] )
        {
            return pair->cell;
        }
    }
    return nil;
}

//----------------------------------------------------------------------------------
- (void)_recordTableViewCell:(UITableViewCell*)cell withIndexPath:(NSIndexPath*)indexPath 
{
    if ( _isStarted == NO ) return;
    
    _currentResponderCell = cell;
    if ( _cellWrappers == nil ) _cellWrappers = [[NSMutableArray alloc] init];
    for ( SWCellWrapper *pair in _cellWrappers )
    {        
        if ( [pair->indexPath compare:indexPath] == NSOrderedSame )
        {
            return;
        }
    }
    SWCellWrapper *pair = [[SWCellWrapper alloc] initWithCell:cell atIndexPath:indexPath];
    [_cellWrappers addObject:pair];
    
    NSLog1 (@"NavigationButtonController recordCell:%x AtIndexPath:%@", (unsigned int)cell, indexPath);
}

//----------------------------------------------------------------------------------
- (void)_recordTextResponder:(UIView*)textResponder
{
    if ( _isStarted == NO ) return;
    
    _currentTextResponder = textResponder;
    NSInteger index = [_textResponders indexOfObject:textResponder];
                    
    if ( index == NSNotFound )
    {
        [_textResponders addObject:textResponder];
        [_textResponderErrors addObject:@""];
        
        id text = nil;
        if ( [textResponder respondsToSelector:@selector(text)] ) text = [(id)textResponder text];
        if (text == nil) text = [NSNull null];
        [_textResponderTexts addObject:text];
        
        if ( [textResponder respondsToSelector:@selector(setRightViewMode:)] )
        {
            [(id)textResponder setRightViewMode:UITextFieldViewModeAlways];
        }
        
        if ( [textResponder respondsToSelector:@selector(setLeftViewMode:)] )
        {
            [(id)textResponder setLeftViewMode:UITextFieldViewModeAlways];
        }
        
        if ( [textResponder respondsToSelector:@selector(setHasBullet:)] )
        {
            [(id)textResponder setHasBullet:YES];
        }
    }
    else
    {
        [_textResponderErrors replaceObjectAtIndex:index withObject:@""];
    }
    
    [self _setIndicator:IndicatorPending forField:textResponder index:0 animated:YES];
    
     // iterar per tots i si hi ha al menys un butto posar V disabled
     // en cas contrari posar V enabled
}


//----------------------------------------------------------------------------------
- (void)_doRightButtonAction:(UISegmentedControl*)segment
{
    BOOL shouldCancel = ([segment selectedSegmentIndex] == 0);
    [self stopWithCancel:shouldCancel animated:YES];
}




//----------------------------------------------------------------------------------
- (void)_setIndicator:(IndicatorMask)type forField:(id)field index:(NSInteger)index animated:(BOOL)animated
{

    NSTextAlignment alignement = NSTextAlignmentRight;
    if ( [field respondsToSelector:@selector(textAlignment)] )
    {
        alignement = [field textAlignment];
    }

    BOOL atRight = (alignement == NSTextAlignmentRight);
    atRight = YES;  // < -- sempre a la dreta
    
    if ( atRight && ![field respondsToSelector:@selector(setRightView:)] )
    {
        return;
    }
    
    if ( atRight == NO && ![field respondsToSelector:@selector(setLeftView:)] )
    {
        return;
    }
    
    IndicatorMask currentIndicator;
    if ( atRight ) currentIndicator = ((int)[[field rightView] tag])>>28;
    else currentIndicator = ((int)[[field leftView] tag])>>28;
    
    if ( currentIndicator == type )
        return;
    
    UIImageView *imageView = nil;
    if ( type & IndicatorPending )
    {
        static UIImage *pendingImg = nil;
        //UIImage *pendingImg = [UIImage imageNamed:@"unreadIndicator10.png"];
        if ( pendingImg == nil )
        {
            const int side = 12;
            pendingImg = glossyImageWithSizeAndColor(CGSizeMake(side, side), UIColorWithRgb(TangerineSelectionColor).CGColor, NO, NO, side/2, 1);
        }
        imageView = [[UIImageView alloc] initWithImage:pendingImg];
        [imageView setContentMode:UIViewContentModeCenter];
        [imageView setFrame:CGRectMake(0,0,22,22)];
        [imageView setTag:type<<28];
    }
    
    if ( atRight ) [field setRightView:imageView];
    else [field setLeftView:imageView];
    
    UIButton *button = nil;
    if ( type & IndicatorError )
    {
    
        if ( IS_IOS7 )
        {
            button = [UIButton buttonWithType:UIButtonTypeInfoDark];
            button.tintColor = [UIColor redColor];
        }
        else
        {
            button = [UIButton buttonWithType:UIButtonTypeCustom];
            UIImage *image = nil;
            if ( atRight || YES ) image = [UIImage imageNamed:@"wrongfield.png"];
            else image = [UIImage imageNamed:@"wrongfieldPointRight.png"];
            [button setImage:image forState:UIControlStateNormal];
        }
    
        [button setFrame:CGRectMake(0, 0, 22, 22)];
        [button setAdjustsImageWhenHighlighted:YES];
        [button addTarget:self action:@selector(_accessoryInfoButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if ( ! (button == nil && (type&IndicatorPending) && atRight) )
    {
        [button setTag:(type<<28)|index];
        [field setRightView:button];
    }

}


//----------------------------------------------------------------------------------
- (void)_provideMainControl:(BOOL)provide animated:(BOOL)animated;
{
    if ( ! [_owner respondsToSelector:@selector(tableFieldsController:didProvideControl:animated:)] )
    {
    	return;
    }
        
    UIControl *control = nil;
    if ( provide )
    {
        if ( _backupControl == nil )
        {
            // crea un segmented control amb imatges
            UIImage *stopImg = [UIImage imageNamed:@"xWhiteShadow.png"];
            UIImage *checkMarkImg = [UIImage imageNamed:@"checkWhiteShadow.png"];   //white
            
            NSArray *objects = [[NSArray alloc] initWithObjects:stopImg, checkMarkImg, nil];
            
            UISegmentedControl *segmented = [[SWTouchUpSegmentedControl alloc] initWithItems:objects];
            
            //[segmented setSegmentedControlStyle:UISegmentedControlStyleBar];
            //[segmented setSelectedSegmentIndex:0];
            
            [segmented setMomentary:NO];
            [segmented addTarget:self action:@selector(_doRightButtonAction:) forControlEvents:UIControlEventValueChanged];
                
            // s'ha de ajustar el frame per evitar que vingui de lluny la primera vegada que apareix si es vol suavitzar el titol 
            CGRect rect = [segmented bounds];
            [segmented setFrame:CGRectMake(0,0,roundf(rect.size.width*1.34f), rect.size.height)];
                
            _backupControl = segmented;
        }
        control = _backupControl;
    }
    
    [_owner tableFieldsController:self didProvideControl:control animated:animated];
}


- (UIView*)_presentingViewForBubbleFromView:(UIView*)view
{
    UIView *presentingView = nil;
    if ( [_owner respondsToSelector:@selector(tableFieldsControllerBubblePresentingView:)])
        presentingView = [_owner tableFieldsControllerBubblePresentingView:self];
    
    if ( presentingView == nil )
        presentingView = [self _tableViewForView:view];
    
    if ( presentingView == nil )
        presentingView = [view superview];
    
    return presentingView;
}


- (void)_presentMessage:(NSString*)msg fromView:(UIView*)view animated:(BOOL)animated
{
    // ignora missatges enviats a la mateixa celda o nil
    if ( bubbleViewView == view ) return;
    if ( view == nil ) return;
  
    [self _dismissMessageViewAnimated:YES];
    
    UIView *presentingView = [self _presentingViewForBubbleFromView:view];
    if ( presentingView ) 
    {
        bubbleView = [[BubbleView alloc] initWithPresentingView:presentingView];
        [bubbleView setDelegate:self];
        [bubbleView presentFromView:view vGap:12.0f message:msg animated:YES];
    }
    
    bubbleViewView = view;
}


- (void)_dismissMessageViewAnimated:(BOOL)animated
{
    if ( bubbleView )
    {
        [bubbleView dismissAnimated:YES];
        bubbleView = nil;
    }
    
    bubbleViewView = nil;
}


//-------------------------------------------------------------------------------
- (void)_accessoryInfoButtonTouched:(UIControl *)sender
{
    NSInteger index = [sender tag]&0x0fffffff;
    //UIView *field = [_textResponders objectAtIndex:index];
    NSString *errText = [_textResponderErrors objectAtIndex:index];
    
    //NSLog( @"Ha tocat el boto de %@",  errText);
    //[self _presentBubbleViewWithMessage:errText forView:sender];
    [self _presentMessage:errText fromView:sender animated:YES];
}

@end







