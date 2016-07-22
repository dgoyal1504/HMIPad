//
//  SWValueTypeEnumCell.m
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 6/20/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWValueTypeEnumCell.h"
#import "SWPropertyDescriptor.h"
#import "SWColor.h"

#import "SWTableSelectionController.h"
#import "FPPopoverController.h"

NSString * const SWValueTypeEnumCellIdentifier = @"ValueTypeEnumCellIdentifier";
NSString * const SWValueTypeEnumCellNibName = @"SWValueTypeEnumCell";
NSString * const SWValueTypeEnumCellNibName6 = @"SWValueTypeEnumCell6";



@interface SWValueTypeEnumCell()<SWTableSelectionControllerDelegate,UIPopoverControllerDelegate,FPPopoverControllerDelegate>
{
    UIPopoverController *_popover;
    FPPopoverController *_fpPopover;
}
@end;

@implementation SWValueTypeEnumCell

@synthesize valueButton = _valueButton;
@dynamic delegate;

#pragma mark Overriden Methods

- (void)awakeFromNib
{
    [super awakeFromNib];
    if ( IS_IOS7 )
    {
    }
    else
    {
        [_valueButton setTitleColor:UIColorWithRgb(TextDefaultColor) forState:UIControlStateNormal];
    }
}

- (void)refreshValue
{
    [super refreshValue];
        
    NSArray *options = [_delegate optionsForEnumCell:self];
    NSString *title = [options objectAtIndex:_value.valueAsInteger];
    [_valueButton setTitle:title forState:UIControlStateNormal];
}

#pragma mark Public Methods

//- (IBAction)valueButtonPushedV:(id)sender
//{
//    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:_value.property
//                                                       delegate:self 
//                                              cancelButtonTitle:nil
//                                         destructiveButtonTitle:nil 
//                                              otherButtonTitles:nil];
//    
//
//    
//    NSArray *options = [_delegate optionsForEnumCell:self];
//    for (NSString *option in options)
//    {
//        [sheet addButtonWithTitle:option];
//    }
//
//    [sheet addButtonWithTitle:NSLocalizedString(@"Dismiss",nil)];
//    sheet.cancelButtonIndex = sheet.numberOfButtons-1;
//    
//    UIView *view = sender;
//    [sheet showFromRect:view.bounds inView:view animated:YES];
//}



