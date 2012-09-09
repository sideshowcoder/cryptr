//
//  DragView.m
//  Cryptr
//
//  Created by Philipp Fehre on 5/21/09.
//  Copyright 2009 SideShowCoder.com. All rights reserved.
//

#import "DragView.h"


@implementation DragView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		[self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
    }
    return self;
}

- (void)drawRect:(NSRect)rect {
	
}

- (void)dealloc
{
	[self unregisterDraggedTypes];
	[super dealloc];
}

#pragma mark Drag'n'Drop 

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    if ((NSDragOperationGeneric & [sender draggingSourceOperationMask]) 
		== NSDragOperationGeneric)
    {
        return NSDragOperationGeneric;
    }
    else
    {
        return NSDragOperationNone;
    }
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
    return YES;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
	NSPasteboard *paste = [sender draggingPasteboard];
	NSArray *types = [NSArray arrayWithObjects:NSFilenamesPboardType, nil];
	NSString *desiredTypes = [paste availableTypeFromArray:types];
	NSData *carriedData = [paste dataForType:desiredTypes];
	
	if (nil == carriedData)
    {
        NSRunAlertPanel(@"Paste Error", @"Past operation failed for unknown reason", 
						nil, nil, nil);
        return NO;
    }
	else {
		if( [desiredTypes isEqualToString:NSFilenamesPboardType] )
		{
            NSArray *fileArray = [paste propertyListForType:@"NSFilenamesPboardType"];
			
			//get the first path from the list since we only support one file anyway
            NSString *path = [fileArray objectAtIndex:0];
			//Check if Dragged path is a Directory if so don't accept
			NSFileManager *fileManager = [NSFileManager defaultManager];
			BOOL isDir;
			[fileManager fileExistsAtPath:path isDirectory:&isDir];
			if ( isDir )
			{
				NSRunAlertPanel(@"Paste Error", @"Only single files are supported, sorry", 
								nil, nil, nil);
				return NO;
			}
			else {
				[self setFilePath:path];
			}
		}
		else
        {
            //this should never happen
            NSAssert(NO, @"This should never happen");
            return NO;
        }
	}
	return YES;
}

- (void)setFilePath:(NSString *)path
{
	[filePath autorelease];
	filePath = [path retain];
	[fileNameTextField setStringValue:[[filePath pathComponents] lastObject]];
	if ([[filePath pathExtension] isEqualToString:@"cryptr"]) {
		[encryptButton setEnabled:NO];
		[decryptButton setEnabled:YES];
	} else {
		[encryptButton setEnabled:YES];
		[decryptButton setEnabled:NO];
	}
	
}

- (NSString *)filePath
{
	return filePath;
}

@end
