//
//  IncidentView.h
//  ScadaMobile_090721
//
//  Created by Joan on 28/07/09.
//  Copyright 2009 SweetWilliam, S.L.. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface IncidentView : UIView 
{
    UIImageView *imageView ;
    UILabel *mainLabel ;
    UILabel *secondaryLabel ;
}

@property (nonatomic, readonly) UILabel *mainLabel;
@property (nonatomic, readonly) UILabel *secondaryLabel;

@end