- (IBAction)valueButtonPushed:(id)sender
{
    NSArray *options = [_delegate optionsForEnumCell:self];
    NSInteger initialOption = _value.valueAsDouble;
    
//    SWTableSelectionController *tsc = [[SWTableSelectionController alloc] initWithStyle:UITableViewStylePlain andOptions:options];
    SWTableSelectionController *tsc = [[SWTableSelectionController alloc] initWithStyle:UITableViewStylePlain options:options];
    [tsc.tableView setScrollEnabled:NO];
    //[tsc setContentSizeForViewInPopover:CGSizeMake(200,options.count*44-1)];
    tsc.preferredContentSize = CGSizeMake(200,options.count*44-1);
    tsc.delegate = self;
    tsc.swselectedOptionIndex = initialOption;
    
    if ( IS_IPHONE )
    {
        _fpPopover = [[FPPopoverController alloc] initWithViewController:tsc];
        _fpPopover.border = NO;
        _fpPopover.tint = FPPopoverWhiteTint;
        _fpPopover.delegate = self;
        [_fpPopover presentPopoverFromView:_valueButton];
    }
    else
    {
        _popover = [[UIPopoverController alloc] initWithContentViewController:tsc];
        _popover.delegate = self;
        [_popover presentPopoverFromRect:_valueButton.bounds inView:_valueButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}



#pragma mark SWTableSelectionControllerDelegate

- (void)tableSelection:(SWTableSelectionController *)controller didSelectOption:(NSString *)option
// aquest no cal si ja observem el model pero sembla raonable actualitzar la vista independenment de si estem observant o no
{
    [_valueButton setTitle:option forState:UIControlStateNormal];
}

- (void)tableSelection:(SWTableSelectionController *)controller didSelectOptionAtIndex:(NSInteger)index
{
    [_value setValueAsDouble:index];
    [_popover dismissPopoverAnimated:YES];
    [_fpPopover dismissPopoverAnimated:YES];
}

#pragma mark popover

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    _popover = nil;
    _fpPopover = nil;
}


//#pragma mark Protocol ActionSheet Delegate
//
//- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    if (buttonIndex == actionSheet.cancelButtonIndex)
//        return;
//    
//    NSLog(@"Setting to value %@ valueAsDouble: %d",self.value.property, buttonIndex);
//    
//    [_value setValueAsDouble:buttonIndex];
//}

@end






//
//  SamplePopoverBackgroundView.h
//  poc
//
//  Created by Andrew Kolesnikov on 11/22/11.
//  Copyright (c) 2011 Isobar. All rights reserved.
//

@interface SamplePopoverBackgroundView : UIPopoverBackgroundView
    {
      UIImageView *_imageView;
      UIImageView *_arrowView;
    }

    /* The arrow offset represents how far from the center of the view the center of the arrow should appear. For `UIPopoverArrowDirectionUp` and `UIPopoverArrowDirectionDown`, this is a left-to-right offset; negative is to the left. For `UIPopoverArrowDirectionLeft` and `UIPopoverArrowDirectionRight`, this is a top-to-bottom offset; negative to toward the top.This method is called inside an animation block managed by the `UIPopoverController`.
      */

    @property (nonatomic, readwrite) CGFloat arrowOffset;

    /* `arrowDirection` manages which direction the popover arrow is pointing. You may be required to change the direction of the arrow while the popover is still visible on-screen.
     */

    @property (nonatomic, readwrite) UIPopoverArrowDirection arrowDirection;

    /* These methods must be overridden and the values they return may not be changed during use of the `UIPopoverBackgroundView`. `arrowHeight` represents the height of the arrow in points from its base to its tip. `arrowBase` represents the the length of the base of the arrow&rsquo;s triangle in points. `contentViewInset` describes the distance between each edge of the background view and the corresponding edge of its content view (i.e. if it were strictly a rectangle). `arrowHeight` and `arrowBase` are also used for the drawing of the standard popover shadow.
     */

    + (CGFloat)arrowHeight;
    + (CGFloat)arrowBase;
    + (UIEdgeInsets)contentViewInsets;

@end

 

 //
    //  SamplePopoverBackgroundView.m
    //  poc
    //
    //  Created by Andrew Kolesnikov on 11/22/11.
    //  Copyright (c) 2011 Isobar. All rights reserved.
    //

    @implementation SamplePopoverBackgroundView

    @synthesize arrowOffset, arrowDirection;

    -(id)initWithFrame:(CGRect)frame{
      if (self = [super initWithFrame:frame]) {
        _imageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"bg-popover.png"] resizableImageWithCapInsets: UIEdgeInsetsMake(40.0, 10.0, 30.0, 10.0)]];
        _arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg-popover-arrow.png"]];

        self.backgroundColor =  _arrowView.backgroundColor =  _imageView.backgroundColor = [UIColor clearColor];
        [self addSubview:_imageView];
        [self addSubview:_arrowView];
      }
      return self;
    }

    - (void)drawRect:(CGRect)rect {

    }

    -(void)layoutSubviews{
    
      if (arrowDirection == UIPopoverArrowDirectionUp) {
      _imageView.frame = CGRectMake(0, [SamplePopoverBackgroundView arrowHeight], self.superview.frame.size.width, self.superview.frame.size.height - [SamplePopoverBackgroundView arrowHeight]);

      _arrowView.frame = CGRectMake(self.superview.frame.size.width / 2 + arrowOffset - [SamplePopoverBackgroundView arrowBase] / 2, 2, [SamplePopoverBackgroundView arrowBase], [SamplePopoverBackgroundView arrowHeight]);

      }

      if (arrowDirection == UIPopoverArrowDirectionRight) {
        _imageView.frame = CGRectMake(0, 0, self.superview.frame.size.width - [SamplePopoverBackgroundView arrowHeight], self.superview.frame.size.height);

        _arrowView.image = [[UIImage alloc] initWithCGImage: _arrowView.image.CGImage scale: 1.0 orientation: UIImageOrientationRight];
        _arrowView.frame = CGRectMake(self.superview.frame.size.width - [SamplePopoverBackgroundView arrowHeight] - 1, self.superview.frame.size.height / 2 + arrowOffset - [SamplePopoverBackgroundView arrowBase] / 2, [SamplePopoverBackgroundView arrowHeight], [SamplePopoverBackgroundView arrowBase]);

      }
    }

    +(UIEdgeInsets)contentViewInsets{
      return UIEdgeInsetsMake(5, 5, 5, 5);
    }

    +(CGFloat)arrowHeight{
      return 21.0;
    }

    +(CGFloat)arrowBase{
      return 35.0;
    }

    @end


















