//
//  SendMailController.m
//  ScadaMobile
//
//  Created by Joan on 28/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SendMailController.h"



///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark SendMailController
///////////////////////////////////////////////////////////////////////////////////////////

//-----------------------------------------------------------------------------------------
@implementation SendMailController

//-----------------------------------------------------------------------------------------
- (id)init
{
    self = [super init];
    if (self) 
    {
        // Custom initialization
        [self setMailComposeDelegate:self] ;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}


///////////////////////////////////////////////////////////////////////////////////////////
#pragma mark MFMailComposeViewControllerDelegate
///////////////////////////////////////////////////////////////////////////////////////////

//-----------------------------------------------------------------------------------------
// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{	
    NSString *text ;

	// Notifies users about errors associated with the interface
	switch (result)
	{
		case MFMailComposeResultCancelled:
			text = @"Result: canceled";
			break;
		case MFMailComposeResultSaved:
			text = @"Result: saved";
			break;
		case MFMailComposeResultSent:
			text = @"Result: sent";
			break;
		case MFMailComposeResultFailed:
			text = @"Result: failed";
			break;
		default:
			text = @"Result: not sent";
			break;
	}
    //NSLog( @"SendMailController Result :%@", text ) ;
    [self dismissViewControllerAnimated:YES completion:nil];
	//[self dismissModalViewControllerAnimated:YES];
}


@end
