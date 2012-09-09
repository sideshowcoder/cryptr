//
//  AppController.m
//  Cryptr
//
//  Created by Philipp Fehre on 5/21/09.
//  Copyright 2009 SideShowCoder.com. All rights reserved.
//

#import "AppController.h"
#import "DragView.h"
#import "PreferencesController.h"

@implementation AppController

#pragma mark Initilize
+ (void)initilize
{
	//create dictionary for defaults
	NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
	
	//set defaults
	NSNumber * defaultDeleteSetting = [NSNumber numberWithInt:NSOffState];
	[defaults setObject:defaultDeleteSetting forKey:CTRDeleteAfterEnc];
	NSNumber * defaultShowInMenuSetting = [NSNumber numberWithInt:NSOffState];
	[defaults setObject:defaultShowInMenuSetting forKey:CTRShowInMenubar];	
	NSNumber * defaultDeleteAfterDecSetting = [NSNumber numberWithInt:NSOffState];
	[defaults setObject:defaultDeleteAfterDecSetting forKey:CTRDeleteAfterDec];	
	//register defaults as defaults dictionary
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

-(void)awakeFromNib 
{
	// making myself the Growl Delegate
	[GrowlApplicationBridge setGrowlDelegate:self];
	
	// get the User defaults to check if to run as Menubar or Dock App, start with Menubar and go to 
	// Dock if needed (simpler this way)
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if(![[defaults objectForKey:CTRShowInMenubar] isEqualToNumber:[NSNumber numberWithInt:NSOnState]]){
		// get the Process Number so it can be referenced
		ProcessSerialNumber psn = { 0, kCurrentProcess };
		// display dock icon if foreground app
		TransformProcessType(&psn, kProcessTransformToForegroundApplication);
		// enable menu bar with Name, File and so on
		SetSystemUIMode(kUIModeNormal, 0);
		// switch to Dock.app and back, to regain full Window Controll, this is a Bug not a Feature!
		[[NSWorkspace sharedWorkspace] launchAppWithBundleIdentifier:@"com.apple.dock" options:NSWorkspaceLaunchDefault additionalEventParamDescriptor:nil launchIdentifier:nil];
		[[NSApplication sharedApplication] activateIgnoringOtherApps:TRUE];
	}
	else {
		// run as menubar otherwise by setting Statusbar Icon, Name etc.
		statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength] retain];
		[statusItem setHighlightMode:YES];
		[statusItem setImage:[NSImage imageNamed:@"cryptrmenubar"]];
		[statusItem setMenu:statusItemMenu];
		[statusItem setToolTip:@"Cryptr"];		
	}
}


#pragma mark Attributes
@synthesize srcPath;
@synthesize destPath;

#pragma mark WindowControl
- (IBAction)showPreferencesPanel:(id)sender
{
	if(!preferencesController) {
		preferencesController = [[PreferencesController alloc] init];
	}
	[preferencesController showWindow:self];
}


// Handle files dragged on Dock Icon
- (BOOL)application:(NSApplication *)sender openFile:(NSString *)path
{
	[mainWindow makeKeyAndOrderFront:nil];
	[dragView setFilePath:path];
	return YES;
}

//handle reopen by clicking on Dock
- (BOOL)applicationShouldHandleReopen:(NSApplication *) theApplication hasVisibleWindows:(BOOL)flag
{
	if (!flag) {
		[mainWindow makeKeyAndOrderFront:nil];
	}
	return YES;
}

//handle open Menu
- (IBAction)openFile:(id)sender
{
	//create a open panel to select a File
	NSOpenPanel *panel = [NSOpenPanel openPanel];
	[panel beginSheetForDirectory:nil 
							 file:nil 
							types:nil
				   modalForWindow:mainWindow 
					modalDelegate:self
				   didEndSelector:@selector(openPanelDidEnd:returnCode:contextInfo:) 
					  contextInfo:NULL];
}

- (void)openPanelDidEnd:(NSOpenPanel *)openPanel 
			 returnCode:(int)returnCode
			contextInfo:(void *)conetext
{
	if (returnCode == NSOKButton) {
		NSString *path = [openPanel filename];
		[dragView setFilePath:path];
	}
}

#pragma mark Growl
// register for Growl Notifications
- (NSDictionary *) registrationDictionaryForGrowl
{
    NSArray *notifications;
	NSArray *notificationsdefault;
	
    notifications = [NSArray arrayWithObjects: @"CTEncryption started", @"CTDecryption started", @"CTEncryption finished", @"CTDecryption finished", nil];
	//Make only the Finish Notifications default appear, because the User knows what he/she started
	notificationsdefault = [NSArray arrayWithObjects: @"CTEncryption finished", @"CTDecryption finished", nil];
	
    NSDictionary *dict;
    dict = [NSDictionary dictionaryWithObjectsAndKeys:
			notifications, GROWL_NOTIFICATIONS_ALL,
			notificationsdefault, GROWL_NOTIFICATIONS_DEFAULT, nil];
    return dict;
}

// Open a finder window where the file is selected
- (void)growlNotificationWasClicked:(id)clickContext {
	[[NSWorkspace sharedWorkspace] selectFile:clickContext inFileViewerRootedAtPath:clickContext];
}


#pragma mark HelperMethods
- (void)buildSrcAndDestPathEncryption
{
	[self setSrcPath:[[dragView filePath] mutableCopy]];
	[self setDestPath:[[dragView filePath] mutableCopy]];
	[[self destPath] appendString:@".cryptr"];
}

- (void)buildSrcAndDestPathDecryption
{
	[self setSrcPath:[[dragView filePath] mutableCopy]];
	[self setDestPath:[[[dragView filePath] stringByDeletingPathExtension] mutableCopy]];
}

