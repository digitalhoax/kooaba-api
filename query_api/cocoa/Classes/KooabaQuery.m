//
//  KooabaQuery.m
//  kooabaQuerySample
//
//  Created by Joachim Fornallaz on 02.11.09.
//  Copyright 2009-2011 kooaba AG. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. 
//

#import "KooabaQuery.h"

#import "NSData+Base64.h"
#include <CommonCrypto/CommonDigest.h>

// Creates a HTTP-compliant date/time format
NSString * HttpDate(void) {
	NSDate* date = [NSDate date];
	NSLocale *usLocale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease];
	NSDateFormatter* formatter = [[[NSDateFormatter alloc] init] autorelease];
	formatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
	formatter.dateFormat = @"EEE',' dd MMM yyyy HH':'mm':'ss 'GMT'";
	formatter.locale = usLocale; // always set the US locale since on non-US systems the string might come out wrong 
	return [formatter stringFromDate:date];
}

// Calculates the MD5 hash of some data and returns its hexadecimal representation as string
NSString * MD5HexDigest(NSData *data) {
	uint8_t result[CC_MD5_DIGEST_LENGTH];
	CC_MD5([data bytes], [data length], result);
	NSMutableString *hexDigest = [NSMutableString string];
	for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
		[hexDigest appendFormat:@"%02x", result[i]];
	return hexDigest;
}

// Calculates the SHA1 hash of a string and returns the raw digest
NSData * SHA1Digest(NSString *inputString) {
	NSData *inputData = [inputString dataUsingEncoding:NSASCIIStringEncoding];
	uint8_t sha1DigestBytes[CC_SHA1_DIGEST_LENGTH];
	CC_SHA1(inputData.bytes, inputData.length, sha1DigestBytes);
	NSData *sha1RawDigest = [NSData dataWithBytes:sha1DigestBytes length:CC_SHA1_DIGEST_LENGTH];
	return sha1RawDigest;
}


@interface KooabaQuery (/* Private */)

@property(nonatomic, retain) NSData *imageData;
@property(nonatomic, copy) NSString *imageType;

@end


@implementation KooabaQuery

@synthesize accessKey, secretKey, groupIds, location;
@synthesize imageData, imageType; /* Private */

#pragma mark -
#pragma mark Object lifecycle

- (id)initWithImageData:(NSData *)data type:(NSString *)type
{
	self = [super init];
	if (self != nil) {
		self.imageData = data;
		self.imageType = type;
		self.groupIds = [NSArray array];
	}
	return self;
}

- (void)dealloc
{
	[accessKey release];
	[secretKey release];
	[imageData release];
	[imageType release];
	[groupIds release];
	[location release];
	[super dealloc];
}

#pragma mark -
#pragma mark Private methods

- (NSData *)textPart:(NSString *)text forKey:(NSString *)key boundary:(NSString *)boundary
{
	NSMutableData *part = [NSMutableData data];
	[part appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSASCIIStringEncoding]];
	[part appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n%@\r\n", key, text] dataUsingEncoding:NSASCIIStringEncoding]];
	return part;
}

- (NSData *)multipartFormDataWithBoundary:(NSString *)boundary
{
	NSMutableData *body = [NSMutableData data];
	// Image data part
	[body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSASCIIStringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"query[file]\"; filename=\"query.%@\"\r\n", imageType] dataUsingEncoding:NSASCIIStringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"Content-Type: image/%@\r\n", imageType] dataUsingEncoding:NSASCIIStringEncoding]];
	[body appendData:[@"Content-Transfer-Encoding: binary\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
	[body appendData:[@"\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
	[body appendData:imageData];
	[body appendData:[@"\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
	// Group ID parts
	for (NSNumber *groupId in self.groupIds) {
		[body appendData:[self textPart:[groupId stringValue] forKey:@"query[group_ids][]" boundary:boundary]];
	}
	// Location parts
	if (self.location) {
		[body appendData:[self textPart:[NSString stringWithFormat:@"%f", location.coordinate.latitude] forKey:@"query[latitude]" boundary:boundary]];
		[body appendData:[self textPart:[NSString stringWithFormat:@"%f", location.coordinate.longitude] forKey:@"query[longitude]" boundary:boundary]];
	}
	// End of boundary
	[body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSASCIIStringEncoding]];
	return body;
}

#pragma mark -
#pragma mark Instance methods

- (NSString *)create
{
	NSURL *queriesURL = [NSURL URLWithString:@"http://search.kooaba.com/queries.xml"];
	NSString *contentType = @"multipart/form-data";	
	NSString *httpMethod = @"POST";
	NSString *boundary = [NSString stringWithFormat:@"%d", arc4random() % 999999];	

	NSData *contentData = [self multipartFormDataWithBoundary:boundary];

	// calculate KWS authorization signature
	NSString *contentMD5 = MD5HexDigest(contentData);
	NSString *dateValue = HttpDate();
	NSString *stringToSign = [NSString stringWithFormat:@"%@\n\n%@\n%@\n%@\n%@\n%@", secretKey, httpMethod, contentMD5, contentType, dateValue, queriesURL.path];
	NSString *signature = [SHA1Digest(stringToSign) base64EncodedString]; // NSData+Base64 category from Matt Gallagher, http://cocoawithlove.googlepages.com/NSData_Base64.zip
	
	// request header values
	NSString *authorizationValue = [NSString stringWithFormat:@"KWS %@:%@", accessKey, signature];
	NSString *contentTypeValue = [NSString stringWithFormat:@"%@; boundary=%@", contentType, boundary];
	
	// create the request object
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:queriesURL];
	[request setHTTPMethod:httpMethod];
	[request addValue:contentTypeValue forHTTPHeaderField:@"Content-Type"];
	[request addValue:authorizationValue forHTTPHeaderField:@"Authorization"];
	[request addValue:dateValue forHTTPHeaderField:@"Date"];
	[request setHTTPBody:contentData];
	
	// send the request
	NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
	
	return [returnString autorelease];
}

@end
