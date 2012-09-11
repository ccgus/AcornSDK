
#import "ACShapeImage.h"

@implementation ACShapeImage


- (id)init {
    self = [super init];
    if (self) {
        _image = nil;
        _cachedImage = nil;
    }
    return self;
}

- (void)dealloc {
    if (_image != _cachedImage) {
        [_cachedImage release];
    }
    [_image release];
    [super dealloc];
}


- (void)AC_clearCachedImage {
    if (_cachedImage != _image) {
        [_cachedImage release];
    }
    _cachedImage = nil;
}

- (void)setImage:(NSImage *)image {
    if (image != _image) {
        [_image release];
        _image = [image retain];
        [self AC_clearCachedImage];
    }
}

- (NSImage *)image {
    return _image;
}

- (NSImage *)transformedImage {
    if (!_cachedImage) {
        NSRect bounds = [self bounds];
        NSImage *image = [self image];
        
        if (!NSIsEmptyRect(bounds)) {
            BOOL flippedHorizontally = [self flippedHorizontally];
            BOOL flippedVertically = [self flippedVertically];
            
            _cachedImage = [[NSImage allocWithZone:[self zone]] initWithSize:bounds.size];
            
            [_cachedImage setFlipped:NO];
            
            if (!NSIsEmptyRect(bounds)) {
                // Only draw in the image if it has any content.
                [_cachedImage lockFocus];
                
                if (flippedHorizontally || flippedVertically) {
                    // If the image needs flipping, we need to play some games with the transform matrix
                    NSAffineTransform *transform = [NSAffineTransform transform];
                    [transform scaleXBy:([self flippedHorizontally] ? -1.0 : 1.0) yBy:([self flippedVertically] ? -1.0 : 1.0)];
                    [transform translateXBy:([self flippedHorizontally] ? -bounds.size.width : 0.0) yBy:([self flippedVertically] ? -bounds.size.height : 0.0)];
                    [transform concat];
                }
                
                [[image bestRepresentationForDevice:nil] drawInRect:NSMakeRect(0.0, 0.0, (int)bounds.size.width, (int)bounds.size.height)];
                
                [_cachedImage unlockFocus];
            }
        }
    }
    return _cachedImage;
}

- (void)setFlippedHorizontally:(BOOL)flag {
    if (_flippedHorizontally != flag) {
        _flippedHorizontally = flag;
        [self AC_clearCachedImage];
    }
}

- (BOOL)flippedHorizontally {
    return _flippedHorizontally;
}

- (void)setFlippedVertically:(BOOL)flag {
    if (_flippedVertically != flag) {
        _flippedVertically = flag;
        [self AC_clearCachedImage];
    }
}

- (BOOL)flippedVertically {
    return _flippedVertically;
}

- (void)flipHorizontally {
    [self setFlippedHorizontally:([self flippedHorizontally] ? NO : YES)];
}

- (void)flipVertically {
    [self setFlippedVertically:([self flippedVertically] ? NO : YES)];
}

- (void)setBounds:(NSRect)bounds {
    
    if (!NSEqualSizes([self bounds].size, bounds.size)) {
        [self AC_clearCachedImage];
    }
    
    [super setBounds:bounds];
}

- (BOOL)drawsStroke {
    // Never draw stroke.
    return NO;
}


- (void) draw {
    NSRect bounds = [self bounds];
    NSImage *image;
    
    NSShadow *cshadow = nil;
    
    if ([self hasShadow]) {
        cshadow = [[[NSShadow alloc] init] autorelease];
        
        NSSize s = [self shadowOffset];
        
        s.height *= -1;
        
        [cshadow setShadowOffset:s];
        [cshadow setShadowBlurRadius:[self shadowBlurRadius]];
    }
    
    if ([self drawsFill]) {
        [[self fillColor] set];
        [cshadow set];
        NSRectFill(bounds);
    }
    
    [cshadow set];
    image = [self transformedImage];
    if (image) {
        [[image bestRepresentationForDevice:nil] drawAtPoint:NSMakePoint(NSMinX(bounds), NSMinY(bounds))];
    }
    
    if (cshadow) {
        CGContextSetShadowWithColor((CGContextRef)([[NSGraphicsContext currentContext] graphicsPort]), CGSizeZero, 0, NULL);
    }
    
}

NSString *ACShapeImageContentsKey = @"Image";
NSString *ACFlippedHorizontallyKey = @"FlippedHorizontally";
NSString *ACFlippedVerticallyKey = @"FlippedVertically";
NSString *ACIsScreenShotKey = @"IsScreenShot";


- (void)loadPropertyListRepresentation:(NSDictionary *)dict {
    id obj;
    
    [super loadPropertyListRepresentation:dict];
    
    obj = [dict objectForKey:ACShapeImageContentsKey];
    if (obj) {
        [self setImage:[NSUnarchiver unarchiveObjectWithData:obj]];
    }
    obj = [dict objectForKey:ACFlippedHorizontallyKey];
    if (obj) {
        [self setFlippedHorizontally:[obj isEqualToString:@"YES"]];
    }
    obj = [dict objectForKey:ACFlippedVerticallyKey];
    if (obj) {
        [self setFlippedVertically:[obj isEqualToString:@"YES"]];
    }
    
    
    _cachedImage = nil;
}


@end
