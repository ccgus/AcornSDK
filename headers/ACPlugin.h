#import <Cocoa/Cocoa.h>

enum {
    ACBitmapLayer = 1,
    ACShapeLayer  = 2,
    ACGroupLayer  = 3,
    // …
    ACMaskLayer   = 5,
};

enum {
    ACRectangleGraphic = 1,
    ACOvalGraphic = 2,
    ACLineGraphic = 3,
    ACTextGraphic = 4,
    ACImageGraphic = 5,
    ACBezierGraphic = 6,
};

#define ACPLUGIN_SUPPORT 1

// forward decl.
@protocol ACBitmapTool;
@protocol ACImageIOProvider;
@protocol ACLayer;
@protocol ACMaskLayer;

@protocol ACPluginManager

- (BOOL)addFilterMenuTitle:(NSString*)menuTitle
        withSuperMenuTitle:(NSString*)superMenuTitle
                    target:(id)target
                    action:(SEL)selector
             keyEquivalent:(NSString*)keyEquivalent
 keyEquivalentModifierMask:(NSUInteger)mask
                userObject:(id)userObject;

- (BOOL)addActionMenuTitle:(NSString*)menuTitle
        withSuperMenuTitle:(NSString*)superMenuTitle
                    target:(id)target
                    action:(SEL)selector
             keyEquivalent:(NSString*)keyEquivalent
 keyEquivalentModifierMask:(NSUInteger)mask
                userObject:(id)userObject;


- (void)registerIOProviderForReading:(id<ACImageIOProvider>)provider forUTI:(NSString*)uti;
- (void)registerIOProviderForWriting:(id<ACImageIOProvider>)provider forUTI:(NSString*)uti;
- (void)registerFilterName:(NSString*)filterName constructor:(Class)filterClass;
@end



@interface NSApplication (ACPluginManagerAdditions)
- (id<ACPluginManager>)sharedPluginManager;
@end

@protocol ACPlugin

/*
 This will create an instance of our plugin.  You really shouldn't need to
 worry about this at all.
 */
+ (id)plugin;

/*
 This gets called right before the plugin manager registers your plugin.
 I'm honestly not sure what you would use it for, but it seemed like a good
 idea at the time.
 */
- (void)willRegister:(id<ACPluginManager>)thePluginManager;

/*
 didRegister is called right after your plugin is all ready to go.
 */
- (void)didRegister;

/*
 Can we handle shape layers?  If yes, then our action is handed the layer instead of a CIImage
 
 return [NSNumber numberWithBool:YES];
 
 NSNumber is used to be friendly with scripting languages.
 */
- (NSNumber*)worksOnShapeLayers:(id)userObject;

/*
 How about a more general type of "do you work on this type of layer" question:
 
 return [NSNumber numberWithBool:YES];
 
 NSNumber is used to be friendly with scripting languages.
 
 Added in version 3.5
 
 */
- (NSNumber*)validateForLayer:(id<ACLayer>)layer;


@end



@protocol ACLayer <NSObject>
/* There are currently three types of layers.  "Bitmap" layers which contain pixels,
 and "Shape" layers which contain Text.  And then Group layers, which is a group of layers.
 
 And maybe other things eventually.
 
 Check out the ACLayerType enum for the constants to tell which is which.
 */
- (int)layerType;

// grab a CIImage representation of the layer.
- (CIImage*)CIImage;


// grab a CIImage representation of the layer, with opacity, layer styles, mask, and other such things applied to it.
// Added in 4.0
- (CIImage*)renderedCIImage;

// opaqueBounds returns the bounds of the image, not counting any 100% transparent pixels along the edges.  If you have a layer style that expands the image size (such as a drop shadow) this is not included in this calculation.
// Added in 3.5
- (NSRect)opaqueBounds;

// set a layer's mask with the given CIImage.  If a layer mask doesn't already exist, one will be created.
// Added in 3.5
- (void)setLayerMaskImage:(CIImage*)ciimage;

// similar to setLayerMaskImage, the following two methods will set the mask of a layer with a URL or a path to an image.
// Added in 3.5
- (void)setLayerMaskWithImageAtURL:(NSURL*)url;
- (void)setLayerMaskWithImageAtPath:(NSString*)path;

// Get the layer mask (if it exists already).  Note that this returns an ACMaskLayer, not a CIImage
// Added in 3.5
- (id <ACMaskLayer>)mask;

// Added in 3.5
- (BOOL)maskIsLinked;

// Added in 3.5
- (void)setMaskIsLinked:(BOOL)value;

// Added in 4.5 - just adds an empty mask, or one based on the current selection.
- (void)addMask;

