//
//  KooabaQueryTool.m
//  kooabaQuerySample
//
//  Copyright 2009 kooaba AG. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. 
//

#import <Foundation/Foundation.h>
#import "KooabaQuery.h"

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    NSLog(@"kooaba Query Sample");

	NSString *accessKey = @"df8d23140eb443505c0661c5b58294ef472baf64";
	NSString *secretKey = @"054a431c8cd9c3cf819f3bc7aba592cc84c09ff7";
	NSArray *groupIds = [NSArray arrayWithObject:[NSNumber numberWithInt:32]];
	
	NSData *imageData = [NSData dataWithContentsOfFile:@"lena.jpg"];
	KooabaQuery *query = [[KooabaQuery alloc] initWithImageData:imageData type:@"jpeg"];
	query.accessKey = accessKey;
	query.secretKey = secretKey;
	query.groupIds = groupIds;
	NSString *response = [query create];
	NSLog(@"response:\n%@", response);
	
    [pool drain];
    return 0;
}
