//
//  SWQuickDocument.h
//  HmiPad
//
//  Created by Lluch Joan on 16/07/12.
//  Copyright (c) 2012 SweetWilliam, SL. All rights reserved.
//

#import <Foundation/Foundation.h>

// Clase que proporciona una interface similar a UIDocument que implementa un subconjunt de la funcionalitat de UIDocument
// La Utilitzacío en general es igual que UIDocument amb les seguents prestacions i diferencies:
//
// Prestacions similars a UIDocument suportades:
//
// - Escritura asincrona.
// - Undo Manager
// - Escritura segura a un fitxer temporal abans de remplaçar el existent.
// - Guardat asincrono automatic (basat en les notificacions el undo manager).
// - Suport per NSFileWrapper
//
// Diferencies i altres prestacions:
//
// - Suportada qualsevol combinacio de tipus de arxiu per load/save/close sense destruccio.
// (El suport de tipus de UIDocument es destructiu, un cop es guarda en un tipus el fitxer anterior es destrueix)
// - Es permet obrir, guardar i tancar el document en diferents formats (i extensions), sense sobreescriure'ls.
// - Incorpora un metode adicional openFromURL per obrir desde un lloc o format diferent del de inicialitzacio.
// - La clase incorpora el override fileTypeForURL que ha de tornar el fileType a partir de un URL
// - La clase crida savingFileType per operacions de escritura (save, close), i guardat automatic basat en undo.
// - La clase crida fileTypeForURL per operacions de lectura (open).
// - La implementacio per defecte de savingFileType es cridar fileTypeForURL.
// - El metode fileType de UIDocument no esta suportat
// - La clase assumeix que el fileType te una estructura del tipus "xx.extensio". (exemple "com.sweetwilliam.hmipad.smb")
// - El ultim component del fileType s'asummeix que es una extensio valida per a confeccionar el path del arxiu del tipus referit.
// - El path de escritura i lectura es confecciona en base a la propietat fileURL (open, close) o be el argument url (save) 
// substituint la extensio si fileType esta disponible.
// - La operacio save es asincrona pero les operacions open i close son sincrones.
//
// Informacio adicional
//
// * La idea principal de la clase es que es pot utilitzar per suportar diferents clases de documents guardats en diferents llocs
// o a dins d'un fiewrapper sense destruccio dels altres.
//
// * La clase mante contadors de canvis per cada tipus de arxiu i fa un guardat inteligent, evitant guardats innecesaris per cada
// tipus de arxiu. Els metodes publics permeten obrir documents de qualsevol tipus, i guardarlos en el format tornat per savingFileType
// o el que s'especifica al cridar els metodes de guardar. Per guardat inteligent s'enten que si un document no ha sofert
// canvis les crides per salvar no tenen efecte.
//
// * Si un document no ha estat obert o guardat mai en un tipus determinat, la clase no en te nocio excepte si aquest tipus
// esta present en el array tornat per savingFileTypes. El comportament de saveToURL en casos de tipus no coneguts
// es el de guardar nomes si hi ha hagut canvis en al menys algun altre tipus, i de no fer res en cas contrari.
// La clase tambe incorpora el metode setHasUnsavedChangesForType que afageix explicitament un tipus per control de canvis.
//
// * El guardat automatic es realitza en la url subministrada a la inicialitzacio i amb el tipus tornat per savingFileType, per tant es
// important que aquest metode sempre retorni el tipus desitjat per els guardats automatics. Es poden guardar varis arxius a la vegada
// incorporant el numero de claus necesaries al NSFileWrapper tornat per contentsForType.
//
// * El suport per NSFileWrapper coincideix amb el de UIDocument excepte en que no es destructiu. Es a dir nomes se sobreescriuen els subwrappers
// que tenen una clau a la propietat fileWrappers del NSFileWrapper retornat per contentsForType. Aixo posibilita el control total del que
// es guarda i posibilita el guardat d'alguns arxius sense afectar la resta.


@interface SWQuickDocument : NSObject
{
}

@property(readonly) NSURL *fileURL;
@property(readonly, copy) NSString *localizedName;
@property(retain) NSUndoManager *undoManager;

@property(readonly) UIDocumentState documentState;

// inicialitzacio
- (id)initWithFileURL:(NSURL *)url;

// Set an external serial dispatch queue just after initialization to handle all the asynchronous operations,
// the queue must have a context data already set with the dispatch_queue_set_specific, you must provide the key.
- (void)setDispatchQueue:(dispatch_queue_t)cQueue key:(const char *)key;

// obrir
- (void)openWithCompletionHandler:(void (^)(BOOL success))completionHandler;

// guardar/tancar amb tots els tipus registrats
- (void)saveForSaveOperation:(UIDocumentSaveOperation)saveOperation completionHandler:(void (^)(BOOL success))completionHandler;
- (void)closeWithCompletionHandler:(void (^)(BOOL success))completionHandler;

// guardar/tancar amb un fileType determinat
- (void)saveToURL:(NSURL *)url withType:(NSString*)fileType
    forSaveOperation:(UIDocumentSaveOperation)saveOperation completionHandler:(void (^)(BOOL success))completionHandler;
- (void)closeWithType:(NSString*)fileType completionHandler:(void (^)(BOOL success))completionHandler;

// registrar un tipus
- (void)setHasUnsavedChangesForType:(NSString*)fileType;

// forzar la necesitat de guardar
- (void)updateChangeCount;

// overrides per el contingut
- (id)contentsForType:(NSString *)typeName error:(NSError *__autoreleasing *)outError;
- (BOOL)loadFromContents:(id)contents ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError;

// overrides per el fileType
- (NSArray*)savingFileTypes;
- (NSString*)savingFileType;
- (NSString*)fileTypeForURL:(NSURL*)url;

// override per errors
- (void)handleError:(NSError *)error userInteractionPermitted:(BOOL)userInteractionPermitted;

// override per detectar canvi
- (void)changeCheckpointNotification;

// override per detectar save
- (void)saveCheckPointForType:(NSString*)fileType;

@end
