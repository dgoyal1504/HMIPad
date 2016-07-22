//
//  SWEventsViewController.h
//  HmiPad
//
//  Created by Joan on 08/08/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewController.h"

//@class SWDocumentModel;
@class SWHistoAlarms;

@interface SWHistoEventsViewController : SWTableViewController
//@interface SWHistoEventsViewController : UITableViewController
{
}

//@property (nonatomic, strong) SWDocumentModel *documentModel;
@property (nonatomic, strong) SWHistoAlarms *histoAlarms;


@end


