//
//  SWSourceTitleCell.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 3/20/12.
//  Copyright (c) 2012 Sweet William SL. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SWSourceItemCell.h"
#import "SWSourceItem.h"

@interface SWSourceTitleCell : SWSourceItemCell <SWObjectObserver>

//@property (nonatomic, strong) NSString *format;
//@property (nonatomic, assign) BOOL decorationSymbolEnabled;
@property (nonatomic, readonly) ItemDecorationType decorationType;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end
