//
//  AICLAppDelegate.m
//  AcornImageChangeListener
//
//  Created by August Mueller on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AICLAppDelegate.h"
#import "ACImageUpdateListener.h"

@implementation AICLAppDelegate

@synthesize window = _window;
@synthesize imageView = _imageView;


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [[ACImageUpdateListener sharedListener] setDelegate:self];
    [[ACImageUpdateListener sharedListener] startListening];
}

- (void)listenerRecievedDataFromAcorn:(NSData*)data {
    NSLog(@"Updating image");
    NSImage *i = [[[NSImage alloc] initWithData:data] autorelease];
    [_imageView setImage:i];
}

@end