#pragma mark Encrypt		

- (IBAction) encryptFile:(id)sender 
{
	[operationIndicator startAnimation:nil];
	[self buildSrcAndDestPathEncryption];
		
	// Don't encrypt if Password is Empty
	if([[passphraseInput stringValue] isEqualToString:@""]) {
		NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"ENCERR", @"EncErr")
										 defaultButton:NSLocalizedString(@"OK", @"Ok")
									   alternateButton:nil 
										   otherButton:nil 
							 informativeTextWithFormat:NSLocalizedString(@"NOPASSWD", @"NoPass")];
		[alert beginSheetModalForWindow:mainWindow 
						  modalDelegate:self 
						 didEndSelector:nil
							contextInfo:NULL];
		
		[operationIndicator stopAnimation:nil];
		return;
	}

	// Growl that encryption started
	[GrowlApplicationBridge notifyWithTitle:@"Cryptr encryption"
								description:[NSString stringWithFormat:@"Encryption for %@ started", [[srcPath pathComponents] lastObject]]
						   notificationName:@"CTEncryption started"
								   iconData:nil
								   priority:0
								   isSticky:NO
							   clickContext:srcPath]; 
	
	// Get the crypto engine running and encrypt
	crypto = [[SSCrypto alloc] 
			  initWithSymmetricKey:[[passphraseInput stringValue] 
									dataUsingEncoding:NSASCIIStringEncoding]];
	[crypto setClearTextWithData:[NSData dataWithContentsOfFile:[self srcPath]]];
	NSData *encData = [crypto encrypt];
	[encData writeToFile:[self destPath] atomically:NO];
	[dragView setFilePath:[self destPath]];
	[crypto release];
	
	// Check if user wants the Source to be deleted afterwards
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if([[defaults objectForKey:CTRDeleteAfterEnc] isEqualToNumber:[NSNumber numberWithInt:NSOnState]]){
		NSFileManager *fileManager = [NSFileManager defaultManager];
		NSError *error = nil;
		[fileManager removeItemAtPath:srcPath error:&error];
		if(error){
			[NSApp presentError:error];
			[operationIndicator stopAnimation:nil];
			return;
		}
	}

	// Growl that encryption ended
	[GrowlApplicationBridge notifyWithTitle:@"Cryptr encryption"
								description:[NSString stringWithFormat:@"Encryption for %@ finished", [[destPath pathComponents] lastObject]]
						   notificationName:@"CTEncryption finished"
								   iconData:nil
								   priority:0
								   isSticky:NO
							   clickContext:destPath]; 
	
	[operationIndicator stopAnimation:nil];
}
	
#pragma mark Decrypt 

- (IBAction) decryptFile:(id)sender
{
	[operationIndicator startAnimation:nil];

	// Check file Type
	if ([[[dragView filePath] pathExtension] isNotEqualTo:@"cryptr"] ) {
		NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"DECERR", @"DecErr")
										 defaultButton:NSLocalizedString(@"OK", @"Ok") 
									   alternateButton:nil 
										   otherButton:nil 
							 informativeTextWithFormat:NSLocalizedString(@"WRONGFILETYP", @"WrongFile")];
		[alert beginSheetModalForWindow:mainWindow 
						  modalDelegate:self 
						 didEndSelector:nil 
							contextInfo:NULL];
		[operationIndicator stopAnimation:nil];
		return;
	}
	
	[self buildSrcAndDestPathDecryption];	

	// Growl that decryption started
	[GrowlApplicationBridge notifyWithTitle:@"Cryptr decryption"
								description:[NSString stringWithFormat:@"Decryption for %@ started", [[srcPath pathComponents] lastObject]]
						   notificationName:@"CTDecryption started"
								   iconData:nil
								   priority:0
								   isSticky:NO
							   clickContext:srcPath]; 
	
	
	// Get Crypto Engine running
	crypto = [[SSCrypto alloc] 
				initWithSymmetricKey:[[passphraseInput stringValue] 
									dataUsingEncoding:NSASCIIStringEncoding]];
	[crypto setCipherText:[NSData dataWithContentsOfFile:[self srcPath]]];
	NSData *decData = [crypto decrypt];

	// Check for Decryption Error, if no error write Data to file
	if (!decData) {
		NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"DECERR", @"DecErr")
											defaultButton:NSLocalizedString(@"OK", @"Ok")
										alternateButton:nil 
											otherButton:nil 
							 informativeTextWithFormat:NSLocalizedString(@"WRONGPASSWD", @"WrongPass")];
		[alert beginSheetModalForWindow:mainWindow 
						  modalDelegate:self 
						 didEndSelector:nil 
							contextInfo:NULL];
		[operationIndicator stopAnimation:nil];
		[crypto release];
		return;
	} else {
		[decData writeToFile:[self destPath] atomically:NO];			
		[crypto release];
	}

	// Delete Source if User wants it, Error checking happend allready
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if([[defaults objectForKey:CTRDeleteAfterDec] isEqualToNumber:[NSNumber numberWithInt:NSOnState]]){
		NSFileManager *fileManager = [NSFileManager defaultManager];
		NSError *error = nil;
		[fileManager removeItemAtPath:srcPath error:&error];
		if(error){
			[NSApp presentError:error];
			return;
		}
	}		
	[dragView setFilePath:[self destPath]];
	
	// Growl that decryption ended
	[GrowlApplicationBridge notifyWithTitle:@"Cryptr decryption"
								description:[NSString stringWithFormat:@"Decryption for %@ finished", [[destPath pathComponents] lastObject]]
						   notificationName:@"CTDecryption finished"
								   iconData:nil
								   priority:0
								   isSticky:NO
							   clickContext:destPath]; 
	
	[operationIndicator stopAnimation:nil];
}

@end
