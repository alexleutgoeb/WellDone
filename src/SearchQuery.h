

#import <Cocoa/Cocoa.h>

#import "SearchItem.h"

/* A SearchQuery is made up of a query string that will have individual SearchItems as children.
 */

extern NSString *SearchQueryChildrenDidChangeNotification;

@interface SearchQuery : NSObject {
@private
    NSMetadataQuery *_query;
    NSString *_title;
    NSArray *_children;
}

- (id)initWithSearchPredicate:(NSPredicate *)searchPredicate title:(NSString *)title;

- (NSString *)title;
- (NSArray *)children;

@end
