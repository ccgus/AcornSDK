//
//  KernelrKontroler.h
//  Kernelr
//
//  Created by August Mueller on 10/10/07.
//  Copyright 2007 Flying Meat Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#import "ACPlugin.h"
#import "KView.h"

@interface KernelrKontroler : NSWindowController {
    IBOutlet KView *imageView;
    IBOutlet NSPathControl *pathControl;
    
    NSURL       *_filterPath;
    CIImage     *_inputImage;
    CIFilter    *_theFilter;
    CIKernel    *_theKernel;
    
    CIFilter    *_checkerFilter;
    
    FSEventStreamRef _eventsStream; 
    
    
    
    
}


@property (retain) NSURL *filterPath;
@property (retain) CIImage *inputImage;
@property (retain) CIFilter *theFilter;
@property (retain) CIKernel *theKernel;


- (void) updateImage;
- (void) updateInputImage;

- (IBAction)openKernelFile:(id)sender;

@end
