//
//  PlcCommsObject.h
//  Domus
//
//  Created by Joan on 05/03/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"
#import "PlcObjectCommonTypes.h"

@class Queue ;
@class PlcCommsObject ;
@class GCDAsyncSocket ;
@class FinsRequest ;
@class GCDReachability ;
@class PlcTagElement ;
@class PlcProtocol ;
@class PlcDevice ;
@protocol PlcProtocolProtocol ;
@protocol CommsObjectDelegate ;



//------------------------------------------------------------------------------------------------
// Definició del tipus de punter a metode del delegat de PlcCommsObject

typedef void (*DelegateMethodIMP1)(id, SEL, PlcCommsObject* ) ;
typedef void (*DelegateMethodIMPB)(id, SEL, PlcCommsObject*, BOOL ) ;
typedef void (*DelegateMethodIMP2)(id, SEL, PlcCommsObject*, id ) ;
typedef void (*DelegateMethodIMP3)(id, SEL, PlcCommsObject*, id, id ) ;
typedef void (*DelegateMethodIMPP)(id, SEL, PlcCommsObject*, float, float ) ;
typedef void (*DelegateMethodIMPI)(id, SEL, PlcCommsObject*, int) ;
//typedef void (*DelegateMethodIMP4)(id, SEL, PlcCommsObject*, id, id ) ;

extern NSString *PlcCommsObjectErrorDomain ;

//------------------------------------------------------------------------------------------------
// Informacio general sobre la clase
//
// Clase per comunicacions amb un PLC utilitzant qualsevol dels protocols de comunicacio suportats
// El delegat pot implementar els metodes del protocol CommsObjectDelegate
// per a notificacions asincrones del proces d'establiment de la comunicació i transfència de dades.
//
// El procés de comunicació amb el PLC implica els passos següents. Les notificacions
// reflexen l'estat de cada pas. Els passos s'executen consecutivament pero de forma
// asincrona al reste de la aplicació. Es a dir, la majoria de metodes de PlcCommsObject 
// tornen inmediatament.
//
//    - identificacio de la reachabilitat
//    - creació del socket
//    - conexió del socket
//    - configuració inicial segons protocol
//    - dispatch de comandes (lectura/escritura)
//    - tancament del socket
//
// La clase notifica events al delegat de manera asíncrona a mida que es van produint. En el cas
// de lectures, el delegat es només informat dels canvis.
//

//------------------------------------------------------------------------------------------------
// Nota sobre la utilitzacio de PlcTagElements amb la clase
//
// La clase utilitza objectes del tipus PlcTagElement per obtenir, amagatzemar i notificar
// els resultats de la comunicacio. Els PlcTagElements es creen i es passen a la clase
// des d'un altre threat pero son manipulats dins del threat d'execucio de la clase.
// Es important respectar una serie de normes per evitar corrupcio de dades i altres
// problemes amb els PlcTagElements compartits. Els PlcTagElements no es poden
// manipular fora de la clase excepte de la manera establerta.
// La clase es completament Thread Safe si es respeten els criteris i patrons
// d'utilització descrits a continuacio:
//
// Les instancies de PlcTagElement que s'envien a la clase per processar, poden ser creades
// de manera unica i utilitzarse repetidament sempre i quan no es modifiquin des de un altre threat.
//
// Per llegir elements del PLC s'ha de registrar els PlcTagElements en una llista
// interna de tags per monitoritzar. Els tags es poden afegir o treure de la llista
// en qualsevol moment amb els metodes seguents.
// - addMonitoredTagElements
// - removeMonitoredTagElements
//
// El periode de mostreig es pot establir, canviar o aturar en qualsevol moment amb el metode seguent.
// Si el temps de mostreig es possitiu, la clase inicia el mostreig automaticament en el moment
// en que hi ha tags per monitoritzar, o es completa l'enllac amb un PLC
// - setPollInterval
//
// La clase notifica els canvis de valor en PlcTags amb el métode delegat seguent. 
// - finsMonitoredTagsDidChange
//
// La notificacio s'executa al menys una vegada per els tags que romanen registrats.
// Aixo pot passar quan s'afageigen per primera vegada, o quan s'inicia el 
// mostreig despres d'una conexio nova. Podem forçar la notificació d'un tag 
// en qualsevol moment si l'eliminem i el tornem a afegir.
// Si un tag ha estat eliminat avans de la seva notificacio de canvi, 
// no hi haura notificacio per aquest tag fins que es torni a afegir.
//
// Un cop es reb una notificació de canvi el mostreig queda aturat i es necesari 
// reactivarlo explicitament cridant el metode seguent.
// - publish
//
// En el interval entre la notificacio de canvi (finsMonitoredTagsDidChange) i la crida
// a publish es segur llegir les dades utilitzant els metodes de LECTURA de PlcTagElements 
// gestionats per la classe.
//
// Per escriure elements no cal registrar-los. Es pot fer en qualsevol moment de manera segura amb
// el seguent metode. 
// - writeTagElementsInArray
//
// La clase notifica de una escritura amb el metode delegat seguent.
// - finsDidCompleteWrite
//
// Els valors de escritura en PlcTagElements es poden establir amb els metodes 
// de ESCRITURA de PlcTagElement despres de rebre la notificacio (finsDidCompleteWrite)
// i abans de cridar writeTagElementsInArray, o be en qualsevol moment
// amb els metodes de ESCRITURA d'aquesta clase







