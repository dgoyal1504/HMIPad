//
//  SWLayoutTypes.m
//  HmiPad
//
//  Created by Joan Martin on 9/6/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import "SWLayoutTypes.h"

const SWRuler SWRulerZero = {{0,0}, {0,0}};

CGRect correctRect_fromRect_usingMinimalSize(CGRect newRect, CGRect oldRect, CGSize minimalSize)
{
    BOOL top = NO;
    BOOL left = NO;
    BOOL right = NO;
    BOOL bottom = NO;
    
    if (newRect.origin.y == oldRect.origin.y)
    {
        if(newRect.size.height != oldRect.size.height)
            bottom = YES;
    }
    else
    {
        top = YES;
    }
        
    if (newRect.origin.x == oldRect.origin.x)
    {
        if( newRect.size.width != oldRect.size.width)
            right = YES;
    }
    else
    {
        left = YES;
    }
            
    if (right && newRect.size.width < minimalSize.width)
        newRect.size.width = minimalSize.width;
    
    if (bottom && newRect.size.height < minimalSize.height)
        newRect.size.height = minimalSize.height;
                    
    if (top && newRect.size.height < minimalSize.height)
    {
        CGFloat offset = minimalSize.height - newRect.size.height;
        newRect.origin.y -= offset;
        newRect.size.height = minimalSize.height;
    }
    
    if (left && newRect.size.width < minimalSize.width)
    {
        CGFloat offset = minimalSize.width - newRect.size.width;
        newRect.origin.x -= offset;
        newRect.size.width = minimalSize.width;
    }
    
    return newRect;
}
