//
//  AppDelegate.h
//  AcornImageTest
//
//  Created by August Mueller on 4/17/09.
//  Copyright 2009 Flying Meat Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

enum {
    ACNS,
    ACCI,
    ACCG,
    ACPath
};

@interface AppDelegate : NSObject {
    IBOutlet NSImageView *imageView;
    
    id _currentAcornAgent;
    int _editCall;
}

@property (retain) id currentAcornAgent;

- (void) editNSInAcornAction:(id)sender;
- (void) editCIInAcornAction:(id)sender;
- (void) editCGInAcornAction:(id)sender;
- (void) editPathInAcornAction:(id)sender;
- (void) testBitmapImageRep:(id)sender;

@end
