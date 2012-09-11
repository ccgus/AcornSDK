//
//  ACBitmapLayer.m
//  AcornQL
//
//  Created by August Mueller on 9/24/07.
//  Copyright 2007 Flying Meat Inc. All rights reserved.
//

#import "ACBitmapLayer.h"

NSString *TSBitmapLayerImageDataKey           = @"TSBitmapLayerImageDataKey";
NSString *TSBitmapLayerCompressedImageDataKey = @"TSBitmapLayerCompressedImageDataKey";
NSString *TSBitmapLayerSizeKey                = @"TSBitmapLayerSizeKey";
NSString *TSBitmapLayerDrawDelta              = @"TSBitmapLayerDrawDelta";
NSString *TSBitmapLayerSaveFrameKey           = @"TSBitmapLayerSaveFrame";


#define BEST_BYTE_ALIGNMENT 16
#define COMPUTE_BEST_BYTES_PER_ROW(bpr)		( ( (bpr) + (BEST_BYTE_ALIGNMENT-1) ) & ~(BEST_BYTE_ALIGNMENT-1) )

@implementation ACBitmapLayer

// This deflate code was kindly donated to gus by mike ash (www.mikeash.com)
- (NSData *)zlibInflateData:(NSData*)data {
    if ([data length] == 0) return data;
    
    unsigned full_length = [data length];
    unsigned half_length = [data length] / 2;
    
    NSMutableData *decompressed = [NSMutableData dataWithLength:full_length + half_length];
    BOOL done = NO;
    int status;
    
    z_stream strm;
    strm.next_in = (Bytef *)[data bytes];
    strm.avail_in = [data length];
    strm.total_out = 0;
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    
    if (inflateInit (&strm) != Z_OK) return nil;
    while (!done)
    {
        // Make sure we have enough room and reset the lengths.
        if (strm.total_out >= [decompressed length])
            [decompressed increaseLengthBy: half_length];
        
        strm.next_out = [decompressed mutableBytes] + strm.total_out;
        strm.avail_out = [decompressed length] - strm.total_out;
        
        // Inflate another chunk.
        status = inflate (&strm, Z_SYNC_FLUSH);
        if (status == Z_STREAM_END) done = YES;
        else if (status != Z_OK) break;
    }
    if (inflateEnd (&strm) != Z_OK) return nil;
    
    // Set real length.
    if (done)
    {
        [decompressed setLength: strm.total_out];
        return [NSData dataWithData: decompressed];
    }
    else return nil;
}


- (void) dealloc {
    
    if (_imageRef) {
        CGImageRelease(_imageRef);
    }
    
    
    [super dealloc];
}


- (void)loadPropertyListRepresentation:(NSDictionary *)dict {
    [super loadPropertyListRepresentation:dict];
    
    NSData *imgData = [dict objectForKey:TSBitmapLayerImageDataKey];
    
    if (!imgData) {
        imgData = [dict objectForKey:TSBitmapLayerCompressedImageDataKey];
        if (imgData) {
            imgData = [self zlibInflateData:imgData];
        }
    }
    
    _size           = NSSizeFromString([dict objectForKey:TSBitmapLayerSizeKey]);
    _drawDelta      = NSPointFromString([dict objectForKey:TSBitmapLayerDrawDelta]);
    
    NSRect savedBitmapFrame = NSMakeRect(0, 0, _size.width, _size.height);
    
    if ([dict objectForKey:TSBitmapLayerSaveFrameKey]) {
        savedBitmapFrame = NSRectFromString([dict objectForKey:TSBitmapLayerSaveFrameKey]);
    }
    
    size_t bytesPerRow = savedBitmapFrame.size.width * 4;
    bytesPerRow = COMPUTE_BEST_BYTES_PER_ROW(bytesPerRow);
    
    unsigned char *dataPtr = calloc(1, bytesPerRow * savedBitmapFrame.size.height);
    
    [imgData getBytes:dataPtr];
    
    CGContextRef context = CGBitmapContextCreate(dataPtr, _size.width, _size.height, 8, bytesPerRow, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedFirst);
    
    _imageRef = CGBitmapContextCreateImage(context);
    
    CGContextRelease(context);
    free(dataPtr);
}

- (void) drawInContext:(CGContextRef)context {
    
    CGRect r;
    
    r.origin.x = _drawDelta.x;
    r.origin.y = _drawDelta.y;
    r.size.width = _size.width;
    r.size.height = _size.height;
    
    // note, if the context isn't a bitmap context, some of the compositing modes (kCGBlendModeClear - kCGBlendModePlusLighter) won't work.
    if (_compositingMode > 0) {
        CGContextSetBlendMode(context, [self compositingMode]);
    }
    
    
    if (_opacity != 1) {
        CGContextSetAlpha(context, _opacity);
        // #warning do we really need a transparency layer?
        // answer: yes.  Because when we are drawing, the behavior is different when we layer stuff down.
        CGContextBeginTransparencyLayer(context, nil);
    }
    
    CGContextDrawImage(context, r, _imageRef);
    
    
    if (_opacity != 1) {
        CGContextEndTransparencyLayer(context);
    }
}

@end
