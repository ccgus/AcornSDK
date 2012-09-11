//
//  KernelrKontroler.m
//  Kernelr
//
//  Created by August Mueller on 10/10/07.
//  Copyright 2007 Flying Meat Inc. All rights reserved.
//

#import "KernelrKontroler.h"


CGContextRef TSCGBitmapFloatContextCreate(NSSize size, CGColorSpaceRef cs);

static void KKFSEventsCallback (const FSEventStreamRef streamRef, 
                                FSEventStreamContext ctxt, 
                                size_t numEvents, 
                                void* eventPaths, 
                                const FSEventStreamEventFlags eventFlags[], 
                                const FSEventStreamEventId eventIds[]);

@interface CIKernel (Private)

- (NSArray*)parameters;

@end


@implementation KernelrKontroler

@synthesize filterPath=_filterPath;
@synthesize inputImage=_inputImage;
@synthesize theFilter=_theFilter;
@synthesize theKernel=_theKernel;

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_filterPath release];
    [_inputImage release];
    [_theFilter release];
    [_theKernel release];
    
    [super dealloc];
}



- (void)awakeFromNib {
    
    [self updateInputImage];
    
    id defaultsController = [NSUserDefaultsController sharedUserDefaultsController];
    
    [defaultsController addObserver:self
                         forKeyPath:@"values.kernelrSoftwareRender" 
                            options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
                            context:NULL];
    
    [defaultsController addObserver:self
                         forKeyPath:@"values.kernelrNumberInput" 
                            options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
                            context:NULL];
    
    [defaultsController addObserver:self
                         forKeyPath:@"values.kernelrDrawTo" 
                            options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
                            context:NULL];
    
    [defaultsController addObserver:self
                         forKeyPath:@"values.kernelrShowCheckerboard" 
                            options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
                            context:NULL];
    
    [defaultsController addObserver:self
                         forKeyPath:@"values.kernelrDrawInMemoryFirst" 
                            options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
                            context:NULL];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateInputImage) name:@"TSLayerChangeNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateKernel)     name:@"KKernelChangeNotification" object:nil];
    
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"KKLastPath"]) {
        [self setFilterPath:[NSURL fileURLWithPath:[[NSUserDefaults standardUserDefaults] objectForKey:@"KKLastPath"]]];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [self updateImage];
}

- (void)updateKernel {
    
    
    
    
    [self setTheFilter:nil];
    [self updateImage];
}

- (void)updateInputImage {
    
    id<ACDocument> document = [[NSDocumentController sharedDocumentController] currentDocument];
    
    id<ACBitmapLayer> currentLayer = (id)[document currentLayer];
    
    if ([currentLayer layerType] != ACBitmapLayer) {
        NSLog(@"The current layer is not a bitmap layer, sorry!");
        return;
    }
    
    [self setInputImage:[currentLayer CIImage]];
    [self updateImage];
}

