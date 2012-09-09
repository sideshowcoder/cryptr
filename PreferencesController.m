//
//  PreferencesController.m
//  Cryptr
//
//  Created by Philipp Fehre on 5/26/09.
//  Copyright 2009 SideShowCoder.com. All rights reserved.
//

#import "PreferencesController.h"

// Strings for the User defaults to use as Identifiers
NSString * const CTRDeleteAfterEnc = @"DeleteSourceAfterEncryption";
NSString * const CTRDeleteAfterDec = @"DeleteSourceAfterDecryption";
NSString * const CTRShowInMenubar = @"LaunchAsMenubarItem";

@implementation PreferencesController
- (id)init
{
	if(![super initWithWindowNibName:@"Preferences"]) {
		return nil;
	}
	return self;
}

- (void)windowDidLoad
{
	[deleteSourceFileAfterEncCheckBox setState:[[self deleteSourceFileAfterEnc] intValue]];
	[deleteSourceFileAfterDecCheckBox setState:[[self deleteSourceFileAfterDec] intValue]];
	[showInMenubarCheckBox setState:[[self showInMenubar] intValue]];
	
}

- (NSNumber *)deleteSourceFileAfterEnc
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	return [defaults objectForKey:CTRDeleteAfterEnc];
}


- (IBAction) changeDeleteSourceFileAterEnc:(id)sender
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:[NSNumber numberWithInt:[deleteSourceFileAfterEncCheckBox state]] forKey:CTRDeleteAfterEnc];
}

- (NSNumber *)deleteSourceFileAfterDec
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	return [defaults objectForKey:CTRDeleteAfterDec];
}


- (IBAction) changeDeleteSourceFileAterDec:(id)sender
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:[NSNumber numberWithInt:[deleteSourceFileAfterDecCheckBox state]] forKey:CTRDeleteAfterDec];
}


- (NSNumber *)showInMenubar
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	return [defaults objectForKey:CTRShowInMenubar];
}

- (IBAction) changeShowInMenubar:(id)sender
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:[NSNumber numberWithInt:[showInMenubarCheckBox state]] forKey:CTRShowInMenubar];
}

@end
