//
//  ControlViewCell.h
//  iPhoneDomusSwitch_090409
//
//  Created by Joan on 09/04/09.
//  Copyright 2009 SweetWilliam, S.L.. All rights reserved.

#import <UIKit/UIKit.h>
#import "GradientBackgroundView.h"

#import "UIView+DecoratorView.h"

@class SWTableFieldsController;
@class ControlViewCell ;

/*
//////////////////////////////////////////////////////////////////////////////
#pragma mark VerticallyAlignedLabel
//////////////////////////////////////////////////////////////////////////////

typedef enum VerticalAlignment 
{
    VerticalAlignmentTop,
    VerticalAlignmentMiddle,
    VerticalAlignmentBottom,
} VerticalAlignment;
 
@interface VerticallyAlignedLabel : UILabel 

{
    @private
    VerticalAlignment verticalAlignment_;
}
 
@property (nonatomic, assign) VerticalAlignment verticalAlignment;
 
@end
*/

////////////////////////////////////////////////////////////////////////////////
//#pragma mark MessageView
////////////////////////////////////////////////////////////////////////////////
//
////----------------------------------------------------------------------------
//@interface MessageView : UIView
//{
//    NSString *message;
//    CGFloat messageHeight; 
//    UILabel *messageViewLabel;
//    __weak UITableView *tableView ; // weak
//}
//
//@property (nonatomic, retain) NSString *message ;
//@property (nonatomic, readonly) CGFloat messageHeight ;
//@property (nonatomic, readonly) UILabel *messageViewLabel ;
//- (id)initWithTableView:(UITableView*)theOwner ;
//
//
//@end

//////////////////////////////////////////////////////////////////////////////
#pragma mark ControlViewCellContentView
//////////////////////////////////////////////////////////////////////////////

@interface ControlViewCellContentView : UIView
{
    BOOL highlight ;
    
    NSString *mainText ;
    UIFont *mainTextFont ;
    UIColor *mainTextColor ;
    UIColor *shadowColor ;
    UIColor *mainTextHighlightColor ;
    
    NSString *bottomText ;
    UIFont *bottomTextFont ;
    UIColor *bottomTextColor ;
    UIColor *bottomTextHighlightColor ;
    
    BOOL multilineMainText ;
    BOOL shadowedMainText ;
    BOOL centeredMainText ;
    //BOOL lateralBottomText ;
}


@property (nonatomic, assign) ControlViewCell *parentCell ;

@property (nonatomic, retain) NSString *mainText ;
@property (nonatomic, retain) UIFont *mainTextFont ;
@property (nonatomic, retain) UIColor *mainTextColor;
@property (nonatomic, retain) UIColor *shadowColor;
@property (nonatomic, retain) UIColor *mainTextHighlightColor;

@property (nonatomic, retain) NSString *bottomText ;
@property (nonatomic, retain) UIFont *bottomTextFont ;
@property (nonatomic, retain) UIColor *bottomTextColor ;
@property (nonatomic, retain) UIColor *bottomTextHighlightColor ;

@property (nonatomic, assign) BOOL multilineMainText;
@property (nonatomic, assign) BOOL shadowedMainText;
@property (nonatomic, assign) BOOL centeredMainText;
//@property (nonatomic, assign) BOOL lateralBottomText;


- (id)initWithFrame:(CGRect)frame parentCell:(ControlViewCell*)parent;

@end


//////////////////////////////////////////////////////////////////////////////
#pragma mark ControlViewGradientBackgroundView
//////////////////////////////////////////////////////////////////////////////

@interface ControlViewGradientBackgroundView : GradientBackgroundView //UIView
{
}

- (id)initWithFrame:(CGRect)frame ;

@end



//////////////////////////////////////////////////////////////////////////////
#pragma mark ControlViewCell
//////////////////////////////////////////////////////////////////////////////

/*
//----------------------------------------------------------------------------
typedef enum
{
    ControlViewCellDecorationTypeNone = 0,
    ControlViewCellDecorationTypeAlert,
    ControlViewCellDecorationTypeWhiteActivityIndicator,
    ControlViewCellDecorationTypeGrayActivityIndicator,
    ControlViewCellDecorationTypeCheckMark,
    ControlViewCellDecorationTypeGray,
    ControlViewCellDecorationTypeGreen,
    ControlViewCellDecorationTypePurple,
    ControlViewCellDecorationTypeRed
} ControlViewCellDecorationType ;
*/

