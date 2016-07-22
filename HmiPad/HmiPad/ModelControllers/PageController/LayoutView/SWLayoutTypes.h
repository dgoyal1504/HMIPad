//
//  SWLayoutTypes.m
//  HmiPad
//
//  Created by Joan Martin on 9/6/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

typedef enum {
    SWLayoutViewCellEventTypeUnknown = 0,
    SWLayoutViewCellEventTypeTopLeft = 1<<0,
    SWLayoutViewCellEventTypeTopCenter = 1<<1,
    SWLayoutViewCellEventTypeTopRight = 1<<2,
    SWLayoutViewCellEventTypeMidleLeft = 1<<3,
    SWLayoutViewCellEventTypeMidleRight = 1<<4,
    SWLayoutViewCellEventTypeBottomLeft = 1<<5,
    SWLayoutViewCellEventTypeBottomCenter = 1<<6,
    SWLayoutViewCellEventTypeBottomRight = 1<<7,
    SWLayoutViewCellEventTypeInside = 1<<8,
    SWLayoutViewCellEventTypeZeroProximity = 1<<9,
    
    
    //SWLayoutViewCellEventTypeTop = 0b00000111, // 7
    //SWLayoutViewCellEventTypeBottom = 0b11100000, // 224
    //SWLayoutViewCellEventTypeLeft = 0b00101001, // 41
    //SWLayoutViewCellEventTypeRight = 0b10010100, // 148
    //SWLayoutViewCellEventTypeTopBottom = 0b11100111,
    //SWLayoutViewCellEventTypeLeftRight = 0b10111101,
    //SWLayoutViewCellEventTypeInside =  0b100000000
    //SWLayoutViewCellEventTypeButtons = 0b011111111,

    SWLayoutViewCellEventTypeTop = SWLayoutViewCellEventTypeTopLeft|
        SWLayoutViewCellEventTypeTopCenter|SWLayoutViewCellEventTypeTopRight,
    
    SWLayoutViewCellEventTypeBottom = SWLayoutViewCellEventTypeBottomLeft|
        SWLayoutViewCellEventTypeBottomCenter|SWLayoutViewCellEventTypeBottomRight,
        
    SWLayoutViewCellEventTypeLeft = SWLayoutViewCellEventTypeTopLeft|
        SWLayoutViewCellEventTypeMidleLeft|SWLayoutViewCellEventTypeBottomLeft,
    
    SWLayoutViewCellEventTypeRight = SWLayoutViewCellEventTypeTopRight|
        SWLayoutViewCellEventTypeMidleRight|SWLayoutViewCellEventTypeBottomRight,
    
    SWLayoutViewCellEventTypeTopBottom = SWLayoutViewCellEventTypeTop|SWLayoutViewCellEventTypeBottom,
    SWLayoutViewCellEventTypeLeftRight = SWLayoutViewCellEventTypeLeft|SWLayoutViewCellEventTypeRight,
    
    SWLayoutViewCellEventTypeInsideZeroProximity = SWLayoutViewCellEventTypeInside|SWLayoutViewCellEventTypeZeroProximity,
    SWLayoutViewCellEventTypeButtons = ~SWLayoutViewCellEventTypeInsideZeroProximity,
    
} SWLayoutViewCellEventType;

typedef enum {
    SWLayoutViewCellResizingStyleNone = 0,
    SWLayoutViewCellResizingStyleHorizontal = 0b01,
    SWLayoutViewCellResizingStyleVertical = 0b10,
    SWLayoutViewCellResizingStyleAll = 0b11
} SWLayoutViewCellResizingStyle;


typedef enum {
    SWLayoutResizerViewDirectionUp,
    SWLayoutResizerViewDirectionLeft,
    SWLayoutResizerViewDirectionDown,
    SWLayoutResizerViewDirectionRight,
} SWLayoutResizerViewDirection;

//typedef enum {
//    SWLayoutResizerViewResizeVerticalExpand,
//    SWLayoutResizerViewResizeVerticalShrink,
//    SWLayoutResizerViewResizeHorizontalExpand,
//    SWLayoutResizerViewResizeHorizontalShink,
//} SWLayoutResizerViewResize;

// ---- FRAME MANIPULATION ---- //

extern CGRect correctRect_fromRect_usingMinimalSize(CGRect newRect, CGRect oldRect, CGSize minimalSize);

// ---- RULERS ---- //

struct SWRuler
{
    CGPoint fromPoint;
    CGPoint toPoint;
};
typedef struct SWRuler SWRuler;

static inline SWRuler SWRulerMake(CGPoint fromPoint, CGPoint toPoint)
{
    SWRuler ruler;
    ruler.fromPoint = fromPoint;
    ruler.toPoint = toPoint;
    return ruler;
}

static inline bool __SWRulerEqualToRuler(SWRuler ruler1, SWRuler ruler2)
{
    return  CGPointEqualToPoint(ruler1.fromPoint, ruler2.fromPoint) &&
    CGPointEqualToPoint(ruler1.toPoint, ruler2.toPoint) &&
    CGPointEqualToPoint(ruler1.fromPoint, ruler2.toPoint) &&
    CGPointEqualToPoint(ruler1.toPoint, ruler2.fromPoint);
}
#define SWRulerEqualToRuler __SWRulerEqualToRuler

extern const SWRuler SWRulerZero;