//
//  SWPageNavigatorCell.m
//  HmiPad
//
//  Created by Joan Martin on 1/16/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//


#import <dispatch/dispatch.h>
#import <QuartzCore/QuartzCore.h>

#import "SWPageNavigatorCell.h"
#import "SWCustomHighlightedButton.h"

#import "SWPage.h"
#import "SWDocumentModel.h"
#import "SWModelManager.h"
#import "SWExpressionInputController.h"

#import "SWExpression.h"
#import "SWEnumTypes.h"

#import "SWPageController.h"
#import "SWImageManager.h"
#import "SWPasteboardTypes.h"

#import "SWColor.h"
#import "Drawing.h"

//#import "CALayer+ScreenShot.h"  // treure

NSString * const SWPageNavigatorCellIdentifier = @"SWPageNavigatorCellIdentifier";
NSString * const SWPageNavigatorCellNibName = @"SWPageNavigatorCell";
NSString * const SWPageNavigatorCellNibName_Phone = @"SWPageNavigatorCell_Phone";


@interface SWPageNavigatorCell()<SWObjectObserver,ExpressionObserver>
{
   // UILongPressGestureRecognizer *_longPressureRecognizer;
}

@end


@implementation SWPageNavigatorCell
{
    BOOL _isObserving;
    BOOL _isSelected;
    UITapGestureRecognizer *_tapRecognizer;
    dispatch_source_t _unhTimer;
}


+ (CGFloat)preferredHeight
{
    return IS_IPHONE?68.0f:90.0f;
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self _setupView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        //[self _setupView];
    }
    return self;
}


- (void)awakeFromNib
{
    [self _setupView];
    
    CALayer *layer = _previewImageButton.layer;
//    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:view.bounds];
//    layer.shadowPath = shadowPath.CGPath;
//    layer.shadowOffset = CGSizeMake(0, 1);
//    layer.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5].CGColor;
//    layer.shadowRadius = 2.5f ;
//    layer.shadowOpacity = 1;
    
    layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.8].CGColor;
    layer.borderColor = [UIColor colorWithWhite:0.0 alpha:0.8].CGColor;
    layer.borderWidth = 1;
    layer.cornerRadius = 4;
}


- (void)_setupView
{
    //self.darkContext = YES;

    _previewImageButton.contentMode = UIViewContentModeCenter;
    //_previewImageButton.imageView.contentMode = UIViewContentModeCenter;
    _previewImageButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    _previewImageButton.backgroundColor = [UIColor clearColor];
    _previewImageButton.userInteractionEnabled = NO;

     
    CGFloat side = 20;
    //UIColor *color = [UIColor colorWithRed:0.8 green:0.8 blue:1.0 alpha:0.8];
    //UIColor *color = [UIColor colorWithRed:.6f green:.6f blue:.6f alpha:0.2f];
    //UIColor *color = [UIColor colorWithRed:0.3f green:0.3f blue:0.3f alpha:0.5f];
    UIColor *color = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.3f];
    //UIColor *color = UIColorWithRgb(MultipleSelectionColor);
    //UIImage *image = glossyImageWithSizeAndColor(CGSizeMake(side, side), [color CGColor], NO, NO, 0, 3);
    UIImage *image = glossyImageWithSizeAndColor(CGSizeMake(side, side), [color CGColor], NO, NO, 0, 1);
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [self setSelectedBackgroundView:imageView];
    
    //self.selectionStyle = UITableViewCellSelectionStyleNone;
    

//    if ( _tapRecognizer == nil )
//    {
//        _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_gestureRecognized:)];
//        _tapRecognizer.cancelsTouchesInView = NO;
//        _tapRecognizer.delegate = self;
//        //_longPressureRecognizer.cancelsTouchesInView = NO; // <--- permetem el behaviour normal dels touch events a fora dels recognizers
//        //_longPressureRecognizer.delaysTouchesBegan = YES;
//        [self addGestureRecognizer:_tapRecognizer];
//    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    _isSelected = selected;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
}


- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
    if (newSuperview == nil)  // woraround al radar 12307048 (https://bugreport.apple.com/cgi-bin/WebObjects/RadarWeb.woa)
    {
        [self endObservingModel];
    }
}


- (void)_updateTitle
{
    SWValue *value = _page.shortTitle;
    [_titleLabel setText:value.valueAsString];
}

- (void)_updateModalStyle
{
    SWValue *value = _page.modalStyle;
    SWModalStyle modalStyle = value.valueAsInteger;
    [_modalLabel setText:modalStyle==SWModalStyleModal?@"M":nil];
}

