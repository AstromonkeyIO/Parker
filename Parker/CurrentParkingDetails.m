//
//  CurrentParkingDetails.m
//  Parker
//
//  Created by Tom Lee on 6/11/15.
//  Copyright (c) 2015 Tom Lee. All rights reserved.
//

#import "CurrentParkingDetails.h"

@implementation CurrentParkingDetails

@synthesize latitude;
@synthesize longitude;
@synthesize zipcode;

- (id)initWithCoder:(NSCoder *)decoder
{
    
    if (self = [super init]) {
        self.latitude = [decoder decodeDoubleForKey:@"latitude"];
        self.longitude = [decoder decodeDoubleForKey:@"longitude"];
        self.zipcode = [decoder decodeObjectForKey:@"zipcode"];
    }
    return self;
    
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    
    [encoder encodeDouble:latitude forKey:@"latitude"];
    [encoder encodeDouble:longitude forKey:@"longitude"];
    [encoder encodeObject:zipcode forKey:@"zipcode"];
    
}

- (void)dealloc
{
    
}

@end
