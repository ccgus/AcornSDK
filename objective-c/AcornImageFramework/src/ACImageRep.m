//
//  ACImageRep.m
//  AcornImage
//
//  Created by Jonathan Wight on 02/18/08.
//  Copyright 2008 Toxic Software. All rights reserved.
//  Copyright 2008 Flying Meat Software. All rights reserved.
//

#import "ACImageRep.h"

#import "ACImage.h"

//#define debug NSLog

@implementation ACImageRep

+ (void)load {
    [NSImageRep registerImageRepClass:[self class]];
}

#pragma mark -

+ (NSArray *)imageUnfilteredFileTypes {
    return [NSArray arrayWithObjects:@"acorn", @"com.flyingmeat.acorn", nil];
}

+ (BOOL)canInitWithData:(NSData *)data {
    
    if ([data length] > 6) {
        
        NSData *sdata = [data subdataWithRange:NSMakeRange(0, 6)];
        NSString *junk = [[[NSString alloc] initWithData:sdata encoding:NSUTF8StringEncoding] autorelease];
        
        if ([@"SQLite" isEqualToString:junk]) {
            return YES; // we'll just assume it's an acorn image at this point.
        }
        
        // acorn 1.x files:
        if (![@"bplist" isEqualToString:junk]) {
            return NO;
        }
    }
    
    
    // is there an easier way than loading up the whole thing?
    
    NSString *error = nil;
    NSDictionary *d = [NSPropertyListSerialization propertyListFromData:data
                                                       mutabilityOption:NSPropertyListImmutable
                                                                 format:nil
                                                       errorDescription:&error];
    
    if (error || !d) {
        return NO;
    }
    
    return YES;
}

//+ (NSArray *)imageUnfilteredPasteboardTypes;

+ (NSArray *)imageFileTypes {
    return [self imageUnfilteredFileTypes];
}

//+ (NSArray *)imagePasteboardTypes;

#pragma mark -

+ (id)imageRepWithData:(NSData *)inData {
    return [[[self alloc] initWithData:inData] autorelease];
}

- (id)initWithData:(NSData *)inData {
    
    if ((self = [self initWithDrawSelector:@selector(draw:) delegate:self]) != NULL) {
        
        [self setImage:[ACImage imageWithData:inData]];
        
        [self setSize:[_image canvasSize]];
	}
    
    return self;
}

- (void)dealloc {
    [_image release];
    
    [super dealloc];
}


- (void)draw:(id)inArgument {
    [NSGraphicsContext saveGraphicsState];
    [_image drawInContext:[[NSGraphicsContext currentContext] graphicsPort]];
    [NSGraphicsContext restoreGraphicsState];
}

- (ACImage *) image {
    return _image;
}

- (void)setImage:(ACImage *)value {
    if (_image != value) {
        [_image release];
        _image = [value retain];
    }
}



@end
