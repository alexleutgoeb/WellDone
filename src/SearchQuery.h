#import <Cocoa/Cocoa.h>
#import "SearchItem.h"

extern NSString *SearchQueryChildrenDidChangeNotification;

@interface SearchQuery : NSObject {
	NSManagedObjectContext *moc;
@private
    NSString *_title;
    NSArray *_children;
}

- (id)initWithSearchPredicate:(NSPredicate *)searchPredicate title:(NSString *)title;

- (NSString *)title;
- (NSArray *)children;

@end
