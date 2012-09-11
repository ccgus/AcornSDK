//
//  AppDelegate.m
//  AcornImageTest
//
//  Created by August Mueller on 4/17/09.
//  Copyright 2009 Flying Meat Inc. All rights reserved.
//

#import "AppDelegate.h"
#import <AcornImage/AcornImage.h>

@implementation AppDelegate
@synthesize currentAcornAgent=_currentAcornAgent;

- (void) awakeFromNib {
    
    [imageView setImage:[NSImage imageNamed:@"aduck.jpg"]];
    
}

- (CGImageRef) createCGImageRefFromImage {
    
    CGImageSourceRef imageSourceRef = CGImageSourceCreateWithData((CFDataRef)[[imageView image] TIFFRepresentation], nil);
    CGImageRef imageRef             = CGImageSourceCreateImageAtIndex(imageSourceRef, 0, nil);
    
    CFRelease(imageSourceRef);
    
    return imageRef;
}

- (void) editCIInAcornAction:(id)sender {
    
    CGImageRef imgRef = [self createCGImageRefFromImage];
    CIImage *img = [CIImage imageWithCGImage:imgRef];
    CGImageRelease(imgRef);
    
    _editCall = ACCI;
    self.currentAcornAgent = [ACImageAgent editCIImageInAcorn:img fileNameHint:@"From CI Image" withDelegate:self];
}

- (void) editCGInAcornAction:(id)sender {
    
    CGImageRef imgRef = [self createCGImageRefFromImage];
    
    _editCall = ACCG;
    self.currentAcornAgent = [ACImageAgent editCGImageInAcorn:imgRef fileNameHint:@"From CG Image" withDelegate:self];
    
    CGImageRelease(imgRef);
    
}

- (void) editPathInAcornAction:(id)sender {
    
    NSString *duckPath = [[NSBundle mainBundle] pathForImageResource:@"aduck.jpg"];
    NSURL *duckURL     = [NSURL fileURLWithPath:duckPath];
    
    // yes, we are going to DESTROY our little duck.  For all time.  Or at least until we rebuild the app.
    self.currentAcornAgent = [ACImageAgent editImageAtURL:duckURL withDelegate:self];
    
    _editCall = ACPath;
}

- (void) editNSInAcornAction:(id)sender {
    _editCall = ACNS;
    self.currentAcornAgent = [ACImageAgent editNSImageInAcorn:[imageView image] fileNameHint:@"From NS Image" withDelegate:self];
}



- (void) acornImageDidUpdate:(ACImageAgent*)agent {
    
    NSImage *img = 0x00;
    
    // we're just demonstrating (and testing) the different ways to get images out of an acorn agent
    
    if (_editCall == ACNS) {
        img = [agent NSImage];
    }
    else if (_editCall == ACCI) {
        
        CIImage *ciimg = [agent CIImage];
        
        NSBitmapImageRep *ir = [NSCIImageRep imageRepWithCIImage:ciimg];
        img = [[[NSImage alloc] initWithSize:NSMakeSize([ir pixelsWide], [ir pixelsHigh])] autorelease];
        
        [img addRepresentation:ir];
    }
    else if (_editCall == ACCG) {
        CGImageRef cgimg = [agent createCGImage];
        
        NSBitmapImageRep *ir = [[[NSBitmapImageRep alloc] initWithCGImage:cgimg] autorelease];
        img = [[[NSImage alloc] initWithSize:NSMakeSize([ir pixelsWide], [ir pixelsHigh])] autorelease];
        
        [img addRepresentation:ir];
        
        CGImageRelease(cgimg);
    }
    else if (_editCall == ACPath) {
        img = [[[NSImage alloc] initByReferencingFile:[agent imagePath]] autorelease];
    }
    
    if (img) {
        [imageView setImage:img];
    }
    else {
        NSRunAlertPanel(@"Image pull failed", @"whoops.", @"OK", nil, nil);
    }
    
}

- (void) acornIsNotInstalledForAgent:(ACImageAgent*)agent {
    int x = NSRunAlertPanel(@"Missing Acorn", @"Sorry, but it looks like Acorn is not installed.  Would you like to get it?", @"Get Acorn", @"Cancel", nil);
    
    if (x == NSOKButton) {
        [ACImageAgent getAcornFree];
        // or:
        //[ACImageAgent getAcorn];
    }
}

- (void)openPanelDidEnd:(NSOpenPanel *)panel returnCode:(int)returnCode  contextInfo:(void  *)contextInfo {
    
    NSURL *fileURL = [panel URL];
    if (!fileURL) {
        return;
    }
    
    NSImage *img = [[[NSImage alloc] initWithContentsOfURL:fileURL] autorelease];
    
    if (img) {
        [imageView setImage:img];
    }
    else {
        NSLog(@"could not make image!");
    }
    
}

- (void) testBitmapImageRep:(id)sender {
    
    [[NSOpenPanel openPanel] beginSheetForDirectory:nil
                                               file:nil
                                              types:[NSArray arrayWithObject:@"acorn"]
                                     modalForWindow:[imageView window]
                                      modalDelegate:self
                                     didEndSelector:@selector(openPanelDidEnd:returnCode:contextInfo:)
                                        contextInfo:nil];
    
    
    
}


@end
