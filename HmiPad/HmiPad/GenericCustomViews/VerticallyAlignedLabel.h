//
//  VerticallyAlignedLabel.h
//  HmiPad
//
//  Created by Joan on 21/05/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum VerticalAlignment 
{
    VerticalAlignmentTop,
    VerticalAlignmentMiddle,
    VerticalAlignmentBottom,
} VerticalAlignment;
 
@interface VerticallyAlignedLabel : UILabel 
{
}
 
@property (nonatomic, assign) VerticalAlignment verticalAlignment;
 
@end
