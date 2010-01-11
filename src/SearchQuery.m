#import "SearchQuery.h"

@interface SearchQuery (Private)

@end

@implementation SearchQuery

- (id)initWithSearchPredicate:(NSPredicate *)searchPredicate title:(NSString *)title {
	
	moc = [[NSApp delegate] managedObjectContext];
	_title = [title retain];
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Task" inManagedObjectContext:moc];
	NSFetchRequest *request = [[NSFetchRequest alloc] init];

	[request setEntity:entityDescription];
	[request setPredicate:searchPredicate];
	
	NSError *error;
	NSArray *tasks = [moc executeFetchRequest:request error:&error];

	if (tasks == nil) {
		NSLog(@"ERROR fetchRequest Tasks == nil!");
	} 
	_children = [tasks retain];
    return self;    
}

- (void)dealloc {
    [_title release];
    [_children release];
    [super dealloc];
}


#pragma mark -


- (NSString *)title {
    return _title;
}

- (NSArray *)children {
    return _children;
}

@end
