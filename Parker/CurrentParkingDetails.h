//
//  CurrentParkingDetails.h
//  Parker
//
//  Created by Tom Lee on 6/11/15.
//  Copyright (c) 2015 Tom Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CurrentParkingDetails : NSObject <NSCoding> {
    
    double latitude;
    double longitude;
    NSString* zipcode;
    
}

@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (nonatomic ,copy) NSString* zipcode;

@end
