//
//  ACImage.m
//  AcornQL
//
//  Created by August Mueller on 9/24/07.
//  Copyright 2007 Flying Meat Inc. All rights reserved.
//

#import "ACImage.h"
#import "ACLayer.h"
#import "ACShapeLayer.h"
#import "ACBitmapLayer.h"
#import "FMDatabaseAdditions.h"

@implementation ACImage

+ (id) imageWithFilePath:(NSString*)filePath {
    
    ACImage *img = [[[self alloc] init] autorelease];
    
    [img readFileAtPath:filePath];
    [img setTransparentBackground:YES];
    return img;
}

+ (id) imageWithURL:(NSURL*)fileURL {
    
    ACImage *img = [[[self alloc] init] autorelease];
    
    [img readFileAtPath:[fileURL path]];
    [img setTransparentBackground:YES];
    
    return img;
}

+ (id) imageWithData:(NSData*)data {
	
    ACImage *img = [[[self alloc] init] autorelease];
    
    [img readData:data];
    [img setTransparentBackground:YES];
    
    return img;
}

- (void) dealloc {
    [_layers autorelease];
    _layers = 0x00;
    
    [_db autorelease];
    _db = 0x00;
    
    if (_databasePathToDelete) {
        [[NSFileManager defaultManager] removeFileAtPath:_databasePathToDelete handler:nil];
        [_databasePathToDelete autorelease];
        _databasePathToDelete = 0x00;
    }
    
    [super dealloc];
}

- (NSSize)canvasSize {
    return _canvasSize;
}
- (void)setCanvasSize:(NSSize)newCanvasSize {
    _canvasSize = newCanvasSize;
}


- (NSMutableArray *)layers {
    return _layers; 
}
- (void)setLayers:(NSMutableArray *)newLayers {
    [newLayers retain];
    [_layers release];
    _layers = newLayers;
}

- (BOOL)transparentBackground {
    return _transparentBackground;
}

- (void)setTransparentBackground:(BOOL)flag {
    _transparentBackground = flag;
}

- (void) readFileAtPath:(NSString*)path {
    
    NSData *data = [NSData dataWithContentsOfMappedFile:path];
    
    if (!data) {
        return;
    }
    
    NSData *sub             = [data subdataWithRange:NSMakeRange(0, 6)];
    NSString *header        = [[[NSString alloc] initWithData:sub encoding:NSUTF8StringEncoding] autorelease];
    
    if ([@"bplist" isEqualToString:header]) {
        [self readData:data];
    }
    else {
        [self readDatabaseAtPath:path];
    }
}

- (void) readDatabaseAtPath:(NSString *)path {
    
    _db = [[PXFMDatabase databaseWithPath:path] retain];
    
    [_db open];
    
    NSString *canvasSizeS = [_db stringForQuery:@"select value from image_attributes where name = ?", @"imageSize"];
    
    [self setCanvasSize:NSSizeFromString(canvasSizeS)];
}

