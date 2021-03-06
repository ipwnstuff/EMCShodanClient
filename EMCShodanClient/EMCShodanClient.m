//
//  ECShodanClient.h
//  Erran Carey
//
//  Created by Erran Carey on 1/4/14.
//  Copyright (c) 2012-2014 Erran Carey. All rights reserved.
//

#import "ECShodanClient.h"

#pragma mark ECShodanClient
#pragma mark -

@implementation ECShodanClient

#pragma mark -
#pragma mark Properties
#pragma mark -

@synthesize apiKey;
@synthesize baseURL; // [todo] - Use a constant
@synthesize results;
@synthesize requestParameters;
@synthesize queryString;

#pragma mark -
#pragma mark Session Management Methods
#pragma mark -

- (id)initWithAPIKey:(NSString *)key {
    self = [super init];
    if (self) {
        apiKey = [key stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        baseURL = @"http://www.shodanhq.com/api/";
    }

    return self;
}

- (void)setAPIKey:(NSString *)key {
    apiKey = key;
}

#pragma mark -
#pragma mark Other Methods
#pragma mark -

- (void)request:(NSString *)function {
    requestParameters = @{
                             @"baseURL":  baseURL,
                             @"function": [function stringByAppendingFormat:@"?"],
                             @"apiKey":   [NSString stringWithFormat:@"key=%@", apiKey]
                         };

    NSURL* url = nil;
    NSString* url_string = @"";

// [review] - In iOS 5 and OS X 10.7 the NSDictionary ordering was different for each platform
#ifdef TARGET_OS_IPHONE
    url_string = [url_string stringByAppendingFormat:@"%@", baseURL];
    url_string = [url_string stringByAppendingFormat:@"%@", [function stringByAppendingFormat:@"?"]];
    url_string = [url_string stringByAppendingFormat:@"%@", [NSString stringWithFormat:@"key=%@", apiKey]];
#else
    for (id key in requestParameters) {
        url_string = [url_string stringByAppendingFormat:@"%@", [requestParameters objectForKey:key]];
    }
#endif

    if ([function isEqualToString:@"count"]) {
        url = [NSURL URLWithString:[url_string stringByAppendingFormat:@"&q=%@", queryString]];
    }
    else if ([function isEqualToString:@"host"]) {
        url = [NSURL URLWithString:[url_string stringByAppendingFormat:@"&ip=%@", queryString]];
    }
    else if ([function isEqualToString:@"info"]) {
        url = [NSURL URLWithString:url_string];
    }
    else if ([function isEqualToString:@"locations"]) {
        url = [NSURL URLWithString:[url_string stringByAppendingFormat:@"&q=%@", queryString]];
    }
    else if ([function isEqualToString:@"search"]) {
        url = [NSURL URLWithString:[url_string stringByAppendingFormat:@"&q=%@", queryString]];
    }

    NSError* error;
    NSData* searchResults = [NSData dataWithContentsOfURL:url];
    if (searchResults) {
        results = [NSJSONSerialization JSONObjectWithData:searchResults options:kNilOptions error:&error];
    }
    else {
        results = nil;
    }
}

#pragma mark -
#pragma mark Search Methods
#pragma mark -

- (NSDictionary *)count:(NSString *)query {
    queryString = [query stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    [self request:@"count"];
    return results;
}

- (NSDictionary *)host:(NSString *)hostname
{
    queryString = [hostname stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    [self request:@"host"];
    return results;
}

- (NSDictionary *)locations:(NSString *)query {
    queryString = [query stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    [self request:@"locations"];
    return results;
}

- (NSDictionary *)search:(NSString *)query {
    [self search:query page:1 limit:100 offset:0];
    return results;
}

- (NSDictionary *)search:(NSString *)query page:(int)pageNumber {
    [self search:query page:pageNumber limit:100 offset:0];
    return results;
}

- (NSDictionary *)search:(NSString *)query page:(int)pageNumber limit:(int)perPage {
    [self search:query page:pageNumber limit:perPage offset:0];
    return results;
}

- (NSDictionary *)search:(NSString *)query page:(int)pageNumber limit:(int)perPage offset:(int)pageOffset {
    query = [query stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    queryString = [query stringByAppendingString:[NSString stringWithFormat:@"&p=%i&l=%i&o=%i", pageNumber, perPage, pageOffset]];

    [self request:@"search"];
    return results;
}

#pragma mark -
#pragma mark Other API Methods
#pragma mark -

- (NSDictionary *)info {
    [self request:@"info"];
    return results;
}

@end
