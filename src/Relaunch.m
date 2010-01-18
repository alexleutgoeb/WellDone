//
//  Relaunch.m
//  WellDone
//
//  Created by Christian Hattinger on 18.01.10.
//  Copyright 2010 TU Wien. All rights reserved.
//

#pragma mark Main method
int main(int argc, char *argv[])
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	// get the PID and wait until the application quit
	pid_t parentPID = atoi(argv[2]);
	ProcessSerialNumber psn;
	while (GetProcessForPID(parentPID, &psn) != procNotFound)
		sleep(1);
	
	// get the path of the app
	NSString *appPath = [NSString stringWithCString:argv[1] encoding:NSUTF8StringEncoding];
	BOOL success = [[NSWorkspace sharedWorkspace] openFile:[appPath stringByExpandingTildeInPath]];
	
	if (!success)
		NSLog(@"Error: could not relaunch application at %@", appPath);
	
	[pool drain];
	return (success) ? 0 : 1;

}



