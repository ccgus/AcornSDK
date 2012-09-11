#import <Cocoa/Cocoa.h>
#import "ACGraphic.h"

@interface ACShapeImage : ACGraphic {
     NSImage *_image;
     NSImage *_cachedImage;
     BOOL _flippedHorizontally;
     BOOL _flippedVertically;
     BOOL isScreenShot;

}


 - (void)setImage:(NSImage *)image;
 - (NSImage *)image;
 - (NSImage *)transformedImage;
 
 - (void)setFlippedHorizontally:(BOOL)flag;
 - (BOOL)flippedHorizontally;
 - (void)setFlippedVertically:(BOOL)flag;
 - (BOOL)flippedVertically;

@end

