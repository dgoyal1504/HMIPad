//
//  SWKeyboardListener.h
//  ScadaMobile
//
//  Created by Joan on 13/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SWKeyboardListener:NSObject 
{
    BOOL isVisible;
    CGRect frame ;
}

+ (SWKeyboardListener *)sharedInstance;
- (BOOL)isVisible;
- (CGRect)frame;    // torna el frame del teclat en coordenades de window
- (CGFloat)offset;  // torna la altura del teclat
- (CGFloat)gap;     // torna el espai que hi ha disponible per sobra del teclat
- (void)postKeyboardNotification;

@end

// utilitzar aquestes si es vol tenir isVisible i frame actualitzades en rebre la notificacio
extern NSString * const SWKeyboardWillShowNotification;
extern NSString * const SWKeyboardDidShowNotification;
extern NSString * const SWKeyboardWillHideNotification;
extern NSString * const SWKeyboardDidHideNotification;
extern NSString * const SWKeyboardWillChangeFrameNotification;
extern NSString * const SWKeyboardDidChangeFrameNotification;



// afegim una categoria de UIViewController per resoldre el bug dels insets dels UITableViewController amb el teclat
// i incorporar la mateixa funcionalitat en qualsevol controlador de respongui a tableView

//
//@interface UIViewController(TableViewBug)
//- (void)beginAdjustingInsetsForKeyboard;   // <-- cridar en el viewWillAppear
//- (void)endAdjustingInsetsForKeyboard;   // <-- cridar en el viewWillDisappear
//@property(nonatomic,assign) CGPoint tableViewOffset;
//
//@end





//@interface SWTableView : UITableView
//
//@property (nonatomic,assign) CGPoint tableViewOffset;
//
//@end
//
//
//
//@interface UIViewController(TableViewOffset)
//
//@property(nonatomic,assign) CGPoint tableViewOffset;
//
//@end




