


#import "SearchQuery.h"

@interface SearchQuery (Private)

@end

@implementation SearchQuery

- (id)initWithSearchPredicate:(NSPredicate *)searchPredicate title:(NSString *)title {
    [super init];
    _title = [title retain];
    _query = [[NSMetadataQuery alloc] init];
    // We want the items in the query to automatically be sorted by the file system name; this way, we don't have to do any special sorting
    [_query setSortDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:(id)kMDItemFSName ascending:YES] autorelease]]];
    [_query setPredicate:searchPredicate];
    // Use KVO to watch the results of the query
    [_query addObserver:self forKeyPath:@"results" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    [_query setDelegate:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(queryNote:) name:nil object:_query];
    
    [_query startQuery];
    return self;    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];    
    [_query removeObserver:self forKeyPath:@"results"];
    [_query release];
    [_title release];
    [_children release];
    [super dealloc];
}

- (void)sendChildrenDidChangeNote {
    [[NSNotificationCenter defaultCenter] postNotificationName:SearchQueryChildrenDidChangeNotification object:self];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    // Delegate the KVO notification by sending a children changed note. We could check the keyPath, but there is no need, since we only observe one value.
    [_children autorelease];
    _children = [[_query results] retain];
    [self sendChildrenDidChangeNote];
}

#pragma NSMetadataQuery Delegate

- (id)metadataQuery:(NSMetadataQuery *)query replacementObjectForResultObject:(NSMetadataItem *)result {
    // We keep our own search item for the result in order to maintian state (image, thumbnail, title, etc)
    return [[[SearchItem alloc] initWithItem:result] autorelease];
}

- (void)queryNote:(NSNotification *)note {
    // The NSMetadataQuery will send back a note when updates are happening. By looking at the [note name], we can tell what is happening
    if ([[note name] isEqualToString:NSMetadataQueryDidFinishGatheringNotification]) {
        // At this point, the query will be done. You may recieve an update later on.
        if ([_children count] == 0) {
            [_children release];
            SearchItem *emptyItem = [[[SearchItem alloc] initWithItem:nil] autorelease];
            [emptyItem setTitle:NSLocalizedString(@"No results", @"Text to display when there are no results")];
            _children = [[NSArray alloc] initWithObjects:emptyItem, nil];
            [self sendChildrenDidChangeNote];
        }        
    }
}

#pragma mark -


- (NSString *)title {
    return _title;
}

- (NSArray *)children {
    return _children;
}

@end

NSString *SearchQueryChildrenDidChangeNotification = @"SearchQueryChildrenDidChangeNotification";
