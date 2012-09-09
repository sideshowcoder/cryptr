//
//  DragView.h
//  Cryptr
//
//  Created by Philipp Fehre on 5/21/09.
//  Copyright 2009 SideShowCoder.com. All rights reserved.
//
//	Handle drag an Drop

#import <Cocoa/Cocoa.h>


@interface DragView : NSView {
	IBOutlet NSTextField *fileNameTextField;
	IBOutlet NSButton *encryptButton;
	IBOutlet NSButton *decryptButton;
	NSString* filePath;
}

- (void)setFilePath:(NSString *)path;
- (NSString *)filePath;

@end
