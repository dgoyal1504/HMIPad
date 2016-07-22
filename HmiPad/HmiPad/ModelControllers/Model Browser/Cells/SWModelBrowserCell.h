//
//  SWModelBrowserCell.h
//  HmiPad
//
//  Created by Joan Martin on 8/10/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

/*
 ---------------------- ATENCIÓ! ----------------------
 Aquesta classe és una cel·la no acoplada a cap model. Està ben feta!
 Permet seleccionar el tipus d'accessory (entre disclosure indicator i una roda dentada) i afegeix un label a la dreta (rightDetailTextLabel).
 La cel·la no depèn de cap XIB, així que és sublcassable per tal de fer-la dependre del model sense necessitat de crear nous xibs.
 ------------------------------------------------------
*/

#import "SWDrawRectCell.h"
#import "RoundedLabel.h"
 
typedef enum {
    SWModelBrowserCellAccessoryTypeNone,
    SWModelBrowserCellAccessoryTypeDisclosureIndicator,
    SWModelBrowserCellAccessoryTypeGroupDisclosureIndicator,
    SWModelBrowserCellAccessoryTypeGearIndicator,
    SWModelBrowserCellAccessoryTypeSeekerIndicator
} SWModelBrowserCellAccessoryType;

@interface SWModelBrowserCell : SWDrawRectCell

//@property (strong, nonatomic) UILabel *rightDetailTextLabel;
//@property (strong, nonatomic) UIColor *rightDetailTintColor;

@property (nonatomic, readonly) RoundedLabel *rightDetailTextLabel;

- (void)setRightDetailTintColor:(UIColor*)color;

//@property (nonatomic, assign) SWModelBrowserCellAccessoryType accessory;
- (void)setAccessory:(SWModelBrowserCellAccessoryType)accessory;
@property (nonatomic, assign) CGFloat rightOffset;

//- (void)setupSelectionStyle;

//@property (nonatomic, assign) BOOL mark;
//@property (nonatomic, strong) UIColor *markTintColor;

@end