//------------------------------------------------------------------------------------------------
@interface PlcCommsObject : NSObject<GCDAsyncSocketDelegate>
{ 
    GCDAsyncSocket *asyncSocket ;
    GCDReachability *reachability ;
    
    Queue *commandQueue ;
    id contextObject ;
    id requestContext ;
    
    int connection_step ;
    int connection_steps ;
    
    PlcDevice *plcDevice ;
    
    UInt8 sdi ;
    BOOL is_starting ;
    BOOL no_local ;
    BOOL no_remote ;
    BOOL is_linked ;
    BOOL is_ready ;
    BOOL is_polling ;
    BOOL is_pushing ;
    BOOL should_register ;
    BOOL monitored_changed ;
    //BOOL publish_pending ;
    BOOL polling_fired ;
    
    uint64_t pollingInterval ;
    uint64_t nextPollingInterval ;
    dispatch_source_t pollingTimer ;
    dispatch_time_t lastPollingTime ;
    dispatch_source_t reOpenTimer ;
    dispatch_source_t reachabilityTimer ;
    
    __weak id<CommsObjectDelegate> delegate ; //weak
	dispatch_queue_t delegateDispatch ;
    
    dispatch_block_t writeBlock ;
    
    DelegateMethodIMP1 finsSocketWillReach ;
    DelegateMethodIMP1 finsSocketDidReach ;
    DelegateMethodIMP1 finsSocketWillConnect ;
    DelegateMethodIMP1 finsSocketDidConnect ;
    DelegateMethodIMP1 finsDidClose ;
    DelegateMethodIMP1 finsDidClausure ;
    //DelegateMethodIMP1 finsShouldExecutePoll  ;
    DelegateMethodIMPB finsDidLink ;
    //DelegateMethodIMP2 finsDidReceiveData ;
    //DelegateMethodIMP2 finsDidCompleteCommand ;
    DelegateMethodIMP2 finsErrorOcurred ;
    DelegateMethodIMP2 finsDidReportIssue ;
    DelegateMethodIMP3 finsMonitoredTagsDidChange ;
    //DelegateMethodIMP3 finsDidCompleteRead ;
    DelegateMethodIMP3 finsDidCompleteWrite ;
    DelegateMethodIMPP finsPollingProgress ;
    DelegateMethodIMPI finsPollingTagsCount ;
    