@property (assign) BOOL visible;
@property (assign) float opacity;
@property (assign) CGBlendMode compositingMode; // aka, also the blend mode.
@property (retain, nonatomic) NSString *layerName;

@end



@protocol ACShapeLayer <ACLayer>

- (NSArray *)selectedGraphics;
- (NSArray *)graphics;

- (id)addRectangleWithBounds:(NSRect)bounds;
- (id)addOvalWithBounds:(NSRect)bounds;
- (id)addTextWithBounds:(NSRect)bounds;

/* added in 3.2.2 */
- (id)addBezierPath:(NSBezierPath*)path;


/* added in 5.2 */
- (void)moveGraphic:(id)graphic toIndex:(NSUInteger)newIndex;

@end

@protocol ACBitmapLayer <ACLayer>

// set a CIImage on the layer, to be a "preview".  Make sure to set it to nil when you are
// done with whatever it is you are doing.
- (void)setPreviewCIImage:(CIImage*)img;

// apply a ciimage to the layer.
- (void)applyCIImageFromFilter:(CIImage*)img;
- (void)applyCIImageFromFilter:(CIImage*)img shouldClipToSelection:(BOOL)clipToSelection;

// get a CGBitmapContext that we can draw on.
- (CGContextRef)drawableContext;

// commit the changes we made to the context, for undo support
- (void)commitFrameOfDrawableContext:(NSRect)r;

// find out where on our layer the current mouse event is pointing to
- (NSPoint)layerPointFromEvent:(NSEvent*)theEvent;

// tell the layer it needs to be updated
- (void)setNeedsDisplayInRect:(NSRect)invalidRect;


// what the origin of the bottom left corner of the layer is.  It's a silly name, which is why I've added setFrameOrigin: and frameOrigin below.
@property (assign) NSPoint drawDelta;


// same as drawDelta, but with a better name.
- (void)setFrameOrigin:(NSPoint)newOrigin;
- (NSPoint)frameOrigin;


@end

@protocol ACGroupLayer <ACLayer>

- (NSArray *)layers;

- (void)addLayer:(id<ACLayer>)l atIndex:(NSInteger)idx;

- (id<ACBitmapLayer>)insertCGImage:(CGImageRef)img atIndex:(NSUInteger)idx withName:(NSString*)layerName;

// Added in Acorn 5.0.1
- (id<ACBitmapLayer>)insertImageWithPath:(NSString*)path atIndex:(NSUInteger)idx withName:(NSString*)layerName;

- (id<ACShapeLayer>)addShapeLayer;
- (id<ACBitmapLayer>)addBitmapLayer;
- (id<ACGroupLayer>)addGroupLayer;

@end


@protocol ACMaskLayer <ACBitmapLayer>

@end


@protocol ACGraphic <NSObject>

- (int)graphicType;

- (void)setDrawsFill:(BOOL)flag;
- (BOOL)drawsFill;

- (void)setFillColor:(NSColor *)fillColor;
- (NSColor *)fillColor;

- (void)setDrawsStroke:(BOOL)flag;
- (BOOL)drawsStroke;

- (void)setStrokeColor:(NSColor *)strokeColor;
- (NSColor *)strokeColor;

- (void)setStrokeWidth:(CGFloat)width;
- (CGFloat)strokeWidth;

- (NSRect)bounds;

- (BOOL)hasCornerRadius;
- (void)setHasCornerRadius:(BOOL)flag;

- (CGFloat)cornerRadius;
- (void)setCornerRadius:(CGFloat)newCornerRadius;

- (BOOL)hasShadow;
- (void)setHasShadow:(BOOL)flag;

- (CGFloat)shadowBlurRadius;
- (void)setShadowBlurRadius:(CGFloat)newShadowBlurRadius;

- (NSSize)shadowOffset;
- (void)setShadowOffset:(NSSize)newShadowOffset;

- (NSBezierPath *)bezierPath;

- (void)scaleXBy:(CGFloat)xScale yBy:(CGFloat)yScale;

@end

@protocol ACTextGraphic <ACGraphic>

// added in 3.0.1
- (void)setHTMLString:(NSString*)html;

// added in 5.0.1
- (void)setString:(NSString*)s;

@end

@protocol ACDocument <NSObject> // this inherits from NSDocument

// grab an array of layers in the document.
- (NSArray*)layers;

// grab the current layer.
- (id<ACLayer>)currentLayer;

// crop to the given rect.
- (void)cropToRect:(NSRect)cropRect;

// start cropping with the given bounds.
- (void)beginCroppingWithRect:(NSRect)cropBounds;

// scale the image to the given size.
- (void)scaleImageToSize:(NSSize)newSize;

