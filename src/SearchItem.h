

#import <Cocoa/Cocoa.h>

extern NSString *SearchItemDidChangeNotification;

enum {
    ItemStateThumbnailLoading = 1 << 1,
    ItemStateThumbnailLoaded = 1 << 2,
    ItemStateImageLoading = 1 << 3,    
    ItemStateImageLoaded = 1 << 3,    
};

@interface SearchItem : NSObject {
@private
    NSString *_title;
    NSImage *_thumbnailImage;
    NSMetadataItem *_item;
    NSInteger _state;
    NSURL *_url;
    NSSize _imageSize;
}

- (id)initWithItem:(NSMetadataItem *)item;

- (NSString *)title;
- (void)setTitle:(NSString *)title;

- (NSMetadataItem *)metadataItem;

- (NSSize)imageSize;

- (NSURL *)filePathURL;

- (NSDate *)modifiedDate;
- (NSString *)cameraModel;

/* The thumbnail image may return nil if it isn't loaded. The first access of it will request it to load. 
 */
- (NSImage *)thumbnailImage;

@end
