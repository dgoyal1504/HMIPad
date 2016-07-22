//
//  TKAlertCenter.h
//  Created by Devin Ross on 9/29/10.
//  Thoroughly modified and extended by Joan Lluch on 5/08/12
//
/*
 
 tapku.com || http://github.com/devinross/tapkulibrary
 
 Permission is hereby granted, free of charge, to any person
 obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without
 restriction, including without limitation the rights to use,
 copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following
 conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


/*
Clase per mostrar un HUD Alert amb diferents possibilitats.
Per defecte mostra una alerta durant un temps propocional a la longitud del missatge, 
i mostra les alertes un darrera l'altre en els temps corresponents.
Es pot aturar la presentacio de missatges pendents cridant cancelPendingAlerts.
Es poden mostrar els missatges pendents en una unica alerta cridant groupPendingAlerts.
Es pot prolongar indefinidament el temps de presentacio cridant setPermanent, en aquest
cas la alerta desapareix inmediatament cridant cancelPendingAlerts


*/


@interface SWAlertCenter : NSObject 

+ (SWAlertCenter*)defaultCenter;
- (void)setPermanent:(BOOL)value;
- (void)postAlertWithMessage:(NSString*)message;
- (void)postAlertWithMessage:(NSString*)message title:(NSString*)title;
- (void)postAlertWithMessage:(NSString*)message image:(UIImage*)image;
- (void)postAlertWithMessage:(NSString*)message view:(UIView*)view;
- (void)cancelPendingAlerts;
- (void)groupPendingAlerts;

@end





