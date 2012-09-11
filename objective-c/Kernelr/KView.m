//
//  KView.m
//  Kernelr
//
//  Created by August Mueller on 10/12/07.
//  Copyright 2007 Flying Meat Inc. All rights reserved.
//

#import "KView.h"

#define debug NSLog


@implementation KView
@synthesize lastPoint=_lastPoint;
@synthesize delegate=_delegate;
@synthesize image=_image;

- (void)dealloc {
    [_image release];
    [super dealloc];
}

- (void)awakeFromNib {
    //[[self window] setPreferredBackingLocation:NSWindowBackingLocationVideoMemory];
}


- (void)drawRect:(NSRect)rect {
    
    static CIFilter *kCheckerFilter = 0x00;
    
    if (!kCheckerFilter) {
        kCheckerFilter = [[CIFilter filterWithName:@"CICheckerboardGenerator"] retain];
        [kCheckerFilter setDefaults];
        
        [kCheckerFilter setValue:[CIColor colorWithRed:0.9f green:0.9f blue:0.9f] forKey:@"inputColor1"];
        [kCheckerFilter setValue:[NSNumber numberWithFloat:10.0f] forKey:@"inputWidth"];
    }
    
    CIContext *ctx = [[NSGraphicsContext currentContext] CIContext];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kernelrShowCheckerboard"]) {
         [ctx drawImage:[kCheckerFilter valueForKey:@"outputImage"]
                 inRect:[self bounds]
               fromRect:[self bounds]];
    }
    
    if (_image) {
        
        NSInteger drawType = [[NSUserDefaults standardUserDefaults] integerForKey:@"kernelrDrawTo"];
        
        if (drawType == 0) {
            [ctx drawImage:_image atPoint:CGPointZero fromRect:[_image extent]];
        }
        else if (drawType == 1) {
            CIImageAccumulator *acc = [[[CIImageAccumulator alloc] initWithExtent:[self bounds] format:kCIFormatARGB8] autorelease];
            [acc setImage:_image];
            [ctx drawImage:[acc image] atPoint:CGPointZero fromRect:[_image extent]];
        }
        else if (drawType == 2) {
            CIImageAccumulator *acc = [[[CIImageAccumulator alloc] initWithExtent:[self bounds] format:kCIFormatRGBAf] autorelease];
            [acc setImage:_image];
            [ctx drawImage:[acc image] atPoint:CGPointZero fromRect:[_image extent]];
        }
        else if (drawType == 3 || drawType == 4) {
            
            CGColorSpaceRef cs = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
            
            CGContextRef context = 0x00;
            
            if (drawType == 3) {
                context = CGBitmapContextCreate(nil, [self bounds].size.width, [self bounds].size.height, 8, 0, cs, kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Host);
            }
            else {
                size_t theBitsPerComponent = 32;
                size_t inBytesPerPixel = 16;
                
                size_t theBytesPerRow = ((int)[self bounds].size.width * inBytesPerPixel + 15) & ~15;
                while ( 0 == (theBytesPerRow & (theBytesPerRow - 1) ) ) {
                    theBytesPerRow += 16;
                }
                
                context = CGBitmapContextCreate(0x00, [self bounds].size.width, [self bounds].size.height, theBitsPerComponent, theBytesPerRow, cs, kCGBitmapFloatComponents | kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Host);
                
            }
            
            
            [ctx drawImage:_image atPoint:CGPointZero fromRect:[_image extent]];
            
            CGImageRef cgimage = CGBitmapContextCreateImage(context);
            
            CGContextDrawImage([[NSGraphicsContext currentContext] graphicsPort], [_image extent], cgimage);
            
            CGImageRelease(cgimage);
            
            CGColorSpaceRelease(cs);
            CGContextRelease(context);
        }
        else if (drawType == 5) {
            
            CGColorSpaceRef cs = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
            
            NSMutableDictionary *contextOptions = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                   //(id)cs, kCIContextOutputColorSpace,
                                                   (id)cs, kCIContextWorkingColorSpace,
                                                   [NSNumber numberWithBool:[[NSUserDefaults standardUserDefaults] boolForKey:@"kernelrSoftwareRender"]], kCIContextUseSoftwareRenderer,
                                                   nil];
            
            CGColorSpaceRelease(cs);
            
            CIContext *cictx = [CIContext contextWithCGContext:[[NSGraphicsContext currentContext] graphicsPort] options:contextOptions];
            
            [cictx drawImage:_image atPoint:CGPointZero fromRect:[_image extent]];
        }
        else {
            debug(@"eh?");
        }
    }
}

- (void)sendDelegateEvent:(NSEvent*)theEvent {
    
    if ([self delegate] && [[self delegate] respondsToSelector:@selector(updateViewWithMouseAtWhateverICantThinkOfAGoodNameForThisMethodOhAtPoint:)]) {
        NSPoint thePoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
        [self setLastPoint:thePoint];
        [[self delegate] updateViewWithMouseAtWhateverICantThinkOfAGoodNameForThisMethodOhAtPoint:thePoint];
    }
    
}

- (void)mouseDown:(NSEvent*)theEvent {
    
    [self sendDelegateEvent:theEvent];
    
    while (1) {
        theEvent = [[self window] nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)];
        
        if ([theEvent type] == NSLeftMouseUp) {
            break;
        }
        
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        
        [self sendDelegateEvent:theEvent];
        
        [pool release];
    }
}


@end