- (void)updateImage {
    
    if (!_inputImage || !_filterPath) {
        return;
    }
    
    if (!_theFilter) {
        
        NSString *foo = [[[NSString alloc] initWithData:[NSData dataWithContentsOfURL:_filterPath] encoding:NSUTF8StringEncoding] autorelease];
        NSArray *kernels = [CIKernel kernelsWithString:foo];
        
        if (!kernels) {
            
            [[self window] setBackgroundColor:[NSColor redColor]];
            
            NSLog(@"Can't compile the kernel");
            return;
        }
        
        [[self window] setBackgroundColor:[NSColor windowBackgroundColor]];
        
        CIKernel *kernel    = [kernels objectAtIndex:0];
        CIFilter *filter    = [[[CIFilter alloc] init] autorelease];
        
        [self setTheKernel:kernel];
        [self setTheFilter:filter];
        
        if (!_theFilter) {
            NSLog(@"Making the filter failed.  Clang-sa is making me do this");
            return;
        }
        
    }
    
    BOOL usedFront = NO;
    
    NSMutableArray *args = [NSMutableArray array];
    
    for (NSDictionary *info in [_theKernel parameters]) {
        
        NSString *type = [info objectForKey:kCIAttributeClass];
        
        if ([type isEqualToString:@"CIVector"] && ([[info objectForKey:@"CIVectorSize"] intValue] == 2)) {
            // i'm just going to assume x/y input for this guy.
            NSPoint p = [imageView lastPoint];
            [args addObject:[CIVector vectorWithX:p.x Y:p.y]];
        }
        else if ([type isEqualToString:@"CIVector"] && ([[info objectForKey:@"CIVectorSize"] intValue] == 4)) {
            // we're goign to use colors for this.
            
            
            NSColor *frontColor = [[NSApp toolPalette] frontColor];
            CGFloat r, g, b, a;
            //debug(@"[frontColor colorUsingColorSpaceName:NSDeviceRGBColorSpace]: '%@'", [frontColor colorUsingColorSpaceName:NSDeviceRGBColorSpace]);
            [[frontColor colorUsingColorSpaceName:NSDeviceRGBColorSpace] getRed:&r green:&g blue:&b alpha:&a];
            
            [args addObject:[CIVector vectorWithX:r Y:g Z:b W:a]];
            
        }
        else if ([type isEqualToString:@"CISampler"]) {
            [args addObject:[CISampler samplerWithImage:_inputImage]];
        }
        else if ([type isEqualToString:@"CIColor"]) {
            
            NSColor *frontColor = usedFront ? [[NSApp toolPalette] backColor] : [[NSApp toolPalette] frontColor];
            
            usedFront = !usedFront;
            
            CGFloat r, g, b, a;
            //debug(@"[frontColor colorUsingColorSpaceName:NSDeviceRGBColorSpace]: '%@'", [frontColor colorUsingColorSpaceName:NSDeviceRGBColorSpace]);
            [[frontColor colorUsingColorSpaceName:NSDeviceRGBColorSpace] getRed:&r green:&g blue:&b alpha:&a];
            CIColor *c = [CIColor colorWithRed:r green:g blue:b alpha:a];
            [args addObject:c];
        }
        else if ([type isEqualToString:@"NSNumber"]) {
            
            CGFloat f = [[NSUserDefaults standardUserDefaults] floatForKey:@"kernelrNumberInput"];
            
            [args addObject:[NSNumber numberWithFloat:f]];
        }
    }
    
    CIImage *output     = [_theFilter apply:_theKernel arguments:args options:nil];
    CGRect extent       = [output extent];
    
    if (CGRectEqualToRect(extent, CGRectInfinite)) {
        CGRect originalExtent   = [_inputImage extent];
        CIVector *theCropVector = [CIVector vectorWithX:0.0 Y:0.0 Z:originalExtent.size.width W:originalExtent.size.height];
        CIFilter *theFilter     = [CIFilter filterWithName:@"CICrop" keysAndValues:@"inputImage", output, @"inputRectangle", theCropVector, NULL];
        output                  = [theFilter valueForKey:@"outputImage"];
        extent                  = [output extent];
    }
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kernelrDrawInMemoryFirst"]) {
        
        CGColorSpaceRef rcs = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
        CGContextRef context    = TSCGBitmapFloatContextCreate(NSMakeSize(2, 2), rcs);
        
        NSMutableDictionary *contextOptions = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                               //(id)rcs, kCIContextOutputColorSpace,
                                               (id)rcs, kCIContextWorkingColorSpace,
                                               //[NSNumber numberWithBool:[[NSUserDefaults standardUserDefaults] boolForKey:@"CISoftwareRender"]], kCIContextUseSoftwareRenderer,
                                               nil];
        
        CFRelease(rcs);
        
        CIContext *cictx = [CIContext contextWithCGContext:context options:contextOptions];
        
        [cictx drawImage:output inRect:extent fromRect:extent];
        
        CGContextRelease(context);
        
        
        /*
        CGColorSpaceRef rcs = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
        
        CGContextRef context    = TSCGBitmapFloatContextCreate(NSSizeFromCGSize(extent.size), rcs);
        
        NSMutableDictionary *contextOptions = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                               (id)rcs, kCIContextOutputColorSpace,
                                               (id)rcs, kCIContextWorkingColorSpace,
                                               [NSNumber numberWithBool:[[NSUserDefaults standardUserDefaults] boolForKey:@"CISoftwareRender"]], kCIContextUseSoftwareRenderer,
                                               nil];
        
        CGColorSpaceRelease(rcs);
        
        CIContext *cictx = [CIContext contextWithCGContext:context options:contextOptions];
        
        [cictx drawImage:output inRect:extent fromRect:extent];
        
        // make a tiff from our context
        CGImageRef imageRef                     = CGBitmapContextCreateImage(context);
        NSMutableData *data                     = [NSMutableData data];
        CGImageDestinationRef imageDestination  = CGImageDestinationCreateWithData((CFMutableDataRef)data, kUTTypeTIFF, 1, nil);
        
        CGImageDestinationAddImage(imageDestination, imageRef, (CFDictionaryRef)[NSDictionary dictionary]);
        CGImageDestinationFinalize(imageDestination);
        
        CFRelease(imageDestination);
        CGImageRelease(imageRef);
        
        NSImage *image = [[[NSImage alloc] initWithData:data] autorelease];
        
        CGContextRelease(context);
        */
    }
    
    [imageView setImage:output];
    [imageView setNeedsDisplay:YES];
}

