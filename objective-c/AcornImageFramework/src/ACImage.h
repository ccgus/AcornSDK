//
//  ACImage.h
//  AcornQL
//
//  Created by August Mueller on 9/24/07.
//  Copyright 2007 Flying Meat Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FMDatabase.h"

@interface ACImage : NSObject {
    NSSize _canvasSize;
    NSMutableArray *_layers;
    BOOL _transparentBackground;
    
    PXFMDatabase *_db;
    NSString *_databasePathToDelete;
}

+ (id) imageWithFilePath:(NSString*)filePath;
+ (id) imageWithURL:(NSURL*)fileURL;
+ (id) imageWithData:(NSData*)data;

- (void) readDatabaseAtPath:(NSString *)path;
- (void) readFileAtPath:(NSString*)path;
- (void) readData:(NSData *)data;

- (NSSize)canvasSize;
- (NSMutableArray *)layers;
- (BOOL)transparentBackground;
- (void)setTransparentBackground:(BOOL)flag;

- (void) drawInContext:(CGContextRef)context;

- (NSData*) compositeData; // a png.

- (CGImageRef) createCGImage;

@end