- (void)scaleImageToHeight:(CGFloat)newHeight;
- (void)scaleImageToWidth:(CGFloat)newWidth;

- (void)scaleImageWithPercentage:(CGFloat)a; // new in 5.1.1.

// resize the image to the given size.
- (void)resizeImageToSize:(NSSize)newSize;

// find the size of the canvas
- (NSSize)canvasSize;
- (void)setCanvasSize:(NSSize)s;
- (void)setCanvasSize:(NSSize)newSize usingAnchor:(NSString *)anchor;

// new in 2.0

// returns the base group, which contains all the base layers.
- (id<ACGroupLayer>)baseGroup;


- (NSSize)dpi;
- (void)setDpi:(NSSize)newDpi;


- (CGColorSpaceRef)colorSpace;

// new in 2.2:
- (void)askToCommitCurrentAccessory;

// new in 3.3:
- (id<ACLayer>)firstLayerWithName:(NSString*)layerName;

// new in 5.0: returns a composite of all the layers.
- (CIImage *)CIImage;

// new in 5.0: write to a file.
- (BOOL)writeToFile:(NSString*)path withUTI:(NSString*)uti;

// new in 5.6.5
// set the bits per _pixel_ for the document. The only correct values here are 32, 64, and 128.
- (void)setBitsPerPixel:(size_t)bitsPerPixel;

// new in 5.6.5
// Get the number of bits per pixel.  Since Acorn 5 only works 4 color components (rgba), you can divide this value by 4 to get the number of channels.
- (size_t)bitsPerPixel;

// new in 5.6.5
// Acorn 5 will always return 4 here. But why not have this here for future proofing?
- (size_t)numberOfComponents;

// new in 5.6.5
- (CGImageRef)newCGImage __attribute__((cf_returns_retained));

@end

@protocol ACToolPalette <NSObject>

- (NSColor *)frontColor;
- (void)setFrontColor:(NSColor *)newFrontColor;

- (NSColor *)backColor;
- (void)setBackColor:(NSColor *)newBackColor;

@end


@protocol ACImageIOProvider  <NSObject>

- (BOOL)writeDocument:(id<ACDocument>)document toURL:(NSURL *)absoluteURL ofType:(NSString *)type forSaveOperation:(NSSaveOperationType)saveOperation error:(NSError **)outError;

- (BOOL)readImageForDocument:(id<ACDocument>)document fromURL:(NSURL *)absoluteURL ofType:(NSString *)type error:(NSError **)outError;

@end


@protocol ACUtilities <NSObject>
- (BOOL)crushPNGData:(NSData*)pngData toPath:(NSString*)path;
@end

@interface NSApplication (AcornAdditions)

- (id<ACToolPalette>)toolPalette;
- (id<ACUtilities>)utilitiesHelper;

@end


// This guy is a nice little helper for drawing to a bitmap for use later on.

#ifndef FMDrawContextAvailable

@interface FMDrawContext : NSObject
+ (id)drawContextWithSize:(NSSize)s;
+ (id)drawContextWithSize:(NSSize)s scale:(CGFloat)scale;
- (CIImage*)CIImage;
- (CGImageRef)CGImage __attribute__((cf_returns_retained));
- (NSImage*)NSImage;
- (NSBitmapImageRep*)bitmapImageRep;
- (NSData*)dataOfType:(NSString*)uti;
- (void)drawInContextWithBlock:(void (^)())r;
- (CGContextRef)context;
- (void)lockFocus;
- (void)unlockFocus;
@end

#endif

/*
 CTGradient is in Acorn, it's just got a different name- "TSGradient".
 For more info on CTGradient, visit here:
 http://blog.oofn.net/2006/01/15/gradients-in-cocoa/
 
 You can use it like so:
 id fade = [NSClassFromString(@"TSGradient") gradientWithBeginningColor:[NSColor clearColor] endingColor:[NSColor blackColor]];
 */
@interface NSObject (TSGradientTrustMeItsThere)
+ (id)gradientWithBeginningColor:(NSColor *)begin endingColor:(NSColor *)end;
- (void)fillRect:(NSRect)rect angle:(CGFloat)angle;
@end

@interface CIImage (PXNSImageAdditions)
- (NSImage *)NSImageFromRect:(CGRect)r;
- (NSImage *)NSImage;

// new in Acorn 3.5
- (BOOL)writeToURL:(NSURL*)fileURL withUTI:(NSString*)uti;
@end

@interface NSImage (PXNSImageAdditions)
- (CIImage *)CIImage;
@end

@interface NSDocumentController (ACNSDocumentControllerAdditions)
- (id)makeUntitledDocumentWithData:(NSData*)data;
- (id)makeUntitledDocumentWithSize:(NSSize)s;
@end