//----------------------------------------------------------------------------
@interface ControlViewCell : UITableViewCell
{    
    ItemDecorationType decorationType;
    BOOL isRightDecoration ;
    ControlViewCellContentView *cellContentView ;
    UIView *rightView;
    UIView *leftView;
}


@property (nonatomic, readonly) ControlViewCellContentView *cellContentView ;
@property (nonatomic, retain) NSString *mainText;
@property (nonatomic, retain) NSString *bottomText;   
@property (nonatomic, retain) UIView *leftView;
@property (nonatomic, retain) UIView *rightView;
@property (nonatomic, retain) UIView *selectedRightView;

// si es >0 agafa la mida del mainText per determinar la mida del view de la dreta i tabula aquest ultim
// si es ==0 agafa la mida del view de la dreta per determinar la mida del mainText
@property (nonatomic) CGFloat tabWidth;

// indica la mida minima del mainText
@property (nonatomic) CGFloat leadingTabWidth;

// indica la mida maxima del mainText, no te efecte si tabWidth >0
@property (nonatomic) CGFloat maxTabbingWidth;

// mida minima del right view
@property (nonatomic) CGSize minRightViewSize ;

- (id)initWithReuseIdentifier:(NSString *)identifier;
- (void)setDecorationType:(ItemDecorationType)type right:(BOOL)right animated:(BOOL)animated;
- (void)setIndentationWidthForDecorationType:(ItemDecorationType)type right:(BOOL)right;

@end


//////////////////////////////////////////////////////////////////////////////
#pragma mark SwitchViewCell
//////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------
@interface SwitchViewCell : ControlViewCell

@property (nonatomic, strong, readonly) UISwitch *switchv ;

@end


//////////////////////////////////////////////////////////////////////////////
#pragma mark TextFieldCell
//////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------
@interface TextFieldCellTextField : UITextField
{
}

-(void)setText:(NSString*)newText;

@end

//----------------------------------------------------------------------------
@interface TextFieldCell : ControlViewCell
{
    TextFieldCellTextField *textField ;
}

@property (nonatomic, strong, readonly)  UITextField *textField ;

@end


//////////////////////////////////////////////////////////////////////////////
#pragma mark ManagedTextFieldCell
//////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------
// Aquesta clase permet gestionar una serie de TextFieldCells que estan en un
// tableview gestionat ultimament per un navigationController. Se li passa com
// a inicialitzador l'objecte NaVigationButtonController que tindra cura de
// de la gestió de tot plegat. El NavigationButtonControler ha d'estar inicialitzat
// amb un owner (generalment el controlador de la taula), que respongui a la 
// propietat navigationItem i a les funcions delegades del NavigationButtonController,
// Adicionalment, per a ser utilitzat en combinació de un ManagedTextField, el 
// owner del NavigationButtonController pot implementar el protocol UITextFieldDelegate
// per un control més acurat de les accions sobre el ManagedTextField

@interface ManagedTextFieldCell : TextFieldCell<UITextFieldDelegate>
{
    SWTableFieldsController *navButtonController ;
    id<UITextFieldDelegate> owner ;
}

- (id)initWithSWTableFieldsController:(SWTableFieldsController*)navBController 
                           reuseIdentifier:(NSString*)identifier;
                           
@end



//////////////////////////////////////////////////////////////////////////////
#pragma mark LabelViewCell
//////////////////////////////////////////////////////////////////////////////
//----------------------------------------------------------------------------
@interface LabelViewCellLabel : UILabel
{
}

-(void)setText:(NSString*)newText;

@end


//----------------------------------------------------------------------------
@interface LabelViewCell : ControlViewCell
{
    UILabel *secondLabel ; // en realitat és un LabelViewCellLabel
}

@property (nonatomic, strong, readonly) UILabel *secondLabel ;
@property (nonatomic, assign) BOOL isButtonLikeCell;

@end



//////////////////////////////////////////////////////////////////////////////
#pragma mark PlcTagViewCell
//////////////////////////////////////////////////////////////////////////////
@class EdgeLayer ;
//----------------------------------------------------------------------------
@interface PlcTagViewCell : ControlViewCell
{
    __weak id delegate ;
    EdgeLayer *edgeLayer ;
}

@property (nonatomic, weak) id delegate ;
- (void)setEdgeColor:(UIColor *)color ;

@end



//////////////////////////////////////////////////////////////////////////////
#pragma mark InfoViewCell
//////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------
@interface InfoViewCell : ControlViewCell
{
}


@end






