//
//  AFUAppDelegate.h
//  AcornFileUpdate
//
//  Created by August Mueller on 3/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AFUAppDelegate : NSObject <NSApplicationDelegate> {
    dispatch_source_t _watcherSource;
    BOOL _updateScheduled;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSImageView *imageView;

@end
