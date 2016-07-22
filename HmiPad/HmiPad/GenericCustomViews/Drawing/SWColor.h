/*
 *  RGBColorMacros.h
 *  ScadaMobile_100827
 *
 *  Created by Joan on 29/08/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#ifdef __cplusplus
extern "C" {
#endif

//----------------------------------------------------------------------------------------------

#define LimitComponent(x) ((x)>255?255:((x)<0?0:(x)))
#define LimitComponenta(x) ((x)>127?127:((x)<0?0:(x)))
#define LimitComponentt(x) ((x)>1?1:((x)<0?0:(x)))
//#define Theme_RGB(t,r,g,b) ( (((t)<255?(t):255)<<24) | (((r)<255?(r):255)<<16) | (((g)<255?(g):255)<<8) | ((b)<255?(b):255) )
//#define Theme_RGB(t,r,g,b,a) ( (LimiteComponent(t)<<24) | (LimiteComponent(r)<<16) | (LimiteComponent(g)<<8) | (LimiteComponent(b)) )
#define Theme_RGBA(t,r,g,b,a) ((UInt32)( (LimitComponentt(t)<<31) | (LimitComponenta(a)<<24) | (LimitComponent(r)<<16) | (LimitComponent(g)<<8) | (LimitComponent(b)) ))
#define Theme_RGB(t,r,g,b) Theme_RGBA(t,r,g,b,0)

//#define TheSystemDarkBlueTheme Theme_RGB(1,50,79,133) // el tema pot indicar varies coses en aquest cas implica que es default
#define TextDefaultColor Theme_RGB(0,50,79,133)
#define TextDefaultColorFixed (IS_IOS7?Theme_RGB(0,128,128,128):TextDefaultColor)

#define TheSystemDarkBlueTheme Theme_RGB(1,80,80,80) // el tema pot indicar varies coses en aquest cas implica que es default
//#define TextDefaultColor Theme_RGB(0,80,80,80)


#define BlueSelectionColor Theme_RGB(0,0,128,255)
#define TangerineSelectionColor Theme_RGB(0,255,128,0)
#define RedColor Theme_RGB(0,255,0,0)
#define MultipleSelectionColor Theme_RGB( 0, (int)(255*0.91f), (int)(255*0.94f), (int)(255*0.98f) )

#define SystemClearBlackColor Theme_RGBA(0,0,0,0,127)
#define SystemClearWhiteColor Theme_RGBA(0,255,255,255,127)

//#define SystemDarkerBlueColor Theme_RGB(0,76,86,108)
#define SystemDarkerBlueColor Theme_RGB(0,80,80,80)
#define SystemRGBWhite Theme_RGB(0,255,255,255)


#define TheNiceGreenColor Theme_RGB(0,44,178,26)
#define BarDefaultColor Theme_RGB(0,44,178,26)
//#define TheNiceGreenColor Theme_RGB(0,27,175,57)

#define Theme(c)  (((c)>>31)&0x01)

#define ThemeR(c) (((c)>>16)&0xff)
#define ThemeG(c) (((c)>>8)&0xff)
#define ThemeB(c) (((c)>>0)&0xff)
#define ThemeA(c) (((c)>>24)&0x7f)   // indica transparencia ( 0x7f es totalment transparent, 0x0 es totalment opac)

#define ColorR(c) ((float)ThemeR(c)/255.0f)
#define ColorG(c) ((float)ThemeG(c)/255.0f)
#define ColorB(c) ((float)ThemeB(c)/255.0f)
#define ColorA(c) ((float)(127-ThemeA(c))/127.0f)

#define DarkenedRgbColor(c,k) Theme_RGBA( Theme(c), (unsigned)((k)*ThemeR(c)), (unsigned)((k)*ThemeG(c)), (unsigned)((k)*ThemeB(c)), ThemeA(c) )
#define OpacifiedRgbColor(c,k) Theme_RGBA( Theme(c), ThemeR(c), ThemeG(c), ThemeB(c),  (unsigned)(127-(k)*(127-ThemeA(c))) )

//#define UIColorWithRgb(c) (ThemeA(c)==127 ? [UIColor clearColor] : [UIColor colorWithRed:ColorR(c) green:ColorG(c) blue:ColorB(c) alpha:ColorA(c)])
#define UIColorWithRgb(c) [UIColor colorWithRed:ColorR(c) green:ColorG(c) blue:ColorB(c) alpha:ColorA(c)]
#define UIColorWithRgb_withThemeFilter(c) (Theme(c) ? [UIColor colorWithRed:ColorR(c) green:ColorG(c) blue:ColorB(c) alpha:ColorA(c)] : nil )
#define DarkenedUIColorWithRgb(c,k) [UIColor colorWithRed:ColorR(c)*(k) green:ColorG(c)*(k) blue:ColorB(c)*(k) alpha:ColorA(c)]
#define SetTheme_toRgbColor(t,c) ((c)=(UInt32)(((c)&0x7fffffff)|((t)<<31))  )
#define BrightnessForRgb(c) ((ColorR(c)*299.0f+ColorG(c)*587.0f+ColorB(c)*114.0f) / 1000.0f)


//extern CGFloat brightnessForColor(UIColor *color) ;

extern UIColor *groupTableViewBackgroundColor(void);   // substitut del metode deprecated amb el mateix nom de UIColor
extern UIColor *checkeredBackgroundColor(void);  // torna un color a quadres per representar res igual que photoshop
extern UIColor *contrastColorForRgbColor(UInt32 color) ;
extern UIColor *shadowColorForForRgbColor(UInt32 color) ;
extern UInt32 rgbColorForUIcolor(UIColor *color) ;

extern UIColor *contrastColorForUIColor(UIColor *color) ;
extern UIColor *shadowColorForUIColor(UIColor *color) ;
    
//----------------------------------------------------------------------------------------------
extern UInt32 getRgbValueForCName_len( const UInt8 *cstr, const int len ) ;
extern UInt32 getRgbValueForString( NSString *colorStr ) ;
    
extern NSString* getColorStrForRgbValue(UInt32 value);
extern NSArray* getAllColorStr(void);

/*  Deprecated, Removed
#import "SWExpression.h"
UIColor* colorFromExpression(SWExpression *exp);
UInt32 getRgbValueFromExpression(SWExpression *exp);
*/

#ifdef __cplusplus
}
#endif