//
//  UIAlertView+Block.m
//  HmiPad
//
//  Created by Joan on 11/06/13.
//  Copyright (c) 2013 SweetWilliam, SL. All rights reserved.
//

#import "SWBlockActionSheet.h"

@interface SWBlockActionSheet()<UIActionSheetDelegate>
{
    void (^_resultBlock)(BOOL success, NSInteger index);
}
@end

@implementation SWBlockActionSheet

- (void)setResultBlock:( void (^)(BOOL success, NSInteger index))resultBlock
{
    self.delegate = self;
    _resultBlock = resultBlock;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    NSInteger cancelIndex = [actionSheet cancelButtonIndex];
    BOOL success = !( buttonIndex == cancelIndex );
    if ( _resultBlock )
        _resultBlock(success,buttonIndex);
    
    _resultBlock = nil;  // ens carreguem _resultBlock per evitar retain cicles
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ( _resultBlock )
        _resultBlock(NO,[actionSheet cancelButtonIndex]);
    
    _resultBlock = nil;  // ens carreguem _resultBlock per evitar retain cicles
}



@end

