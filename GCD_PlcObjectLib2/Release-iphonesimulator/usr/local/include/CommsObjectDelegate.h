//
//  PlcCommsObjectDelegate.h
//  Domus
//
//  Created by Joan on 05/03/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

@class PlcCommsObject ;
//@class FinsRequest ;   // a treure

//------------------------------------------------------------------------------------------------
// Metodes opcionals a implementar per el delegat de PlcCommsObject

@protocol CommsObjectDelegate<NSObject>

@optional

// Avis de que estem esperant que hi hagi access a xarxa (WiFi o Mobil)
- (void)finsSocketWillReach:(PlcCommsObject*)plcObj ;

// Tenim access a xarxa
- (void)finsSocketDidReach:(PlcCommsObject*)plcObj ;

// Estem esperant la conexio del socket
- (void)finsSocketWillConnect:(PlcCommsObject*)plcObj ;

// El socket s'ha conectat
- (void)finsSocketDidConnect:(PlcCommsObject*)plcObj ;

// El objecte ha enllacat am el PLC incluint la configuracio inicial i el validation tag
- (void)finsDidLink:(PlcCommsObject*)plcObj altHost:(BOOL)altHost;

// S'ha completat el procesament de una peticio de lectura amb canvi en al menys un plcTagElement
- (void)finsMonitoredTagsDidChange:(PlcCommsObject*)plcObj plcTagElements:(NSArray*)elements contextObj:(id)obj ;

// S'ha completat el procesament de una peticio de escritura amb resultat que no afecta les comunicacions
- (void)finsDidCompleteWrite:(PlcCommsObject*)plcObj plcTagElements:(NSArray*)elements contextObj:(id)obj ;

// Despres de una lectura o escritura. Hi ha algun avis que no provoca desconexio
- (void)finsDidReportIssue:(PlcCommsObject*)plcObj error:(NSError*)error ;

// Notificacio del nombre de comandes per segon enviades i el nombre de lectures per segon.
// Es crida com a maxim 2 cops per segon 
- (void)finsPollingProgress:(PlcCommsObject*)plcObj cps:(float)cps rps:(float)rps ;

// Notificacio de canvi en el numero de tags que estan registrats per llegir
// Es crida despres de rebre un restoreMonitoredTagElementsByAdding o un removeAllMonitoredTagElements
- (void)finsPollingTagsCountDidChange:(PlcCommsObject*)plcObj count:(int)count ;
     
// El socket s'ha tancat
- (void)finsDidClose:(PlcCommsObject*)plcObj ;

// S'ha produit un error que afecta les comunicacions en qualsevol dels estadis de l'objecte. Els errors estan 
// generalment adaptats dels que torna AsyncSocket o autogenerats.
// (Veure el codi font per mes informacio)
- (void)finsErrorOcurred:(PlcCommsObject*)plcObj error:(NSError*)error ;

// El objecte PlcCommObject ha estat clausurat, i ja no fara mes intents de conexio 
- (void)finsDidClausure:(PlcCommsObject*)plcObj ;

@end




//------------------------------------------------------------------------------------------------
// Ordre de cridada dels metodes delegats
/*

(openWithPlcDevice)
finsSocketWillReach
|
|---finsSocketDidReach
|   |
|   |---finsSocketWillConnect
|   |   |
|   |   |---finsSocketDidConnect
|   |   |   |
|   |   |   |---finsDidLink
|   |   |   |   |
|   |   |   |   |   (addMonitoredTagElements) o (removeMonitoredTagElements)
|   |   |   |   |   | 
|   |   |   |   |   |---finsMonitoredTagsDidChange  -> (publish)
|   |   |   |   |   |    
|   |   |   |   |   |---finsDidReportIssue
|   |   |   |   |   |
|   |   |   |   |   |   (writeTagElementsInArray)
|   |   |   |   |   |   |
|   |   |   |   |   |   |---finsDidCompleteWrite
|   |   |   |   |   |   |   
|   |   |   |   |   |   |---finsDidReportIssue
|   |   |   |   |   |   |
|   |   |   |   |   |   |
|---|---|---|---|---|---|---finsErrorOcurred
        |---|---|---|---|---finsDidClose

*/











