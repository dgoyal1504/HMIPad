//
//  SWPropertyListTableViewController.h
//  HmiPad
//
//  Created by Joan Martín Hernàndez on 5/17/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SWPropertyListTableViewController;

@protocol SWPropertyListTableViewDataSource <NSObject>
+ (NSString*)itemName;
+ (NSString*)itemDescription;
+ (UIImage*)itemIcon;
@end

@protocol SWPropertyListTableViewControllerDelegate <NSObject>
- (void)propertyListTableViewControllerDelegate:(SWPropertyListTableViewController*)controller didSelectOption:(NSString*)option;
@end

@interface SWPropertyListTableViewController : UITableViewController {
    NSDictionary *_dictionary;
}

- (id)initWithPropertyList:(NSString*)propertyListFileName inBundle:(NSBundle*)bundle style:(UITableViewStyle)style;
- (id)initWithDictionary:(NSDictionary*)dictionary style:(UITableViewStyle)style;

@property (nonatomic, readonly) CGSize popoverSize;

@property (nonatomic, weak) id <SWPropertyListTableViewControllerDelegate> delegate;

@end