- (void)_updatePageHidden
{
    SWValue *value = _page.hidden;
    BOOL hidden = value.valueAsBool;
    [_previewImageButton setAlpha:hidden?1.0:1.0];
    [_hiddenLabel setText:hidden?@"H":nil];
}

- (void)_updateImage
{

    [[SWImageManager defaultManager] getThumbnailImageWithUuid:_page.uuid
    completionBlock:^(UIImage *image)
    {
        [self _setImage:image];
    }];
}


- (void)_setImage:(UIImage*)image
{
    [_previewImageButton setImage:image forState:UIControlStateNormal];
}






#pragma mark Public Methods

- (void)setPage:(SWPage *)page
{
    _page = page;
    [self _updateModalStyle];
    [self _updatePageHidden];
    [self _updateTitle];
    [self _updateImage];
}


- (void)beginObservingModel
{
    if ( !_isObserving )
    {
        _isObserving = YES;
        [_page.modalStyle addObserver:self];
        [_page.shortTitle addObserver:self];
        [_page.hidden addObserver:self];
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(pageControllerThumbnailChangeNotification:) name:SWPageControllerThumbnailChangeNotification object:nil];
    }
}

- (void)endObservingModel
{
    if ( _isObserving )
    {
        _isObserving = NO;
        [_page.modalStyle removeObserver:self];
        [_page.shortTitle removeObserver:self];
        [_page.hidden removeObserver:self];
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc removeObserver:self];
    }
}

#pragma mark button action

- (IBAction)previewImageButtonTouched:(id)sender
{
}


#pragma mark Protocol Expression Observer

- (void)value:(SWValue *)value didEvaluateWithChange:(BOOL)changed
{
    if ( value == _page.shortTitle )
        [self _updateTitle];
    
    else if ( value == _page.modalStyle)
        [self _updateModalStyle];
    
    else if ( value == _page.hidden )
        [self _updatePageHidden];
}


#pragma thumbnailNotification

- (void)pageControllerThumbnailChangeNotification:(NSNotification*)note
{
    SWPage *page = note.object;
    if ( page == _page )
    {
        UIImage *image = note.userInfo[@1];
        [self _setImage:image];
    }
}


#pragma mark touch

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{

    // tallem la crida al super
    [super touchesBegan:touches withEvent:event];
    
    [_previewImageButton setCustomHighlighted:YES];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // tallem la crida al super
    [super touchesEnded:touches withEvent:event];
    
    //[_previewImageButton setCustomHighlighted:NO];
    
    // no podem utilitzar un runloop timer perque no s'executa fins que deixem anar el touch!
    [self _startDelayedUnhighlight];
    
    if ( _isSelected && [_page.docModel editMode])
    {
        [self _showMenu];
    }
}


- (void)dealloc
{
    if ( _unhTimer )
        dispatch_source_cancel(_unhTimer), _unhTimer = NULL;
}

- (void)_startDelayedUnhighlight
{
    if ( _unhTimer == NULL )
    {
        _unhTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue() );
    
        //dispatch_source_t theUnhTimer = _unhTimer;
       // __weak id theSelf = self ;  // evitem el retain cycle entre _saveTimer i self
        __weak SWCustomHighlightedButton *thePreviewImageButton = _previewImageButton;
        
        dispatch_source_set_event_handler( _unhTimer, 
        ^{
            //[theSelf _delayedUnHighlight];
            [thePreviewImageButton setCustomHighlighted:NO];
        });

        dispatch_source_set_cancel_handler( _unhTimer, 
        ^{
            //IOS6 dispatch_release( theUnhTimer );
        });
    
        dispatch_resume( _unhTimer );
    }
    
    dispatch_time_t tt = dispatch_time( DISPATCH_TIME_NOW, NSEC_PER_MSEC*200 );   // comenca d'aqui a 0,2 segons
    dispatch_source_set_timer( _unhTimer, tt, DISPATCH_TIME_FOREVER, 0 );      // no repeteix mai
}


- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    // tallem la crida al super
    [super touchesCancelled:touches withEvent:event];
    
    //[self _startDelayedUnhighlight];
    
    [_previewImageButton setCustomHighlighted:NO];
}


#pragma mark gesture recognizer

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
//{
//    return YES;
//}
//
//
//- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)recognizer
//{    
//    return YES;
//}
//
//
//- (void)_gestureRecognized:(UIGestureRecognizer*)recognizer
//{
//    if ( _isSelected && [_page.docModel editMode])
//    {
//        [self _showMenu];
//    }
//
//    if ( [_delegate respondsToSelector:@selector(pageNavigatorCellButtonTouched:)])
//        [_delegate pageNavigatorCellButtonTouched:self];
//}


