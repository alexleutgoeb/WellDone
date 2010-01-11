

#import "SearchItem.h"

@implementation SearchItem

- (id)initWithItem:(NSMetadataItem *)item {
    [super init];
    _item = [item retain];
    return self;
}

- (void)dealloc {
    [_url release];
    [_title release];
    [_thumbnailImage release];
    [super dealloc];
}

- (NSMetadataItem *)metadataItem {
    return _item;
}

- (NSString *)title {
    if (_title == nil) {
        // First access -- dynamically get the title and cache it.
        _title = [(NSString *)[_item valueForAttribute:(NSString *)kMDItemDisplayName] retain];
    }
    return _title;  
}

- (void)setTitle:(NSString *)title {
    if (![_title isEqualToString:title]) {
        [_title release];
        _title = [title copy];
    }
}

- (NSDate *)modifiedDate {
    return (NSDate *)[_item valueForAttribute:(NSString *)kMDItemContentModificationDate];
}

- (NSString *)cameraModel {
    return (NSString *)[_item valueForAttribute:(NSString *)kMDItemAcquisitionModel];
}

- (NSURL *)filePathURL {
    if (_url == nil) {
        NSString *path = [_item valueForAttribute:(NSString *)kMDItemPath];
        if (path != nil) {
            _url = [[NSURL fileURLWithPath:path] retain];
        }
    }
    return [[_url retain] autorelease];
}

+ (NSSize)getImageSizeFromImageSource:(CGImageSourceRef)imageSource {
    CGImageRef imageRef = CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);
    NSSize result;
    if (imageRef != NULL) {
        result.width = CGImageGetWidth(imageRef);
        result.height = CGImageGetHeight(imageRef);
        CGImageRelease(imageRef);
    } else {
        result = NSZeroSize;
    }
    return result;
}

+ (NSImage *)createThumbnailImageFromImageSource:(CGImageSourceRef)imageSource {
    NSImage *result;
    // This code needs to be threadsafe, as it will be called from the background thread. The easiest way to ensure you only use stack variables is to make it a class method.
    NSNumber *maxPixelSize = [NSNumber numberWithInteger:32];
    NSDictionary *imageOptions = [[NSDictionary alloc] initWithObjectsAndKeys:(id)kCFBooleanTrue, (id)kCGImageSourceCreateThumbnailFromImageIfAbsent, maxPixelSize, (id)kCGImageSourceThumbnailMaxPixelSize, kCFBooleanTrue, (id)kCGImageSourceCreateThumbnailWithTransform, nil];
    CGImageRef imageRef = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, (CFDictionaryRef)imageOptions);
    [imageOptions release];
    if (imageRef != NULL) {
        CGRect rect;
        rect.origin.x = 0;
        rect.origin.y = 0;
        rect.size.width = CGImageGetWidth(imageRef);
        rect.size.height = CGImageGetHeight(imageRef);
        result = [[[NSImage alloc] init] autorelease];
        [result setFlipped:YES];
        [result setSize:NSMakeSize(rect.size.width, rect.size.height)];
        [result lockFocus];
        CGContextDrawImage((CGContextRef)[[NSGraphicsContext currentContext] graphicsPort], rect, imageRef);
        
        [result unlockFocus];
        CFRelease(imageRef);
    } else {
        result = nil;
    }
    return result;
}

/* Use a background thread for computing the image thumbnails. This logic is rather complex, but should be easy to follow. The general procedure is to use a shared queue to place the SearchItems onto for thumbnail computation. 
 */

#define HAS_DATA 1
#define NO_DATA  0

// The computeThumbnailClientQueue protectes the computeThumbnailClientQueue
static NSConditionLock *computeThumbnailConditionLock = nil;
static NSMutableArray *computeThumbnailClientQueue = nil;