    NSTimeInterval connectTimeout ;
    NSTimeInterval readTimeout ;
    NSTimeInterval writeTimeout ;
    NSTimeInterval reconnectTime ;
    int commandCount ;
    int readCount ;
    //CFAbsoluteTime lastCommandTime ;
    NSTimeInterval readTime ;
    CFAbsoluteTime lastReadTime ;
    
    Class protocolClass ;
    PlcProtocol<PlcProtocolProtocol> *protocol ;
    //NSArray *readElements ;  // tags en el cicle de monitoritzacio actual
    
    NSMutableArray *requests ;  // requests optimitzats per els tags monitoritzats
    //NSCountedSet *tagsSet ;  // tags monitoritzats
    CFMutableArrayRef tagsSetArray ;
    NSArray *writeElements ; // tags en el cicle de escritura actual
    
	//dispatch_queue_t mainDispatch ;
    dispatch_queue_t commandsDispatch ;
}

//-------------------------------------------------------------------------------------- 
#pragma mark INICIALITZACIO, Metodes i propietats per inicialitzar la classe
// Els seguents metodes i propietats inicialitzen les instancies i s'han cridar 
// avans de començar a utilitzar l'objecte.

// Metodes per especificar el delegat
- (void)setDelegate:(id<CommsObjectDelegate>)object ; // aumeix dispatch_get_main_queue()
- (void)setDelegate:(id<CommsObjectDelegate>)object delegateQueue:(dispatch_queue_t)dispatchQ ;

// Metode per especificar els timeouts si no volem els de defecte
- (void)setTimeoutsForConnect:(NSTimeInterval)connectT read:(NSTimeInterval)readT write:(NSTimeInterval)writeT reconnect:(NSTimeInterval)reconnectT ;

// Obra l'objecte per comunicació intentant una conexió al PlcDevice especificat.
// Atenció, device ha de ser considerat inmutable o no canviar mentre la clase esta en funcionament.
- (BOOL)openWithPlcDevice:(PlcDevice *)device contextObj:(id)contextObj ;


//-------------------------------------------------------------------------------------- 
#pragma mark FINALITZACIO

// Tanca la comunicació amb el PLC pero no allibera l'objecte, ni elimina els delegats, ni els
// elements monitoritzats que pugui tenir. El objecte queda clausurat i no fa mes intents.
// Es pot cridar en qualsevol moment des de qualsevol thread.
- (void)close ;


//-------------------------------------------------------------------------------------- 
#pragma mark PROPIETATS, Access a propietats i d'altres

// Els seguents metodes es segur cridarlos en qualsevol moment des de qualsevol thread
// poden tenir un cert overhead degut a sincronisme del thread d'execucio de la clase

// Torna el objecte de contexte associat a l'objecte.
- (id)contextObject ;
 
// Torna una NSString representant el host:port al que s'ha conectat
// a partir del AsyncSocket   
- (NSString *)connectedHost ;

// Torna una NSString representant el host:port al que s'esta conectant 
// agafant directament la informacio de plcDevice
- (NSString *)connectingHost ;


//-------------------------------------------------------------------------------------- 
#pragma mark LECTURA, Es segur cridar aquests metodes en qualsevol moment

// Metode per especificar el temps de polling. Atura el polling si passem un valor negatiu
- (void)setPollInterval:(CFTimeInterval)interval ;

// Afageig o treu tags per monitoritzacio de lectura. Es segur cridar aquests metodes en qualsevol moment.
// Els canvis queden notificats per finsMonitoredTagsDidChange
//- (void)addMonitoredTagElements:(NSArray*)elements contextObj:(id)context ;
//- (void)removeMonitoredTagElements:(NSArray*)elements ;  // si pasem nil s'esborra tot, si passem un array vuit no fa res
- (void)restoreMonitoredTagElementsByAdding:(NSArray*)addElements removing:(NSArray*)removeElements contextObj:(id)context ;
- (void)removeAllMonitoredTagElements ;

