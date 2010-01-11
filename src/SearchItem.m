

#import "SearchItem.h"

@implementation SearchItem

- (void)dealloc {
    [_title release];
    [super dealloc];
}

- (void)setTitle:(NSString *)title {
    if (![_title isEqualToString:title]) {
        [_title release];
        _title = [title copy];
    }
}

@end

