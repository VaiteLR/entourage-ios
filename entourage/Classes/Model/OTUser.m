//
//  OTUser.m
//  entourage
//
//  Created by Hugo Schouman on 10/10/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import "OTUser.h"

#import "NSDictionary+Parsing.h"

static NSString *const kKeySid = @"sid";
static NSString *const kKeyEmail = @"email";
static NSString *const kKeyToken = @"token";

@implementation OTUser

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	if (self)
	{
		_sid = [dictionary numberForKey:kKeySid];
		_email = [dictionary stringForKey:kKeyEmail];
		_token = [dictionary stringForKey:kKeyToken];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
	// Encode properties, other class variables, etc
	[encoder encodeObject:self.sid forKey:kKeySid];
	[encoder encodeObject:self.email forKey:kKeyEmail];
	[encoder encodeObject:self.token forKey:kKeyToken];
}

- (id)initWithCoder:(NSCoder *)decoder
{
	if ((self = [super init]))
	{
		// decode properties, other class vars
		self.sid = [decoder decodeObjectForKey:kKeySid];
		self.email = [decoder decodeObjectForKey:kKeyEmail];
		self.token = [decoder decodeObjectForKey:kKeyToken];
	}
	return self;
}

@end