// Atencio que els tags afegits o eliminats continuen essent vigents despres de desconexions, errors
// de comunicacio etc. Si hi ha tags registrats en el moment de enllacar amb un PLC, la
// clase els notificara al menys una vegada amb finsMonitoredTagsDidChange.

//-------------------------------------------------------------------------------------- 
#pragma mark CONTINUACIO LECTURA

// Metode a cridar per continuar el polling despres de rebre finsDidCompleteRead.
// Els metodes de LECTURA de PlcTagElemens s'han de utilitzar abans de cridar publish
- (void)publish ;

// El mostreig s'inicia automaticament quan hi ha tags per monitoritzar i el objecte esta enllacat.
// El mostreig s'atura si no hi ha tags per monitoritzar o el interval de mostreig es negatiu.


//-------------------------------------------------------------------------------------- 
#pragma mark ESCRITURA, Es segur cridar aquests metodes en qualsevol moment

// Estableixen valors d'enginyeria per un PlcTagElement abans d'executar una escritura
- (void)setEngWValue:(double)newValue atIndex:(int)indx forTagElement:(PlcTagElement*)element ;
- (void)setEngWValues:(CFDataRef)newValues maxCount:(int)count forTagElement:(PlcTagElement*)element ;
- (void)setEngWString:(CFStringRef)str encoding:(CFStringEncoding)encoding atIndex:(int)indx forTagElement:(PlcTagElement*)element ;
- (void)setEngWStrings:(CFArrayRef)texts encoding:(CFStringEncoding)encoding maxCount:(int)count forTagElement:(PlcTagElement*)element ;

// Executa una escritura multiple de PlcTagElements, La operacio completada queda notificada per finsDidCompleteWrite
// 
- (void)writeTagElementsInArray:(NSArray*)elements contextObj:(id)obj ;

// NOTA (INTERNA)
// En el cas de arrays de un element de tipus escalar, i nomes en aquest cas, 
// la clase copia el valor de escritura en el request que es fa servir per escriure, 
// (a writeTagElementsInArray). Els protocols utilitzen aquest valor per formar la trama d'escritura
// (utilitzant rawWValueAtIndex:forElement: del request). Aixo elimina el risc de que el valor del tag
// sigui canviat avans de crear la trama i resulti en repeticions de escritures amb l'ultim valor, en
// lloc de escritures de valors diferents.
// Una millora de la clase seria copiar sistematicament els valors de escritura en els requests i
// utilitzar sempre aquests en lloc dels del PlcTagElements.
// Per implementar aixo es pot definir un objecte
// PlcTagEnvelop que contingui un PlcTagElement i unes dades de escritura TagRawValue. Al copiar es pot
// pasar el ownership del TagRawValue al PlcTagEnvelop i alliberar el del PlcTagElement
// els PlcTag.
// Alternativament (millor) el request pot incorporar un objecte similar al plcElementStore per amagatzemar
// TagRawValues encapsulades en objectes PlcTagWValue (ex). Es pot simplement passar el ownership del
// PlcTagElement al PlcTagWValue a la creacio del request d'escritura, i tornar aquest en el rawWValueAtIndex



@end



//---------------------------------------------------------------------------
@interface PlcCommsObject(PlcProtocolInterface)

- (void)processRequest:(FinsRequest*)request ;
- (void)scheduleCommandWithKind:(RequestCode)kind contextObj:(id)obj plcTagElement:(id)plcTag isPartial:(BOOL)partial context:(const void*)ctx;

- (BOOL)validateTag:(PlcTagElement*)plcTag outErrorMsg:(NSString **)outErrMsg ;
- (PlcTagElement*)validationTag ;
- (PlcDevice*)plcDevice ;
- (id)contextObject ;

@end


//---------------------------------------------------------------------------
@interface PlcCommsObject(TagsSetInterface)

- (NSArray *)tagsSetArray ;

@end



/*
//---------------------------------------------------------------------------
@interface PlcCommsObject(PlcTagElement)

- (dispatch_queue_t)commandsDispatch ;

@end
*/


