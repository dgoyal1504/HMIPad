//
//  SWTableFieldsController.m
//  HmiPad
//
//  Created by Joan on 24/04/09.
//  Copyright 2009 SweetWilliam, S.L.. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SWTableFieldsControllerDelegate ;

@class BubbleView ;

//----------------------------------------------------------------------------------
@interface SWCellWrapper: NSObject
{
    @public
    UITableViewCell *cell ;
    NSIndexPath *indexPath ;
    //int section ;
    //int row ;
}
@end


//////////////////////////////////////////////////////////////////////////////
#pragma mark SWTableFieldsController
//////////////////////////////////////////////////////////////////////////////

//----------------------------------------------------------------------------
// Aquesta clase permet controlar una serie de textFields de manera que l'usuari
// pot acceptar o descartar en bloc els canvis fets sobre aquests. La clase 
// s'inicialitza especificant un UIViewController (owner) que ha de respondre al
// protocol SWTableFieldsControllerDelegate,
// Quan s'envia startAnimated la clase proporciona un UISegmentedView
// i es prepara per fer el seguiment dels UITextFields que
// s'incorporin amb el missatge recordTextField (normalment els UItextField
// interessats enviaran el missatge des del seu textFieldDidBeginEditing metode 
// delegat.
// Es pot aturar programàticament el registre de UITextFields i la visualització
// del UISegmentView enviant stopWithCancel:animated, o automàticament quan 
// l'usuari toca el UISegmentView. En qualsevol d'aquests casos 
// la clase envia automàticament un resignFirstResponder a l'ultim TextField
// que s'ha registrat
// NOTA IMPORTANT: Atenció al fet de que si s'utilitza aquesta clase en combinacio
// amb TableViewCells que son reusats, la clase no te cap manera de saber si
// un UITextField esta essent reusat, i per tant el resultat de la acceptació
// o cancel-lació dels canvis pot tenir efectes imprevistos. Per solucionar aquest
// problema la clase incorpora el metode amendedCellFromCell:
// El métode amendedCellFromCell s'utilitza passant-li la celda que 
// ha tornat dequeueReusableCellWithIdentifier i
// torna una celda sense reusar que es apta per aquesta clase.

@interface SWTableFieldsController : NSObject 
{ 
    __weak id<SWTableFieldsControllerDelegate> _owner ; 
    UISegmentedControl* _backupControl ; // amagatzema el control de la dreta
    BubbleView *bubbleView ;
    UIView *bubbleViewView ;
    NSMutableArray *_textResponders ; // amagatzema la llista de textFields control-lats
    NSMutableArray *_textResponderTexts ; // amagatzema els valors inicials dels camps
    NSMutableArray *_textResponderErrors ; // amagatzema els textes d'error dels camps
    NSMutableArray *_cellWrappers ; // amagatzema parells de valors representant section i row
    
    BOOL _isStarted ;
}

//@property (nonatomic, readonly) id<NavigationButtonControllerDelegate,UITextFieldDelegate> owner;
@property (nonatomic, readonly, weak) id<SWTableFieldsControllerDelegate> owner;
@property (nonatomic, readonly) BOOL isStarted;
@property (nonatomic, readonly) UIResponder *currentTextResponder;  // amagatzema l'ultima celda per la qual s'ha enviat recordTextResponder
@property (nonatomic, readonly) UITableViewCell *currentResponderCell; // amagatzema l'ultima celda per la qual s'ha enviat recordTextResponde

// inicialitzacio
- (id)initWithOwner:(id<SWTableFieldsControllerDelegate>)theOwner;

// Torna els textFields que han sigut registrats. Es pot fer servir dintre dels
// metodes delegats
- (NSArray*)textResponders ;

// Torna els cellWrappers amb les celdes que han estat registrades
- (NSArray*)cellWrappers ;


// Un cop està engegat pot cridarse multiples vegades sense efecte
- (void)startAnimated:(BOOL)animated;

// Els textField repetits es registren com un de sol
// No te efecte si l'objecte no s'ha engegat amb startAnimated
- (void)recordTextResponder:(UIView*)textResponder;

// Torna la cell (o nil) que es superview de textResponder
- (UITableViewCell*)cellForTextResponder:(UIView*)textResponder;
- (UITableViewCell*)cellForIndexPath:(NSIndexPath*)indexPath;

// Torna el indexpath que es va registrar per textResponser
- (NSIndexPath*)indexPathforTextResponder:(UIView*)textResponder;

// Enviar aquest per aturar programàticament el registre de textFields
- (void)stopWithCancel:(BOOL)shouldCancel animated:(BOOL)animated;

// Els dos métodes a continuació proporcionen suport a textFiels que estan en
// celdes reusables
//- (void)recordTextResponder:(UIView*)textResponder inTableView:(UITableView*)tableView ;
//- (void)recordTableTextResponder:(UIView*)textResponder ;
//- (UITableViewCell*)dequeueRegisteredCellAtIndexPath:(NSIndexPath*)indexPath;
- (UITableViewCell*)amendedCellFromCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath;
//- (UITableViewCell*)dequeueCellAtIndexPath:(NSIndexPath*)indexPath ;

- (void)presentInfoMessage:(NSString*)msg fromView:(UIView*)view animated:(BOOL)animated;
- (void)dismisInfoMessageAnimated:(BOOL)animated;
- (void)resetIndicatorForField:(id)field animated:(BOOL)animated;

@end