+ (void)subthreadComputePreviewThumbnailImages {
    @try {
        BOOL shouldExit = NO;
        while (!shouldExit) {
            NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
            
            NSImage *image = nil;
            BOOL aquiredLock = [computeThumbnailConditionLock lockWhenCondition:HAS_DATA beforeDate:[NSDate dateWithTimeIntervalSinceNow:5.0]];
            if (aquiredLock && ([computeThumbnailClientQueue count] > 0)) {
                // Remove the item from the queue. Retain it to ensure it stays alive while we use it in the thread.
                SearchItem *item = [[computeThumbnailClientQueue objectAtIndex:0] retain];
                // Grab the URL while holding the lock, since the _url is cached and shared
                NSURL *urlForImage = [item filePathURL];
                [computeThumbnailClientQueue removeObjectAtIndex:0];
                // Unlock the lock so the main thread can put more things on the stack
                BOOL hasMoreData = [computeThumbnailClientQueue count] > 0;
                [computeThumbnailConditionLock unlockWithCondition:hasMoreData ? HAS_DATA : NO_DATA];
                
                // Now, we can do our slow operations, like loading the image
                CGImageSourceRef imageSource = CGImageSourceCreateWithURL((CFURLRef)urlForImage, nil);
                if (imageSource) {
                    // Grab the width/height
                    NSSize imageSize = [[self class] getImageSizeFromImageSource:imageSource];
                    // Signal the main thread
                    [item performSelectorOnMainThread:@selector(mainThreadComputeImageSizeFinished:) withObject:[NSValue valueWithSize:imageSize] waitUntilDone:NO];
                    
                    // Now, compute the thumbnail
                    image = [[self class] createThumbnailImageFromImageSource:imageSource];
                    [item performSelectorOnMainThread:@selector(mainThreadComputePreviewThumbnailFinished:) withObject:image waitUntilDone:NO];
                }
                
                // Now, we are done with the item.
                [item release];
            } else {
                // It is possible that something was placed on the queue; check if we are done while holding the lock.
                [computeThumbnailConditionLock lock];
                shouldExit = [computeThumbnailClientQueue count] == 0;
                if (shouldExit) {
                    [computeThumbnailClientQueue release];
                    computeThumbnailClientQueue = nil;
                }
                [computeThumbnailConditionLock unlock];
            }
            [pool release];
        }
    } @catch (NSException *e) {
        NSLog(@"Exception raised in thumbnail preview thread: %@", e);
    }
}

- (void)computeThumbnailImageInBackgroundThread {
    if (computeThumbnailConditionLock == nil) {
        computeThumbnailConditionLock = [[NSConditionLock alloc] initWithCondition:NO_DATA];
    }
    
    // See if we need to startup the thread. The computeThumbnailClientQueue being nil is the signal to start the thread..
    // Acquire the lock first.
    [computeThumbnailConditionLock lock];
    if (computeThumbnailClientQueue == nil) {
        computeThumbnailClientQueue = [[NSMutableArray alloc] init];
        [NSThread detachNewThreadSelector:@selector(subthreadComputePreviewThumbnailImages) toTarget:[self class] withObject:nil];
    }
    
    if ([computeThumbnailClientQueue indexOfObjectIdenticalTo:self] == NSNotFound) {
        [computeThumbnailClientQueue addObject:self];
    }
    BOOL hasMoreData = [computeThumbnailClientQueue count] > 0;
    
    // Now, unlock, which will signal the background thread to start working
    [computeThumbnailConditionLock unlockWithCondition:hasMoreData ? HAS_DATA : NO_DATA];
}

- (NSImage *)thumbnailImage {
    if (!(_state & ItemStateThumbnailLoaded)) {
        if (_thumbnailImage == nil && (_state & ItemStateThumbnailLoading) == 0) {
            _state |= ItemStateThumbnailLoading;
            [self computeThumbnailImageInBackgroundThread];
        }
    }
    return _thumbnailImage;
}

- (void)mainThreadComputePreviewThumbnailFinished:(NSImage *)thumbnail {
    _state &= ~ItemStateThumbnailLoading;
    _state |= ItemStateThumbnailLoaded;
    if (_thumbnailImage != thumbnail) {
        [_thumbnailImage release];
        _thumbnailImage = [thumbnail retain];
        [[NSNotificationCenter defaultCenter] postNotificationName:SearchItemDidChangeNotification object:self];    
    }
}

- (void)mainThreadComputeImageSizeFinished:(NSValue *)imageSizeValue {
    _imageSize = [imageSizeValue sizeValue];
    [[NSNotificationCenter defaultCenter] postNotificationName:SearchItemDidChangeNotification object:self];    
}

- (NSSize)imageSize {
    return _imageSize;
}

@end

NSString *SearchItemDidChangeNotification = @"SearchItemDidChangeNotification";
