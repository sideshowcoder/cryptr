//
//  AppController.h
//  Cryptr
//
//  Created by Philipp Fehre on 5/21/09.
//  Copyright 2009 SideShowCoder.com. All rights reserved.
//
//	Create a Drag an Drop way to Encrypt files 

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>
#import <SSCrypto/SSCrypto.h>
#import <Growl/Growl.h>

@class DragView;
@class PreferencesController;

@interface AppController : NSObject <GrowlApplicationBridgeDelegate> {
	PreferencesController *preferencesController;
	NSStatusItem *statusItem;
	IBOutlet NSMenu *statusItemMenu;
	IBOutlet NSProgressIndicator *operationIndicator;
	IBOutlet NSSecureTextField *passphraseInput;
	IBOutlet NSWindow *mainWindow;
	IBOutlet DragView *dragView;
	NSMutableString *srcPath;
	NSMutableString *destPath;
	SSCrypto *crypto;
}

- (IBAction) showPreferencesPanel:(id)sender;
- (IBAction) encryptFile:(id)sender;
- (IBAction) decryptFile:(id)sender; 
- (IBAction) openFile:(id)sender;
- (void) buildSrcAndDestPathEncryption;
- (void) buildSrcAndDestPathDecryption;

@property (readwrite, retain) NSMutableString *srcPath;
@property (readwrite, retain) NSMutableString *destPath;

@end
