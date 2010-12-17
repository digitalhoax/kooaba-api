//
//  KooabaQuery.h
//  kooabaQuerySample
//
//  Created by Joachim Fornallaz on 02.11.09.
//  Copyright 2009 kooaba AG. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. 
//

#import <Foundation/Foundation.h>


@interface KooabaQuery : NSObject {
	NSData *imageData;
	NSString *imageType;
	NSArray *groupIds;
	NSString *accessKey;
	NSString *secretKey;
	BOOL match;
}

@property(nonatomic, copy) NSArray *groupIds;
@property(nonatomic, copy) NSString *accessKey;
@property(nonatomic, copy) NSString *secretKey;

- (id)initWithImageData:(NSData *)data type:(NSString *)type;
- (NSString *)create;
- (NSData *)textPart:(NSString *)text forKey:(NSString *)key boundary:(NSString *)boundary;

@end
