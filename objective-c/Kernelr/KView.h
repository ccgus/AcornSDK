//
//  KView.h
//  Kernelr
//
//  Created by August Mueller on 10/12/07.
//  Copyright 2007 Flying Meat Inc. All rights reserved.
//

#define NS_BUILD_32_LIKE_64 1

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

@interface KView : NSView {
    IBOutlet id _delegate;
    NSPoint _lastPoint;
    
    CIImage *_image;
    
}

@property (assign) NSPoint lastPoint;
@property (assign) id delegate;
@property (retain) CIImage *image;

@end

@interface NSObject (extras)
- (void)updateViewWithMouseAtWhateverICantThinkOfAGoodNameForThisMethodOhAtPoint:(NSPoint)p;
@end