#pragma mark UIResponder overrides

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if ( ![_page.docModel editMode])
        return NO;

    if (![self isFirstResponder])
        return NO;
    
    if (action == @selector(settings:) ||
        action == @selector(deleteAction:) ||
        action == @selector(duplicate:) ||
        action == @selector(copyToPasteboard:))
        return YES;
        
    if (action == @selector(pasteFromPasteboard:))
        if ([[UIPasteboard applicationPasteboard] containsPasteboardTypes:[NSArray arrayWithObject:kPasteboardPageListType]])
            return YES;
    
    return NO;
}

- (void)_showMenu
{
    SWModelManager *manager = [[SWModelManagerCenter defaultCenter] managerForDocumentModel:_page.docModel];
    [manager.inputController resignResponder];
    [self becomeFirstResponder];
    
    CGRect rect = _previewImageButton.frame;
    //CGRect rect = _previewImageView.frame;
    UIMenuController *menu = [UIMenuController sharedMenuController];
    [menu setTargetRect:rect inView:self];
    [menu setArrowDirection:UIMenuControllerArrowLeft];
    [menu setMenuVisible:YES animated:YES];
    [self performDelayedHideMenu];
}

- (void)performDelayedHideMenu
{
    [NSThread cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayedHideMenu) object:nil];
    [self performSelector:@selector(delayedHideMenu) withObject:nil afterDelay:4.0];
}

- (void)delayedHideMenu
{
    UIMenuController *menu = [UIMenuController sharedMenuController];
    [menu setMenuVisible:NO animated:YES];
}

#pragma mark menu actions

- (void)settings:(id)sender
{    
    SWModelManager *manager = [[SWModelManagerCenter defaultCenter] managerForDocumentModel:_page.docModel];
    //[manager presentModelConfiguratorForObject:_page animated:NO presentingControllerKey:nil];
    [manager presentModelConfiguratorOnControllerWithIdentifier:nil forObject:_page animated:IS_IPHONE];
}

- (void)copyToPasteboard:(id)sender
{
    NSData *data = [SymbolicArchiver archivedDataWithArrayOfObjects:@[_page]
            forKey:kSymbolicCodingCollectionKey
            version:SWVersion];
        
    UIPasteboard *pasteboard = [UIPasteboard applicationPasteboard];
    [pasteboard setData:data forPasteboardType:kPasteboardPageListType];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:kPasteboardContentDidChangeNotification object:nil userInfo:nil];
}


- (void)pasteFromPasteboard:(id)sender
{
    NSData *data = [[UIPasteboard applicationPasteboard] dataForPasteboardType:kPasteboardPageListType];
    NSError *error = nil;
    NSArray *pages = [SymbolicUnarchiver unarchivedObjectsWithData:data
                                    forKey:kSymbolicCodingCollectionKey
                                    builder:_page.builder
                                    parentObject:_page.docModel
                                    version:SWVersion
                                    outError:&error];
        
    if ( pages == nil )
    {
        return;
    }
    else
    {
        SWDocumentModel *docModel = _page.docModel;
        NSInteger insertionIndex = [docModel.pages indexOfObjectIdenticalTo:_page] + 1;
        [docModel insertPages:pages atIndexes:[NSIndexSet indexSetWithIndex:insertionIndex]];
    }
}


- (void)duplicate:(id)sender
{
   
    NSData *data = [SymbolicArchiver archivedDataWithArrayOfObjects:@[_page]
                                    forKey:kSymbolicCodingCollectionKey
                                    version:SWVersion];
                                                                    
    NSError *error = nil;
    NSArray *pages = [SymbolicUnarchiver unarchivedObjectsWithData:data
                                    forKey:kSymbolicCodingCollectionKey
                                    builder:_page.builder
                                    parentObject:_page.docModel
                                    version:SWVersion
                                    outError:&error];
        
    if ( pages == nil )
    {
        return;
    }
    else
    {
        SWDocumentModel *docModel = _page.docModel;
        NSInteger insertionIndex = [docModel.pages indexOfObjectIdenticalTo:_page] + 1;
        [docModel insertPages:pages atIndexes:[NSIndexSet indexSetWithIndex:insertionIndex]];
    }
}


- (void)deleteAction:(id)sender
{
    SWDocumentModel *docModel = _page.docModel;
    NSInteger index = [docModel.pages indexOfObjectIdenticalTo:_page];
    [docModel removePagesAtIndexes:[NSIndexSet indexSetWithIndex:index]];
}

@end