- (void)setupFSEvents {
    
    if (_eventsStream) {
        FSEventStreamInvalidate(_eventsStream);
        FSEventStreamRelease(_eventsStream);
    }
    
    if (!_filterPath) {
        return;
    }
    
    NSString *path = [[_filterPath path] stringByDeletingLastPathComponent];
    
    CFAbsoluteTime latency = 1.0;
    _eventsStream = FSEventStreamCreate(kCFAllocatorDefault,
                                        (FSEventStreamCallback)&KKFSEventsCallback,
                                        nil,
                                        (CFArrayRef)[NSArray arrayWithObject:path],
                                        kFSEventStreamEventIdSinceNow,
                                        latency,
                                        kFSEventStreamCreateFlagUseCFTypes);
    
    if (_eventsStream) {
        FSEventStreamScheduleWithRunLoop(_eventsStream, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
        if (!FSEventStreamStart(_eventsStream)) {
            NSLog(@"Can't start fsevents!");
            return;
        }
        FSEventStreamFlushSync(_eventsStream);
    }
    
}

- (NSURL *)filterPath {
    return _filterPath;
}

- (void)setFilterPath:(NSURL *)value {
    if (_filterPath != value) {
        [_filterPath release];
        _filterPath = [value retain];
        
        if (_filterPath) {
            [[NSUserDefaults standardUserDefaults] setObject:[_filterPath path] forKey:@"KKLastPath"];
            [self setupFSEvents];
        }
        
        [self updateKernel];
    }
}


- (void)updateViewWithMouseAtWhateverICantThinkOfAGoodNameForThisMethodOhAtPoint:(NSPoint)p {
    [self updateImage]; 
}



- (IBAction) openKernelFile:(id)sender {
    if (!_filterPath) {
        NSBeep();
        return;
    }
    
    [[NSWorkspace sharedWorkspace] openFile:[_filterPath path]];
}

@end

CGContextRef TSCGBitmapFloatContextCreate(NSSize size, CGColorSpaceRef cs) {
    
    size_t theBitsPerComponent = 32;
    size_t inBytesPerPixel = 16;
    
    size_t theBytesPerRow = ((int)size.width * inBytesPerPixel + 15) & ~15;
    while ( 0 == (theBytesPerRow & (theBytesPerRow - 1) ) ) {
        theBytesPerRow += 16;
    }
    
    //size_t theDataSize = theBytesPerRow * size.height;
    //float* theBitmapData = malloc(theDataSize);
    
    CGContextRef context = CGBitmapContextCreate(0x00, size.width, size.height, theBitsPerComponent, theBytesPerRow, cs, kCGBitmapFloatComponents | kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Host);
    
    return context;
}



static void KKFSEventsCallback (const FSEventStreamRef streamRef, 
                                FSEventStreamContext ctxt, 
                                size_t numEvents, 
                                void* eventPaths, 
                                const FSEventStreamEventFlags eventFlags[], 
                                const FSEventStreamEventId eventIds[]) 
{
    // FIXME: I probably should be a little more precise here.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KKernelChangeNotification" object:nil];
}