- (void) readDatabaseFromMemory:(NSData *)data {
    
    // well poop.  We need to write this data to disk somewhere, and then read it, because we can't load a sqlite db into memory this way.
    
    // let's make a uuid for this guy.
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidString = (NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
    CFRelease(uuid);
    [uuidString autorelease];
    
    uuidString = [uuidString lowercaseString];  // (I have an aversion to uppercase uuid's.  THEY ARE SHOUTING AT ME AND I DON'T LIKE IT STOP STOP STOP NOW THX.)
    
    _databasePathToDelete = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.acorn", uuidString]];
    [_databasePathToDelete retain];
    
    if ([data writeToFile:_databasePathToDelete atomically:NO]) {
        [self readDatabaseAtPath:_databasePathToDelete];
    }
    else {
        NSLog(@"Could not create temporary file to load acorn image");
    }
}


- (void) readData:(NSData *)data {
    
    if ([data length] > 6) {
        
        NSData *sdata = [data subdataWithRange:NSMakeRange(0, 6)];
        NSString *junk = [[[NSString alloc] initWithData:sdata encoding:NSUTF8StringEncoding] autorelease];
        
        if ([@"SQLite" isEqualToString:junk]) {
            
            [self readDatabaseFromMemory:data];
            return;
        }
    }
    
    
    NSString *error = nil;
    NSDictionary *doc = [NSPropertyListSerialization propertyListFromData:data
                                                         mutabilityOption:NSPropertyListImmutable
                                                                   format:nil
                                                         errorDescription:&error];
    
    if (error) {
        NSLog(@"error: %@", error);
        return;
    }
    
    if (![doc objectForKey:@"canvasSize"]) {
        return;
    }
    _canvasSize = NSSizeFromString([doc objectForKey:@"canvasSize"]);
    
    [self setLayers:[NSMutableArray array]];
    NSArray *ar = [doc objectForKey:@"LayersList"];
    NSEnumerator *e = [ar objectEnumerator];
    NSDictionary *layerDict;
    
    while ((layerDict = [e nextObject])) {
        
        NSString *className = [layerDict objectForKey:@"class"];
        ACLayer *layer = 0x00;
        
        if ([@"TSBitmapLayer" isEqualToString:className]) {
            layer = [[[ACBitmapLayer alloc] init] autorelease];
        }
        else if ([@"TSShapeLayer" isEqualToString:className]) {
            layer = [[[ACShapeLayer alloc] init] autorelease];
        }
        else {
            // ... why what do we have here?  A futuristic new layer of some type?  AMAZING!
        }
        
        
        if (layer) {
            [layer loadPropertyListRepresentation:layerDict];
            [[self layers] addObject:layer];
        }
        
    }
}

- (NSData*) compositeData {
    NSData *compositeData = [_db dataForQuery:@"select value from image_attributes where name = ?", @"composite"];
    
    if (!compositeData) {
        NSLog(@"No composite data");
        // TODO: load up the layers
        return 0x00;
    }
    
    return compositeData;
}

- (void) drawFromDatabaseInContext:(CGContextRef)context {
    NSData *compositeData = [self compositeData];
    
    if (!compositeData) {
        NSLog(@"No composite data");
        // TODO: load up the layers
        return;
    }
    
    //NSDictionary *options = [NSDictionary dictionaryWithObject:(id)kUTTypePNG forKey:(id)kCGImageSourceTypeIdentifierHint];
    
    CGImageSourceRef imageSourceRef = CGImageSourceCreateWithData((CFDataRef)compositeData, nil);
    if (!imageSourceRef) {
        NSLog(@"Could not turn the data into an image");
        return;
    }
    
    CGImageRef imageRef = CGImageSourceCreateImageAtIndex(imageSourceRef, 0, (CFDictionaryRef)[NSDictionary dictionary]);
    
    CFRelease(imageSourceRef);
    
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(imageRef), CGImageGetHeight(imageRef)), imageRef);
    
    CGImageRelease(imageRef);
    
}


- (void) drawInContext:(CGContextRef)context {
    
    if (_db) {
        [self drawFromDatabaseInContext:context];
        return;
    }
    
    NSEnumerator *e = [[self layers] reverseObjectEnumerator];
    ACLayer *layer;
    
    if (!_transparentBackground) {
        CGContextSetRGBFillColor(context, 1, 1, 1, 1); // white
        CGContextFillRect(context, CGRectMake(0, 0, _canvasSize.width, _canvasSize.height));
    }
    
    while ((layer = [e nextObject])) {
        
        if (![layer visible]) {
            continue;
        }
        
        CGContextSaveGState(context);
        
        if ([layer isKindOfClass:[ACShapeLayer class]]) {
            // flip the context
            CGContextTranslateCTM(context, 0, _canvasSize.height);
            CGContextScaleCTM(context, 1.0, -1.0 );
        }
        
        [layer drawInContext:context];
        
        CGContextRestoreGState(context);
    }
}

- (CGImageRef) createCGImage {
    
    CGColorSpaceRef cs   = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo options = kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Host;
    CGContextRef context = CGBitmapContextCreate(nil, _canvasSize.width, _canvasSize.height, 8, 0, cs, options);
    
    [self drawInContext:context];
    
    CGImageRef img = CGBitmapContextCreateImage(context);
    
    CGContextRelease(context);
    CGColorSpaceRelease(cs);
    
    return img;
}


@end
