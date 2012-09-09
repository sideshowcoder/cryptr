//
//  PreferencesController.h
//  Cryptr
//
//  Created by Philipp Fehre on 5/26/09.
//  Copyright 2009 SideShowCoder.com. All rights reserved.
//
//	Handle the Preferences

#import <Cocoa/Cocoa.h>

extern NSString * const CTRDeleteAfterEnc;
extern NSString * const CTRDeleteAfterDec;
extern NSString * const CTRShowInMenubar;

@interface PreferencesController : NSWindowController {
	IBOutlet NSButton *deleteSourceFileAfterEncCheckBox;
	IBOutlet NSButton *deleteSourceFileAfterDecCheckBox;
	IBOutlet NSButton *showInMenubarCheckBox;
}

- (NSNumber *) deleteSourceFileAfterDec;
- (IBAction) changeDeleteSourceFileAterDec:(id)sender;
- (NSNumber *) deleteSourceFileAfterEnc;
- (IBAction) changeDeleteSourceFileAterEnc:(id)sender;
- (NSNumber *) showInMenubar;
- (IBAction) changeShowInMenubar:(id)sender;

@end
