//
//  CurrentParkingDetails.h
//  Parker
//
//  Created by Tom Lee on 6/11/15.
//  Copyright (c) 2015 Tom Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CurrentParkingDetails : NSObject

@property (nonatomic) double latitue;
@property (nonatomic) double longitude;
@property (strong, nonatomic) NSString* zipcode;

@end
