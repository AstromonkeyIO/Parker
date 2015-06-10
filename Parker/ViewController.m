//
//  ViewController.m
//  Parker
//
//  Created by Tom Lee on 6/4/15.
//  Copyright (c) 2015 Tom Lee. All rights reserved.
//

#import "ViewController.h"
#define METERS_PER_MILE 1609.344

@interface ViewController ()

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) CLGeocoder* geocoder;
@property (strong, nonatomic) NSString* currentParkingState;
@property (strong, nonatomic) MKPointAnnotation* currentParkingAnnotation;



@end

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)


@implementation ViewController

- (void) viewWillAppear:(BOOL)animated
{
    
    if(self.locationManager)
    {
        [self.locationManager startUpdatingLocation];
        [self deviceLocation];
    }

    NSLog(@"%@", [self deviceLocation]);
    
    //self.parkButton.layer.shadowRadius = 3.0f;
    //self.parkButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.menuButtonContainer.layer.borderWidth=1.0f;
    self.menuButtonContainer.layer.borderColor= [[UIColor colorWithRed: 169/255.0 green: 169/255.0 blue: 169/255.0 alpha:0.5] CGColor];
    
    self.parkButtonContainer.layer.borderWidth=1.0f;
    self.parkButtonContainer.layer.borderColor= [[UIColor colorWithRed: 169/255.0 green: 169/255.0 blue: 169/255.0 alpha:0.5] CGColor];

    self.currentLocationButtonContainer.layer.borderWidth=1.0f;
    self.currentLocationButtonContainer.layer.borderColor= [[UIColor colorWithRed: 169/255.0 green: 169/255.0 blue: 169/255.0 alpha:0.5] CGColor];
    
    CGPoint saveCenter = self.parkButton.center;
    CGRect newFrame = CGRectMake(self.parkButton.frame.origin.x, self.parkButton.frame.origin.y, 120, 120);
    self.parkButton.frame = newFrame;
    self.parkButton.layer.cornerRadius = 120 / 2.0;
    self.parkButton.center = saveCenter;
    self.parkButton.clipsToBounds = YES;
    
    CGPoint saveCenter1 = self.parkButtonContainer.center;
    CGRect newFrame1 = CGRectMake(self.parkButtonContainer.frame.origin.x, self.parkButtonContainer.frame.origin.y, 136, 136);
    self.parkButtonContainer.frame = newFrame1;
    self.parkButtonContainer.layer.cornerRadius = 136 / 2.0;
    self.parkButtonContainer.center = saveCenter1;
    self.parkButtonContainer.clipsToBounds = YES;
    
    
    CGPoint saveCenter2 = self.currentLocationButton.center;
    CGRect newFrame2 = CGRectMake(self.currentLocationButton.frame.origin.x, self.currentLocationButton.frame.origin.y, 46, 46);
    self.currentLocationButton.frame = newFrame2;
    self.currentLocationButton.layer.cornerRadius = 46 / 2.0;
    self.currentLocationButton.center = saveCenter2;
    self.currentLocationButton.clipsToBounds = YES;
    
    CGPoint saveCenter3 = self.currentLocationButtonContainer.center;
    CGRect newFrame3 = CGRectMake(self.currentLocationButtonContainer.frame.origin.x, self.currentLocationButtonContainer.frame.origin.y, 56, 56);
    self.currentLocationButtonContainer.frame = newFrame3;
    self.currentLocationButtonContainer.layer.cornerRadius = 56 / 2.0;
    self.currentLocationButtonContainer.center = saveCenter3;
    self.currentLocationButtonContainer.clipsToBounds = YES;
    
    CGPoint saveCenter4 = self.menuButton.center;
    CGRect newFrame4 = CGRectMake(self.menuButton.frame.origin.x, self.menuButton.frame.origin.y, 46, 46);
    self.menuButton.frame = newFrame4;
    self.menuButton.layer.cornerRadius = 46 / 2.0;
    self.menuButton.center = saveCenter4;
    self.menuButton.clipsToBounds = YES;
    
    CGPoint saveCenter5 = self.menuButtonContainer.center;
    CGRect newFrame5= CGRectMake(self.menuButtonContainer.frame.origin.x, self.menuButtonContainer.frame.origin.y, 56, 56);
    self.menuButtonContainer.frame = newFrame5;
    self.menuButtonContainer.layer.cornerRadius = 56 / 2.0;
    self.menuButtonContainer.center = saveCenter5;
    self.menuButtonContainer.clipsToBounds = YES;
    
    
}

- (void) viewDidLoad
{
    
    [super viewDidLoad];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.geocoder = [[CLGeocoder alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest; // setting the accuracy

#ifdef __IPHONE_8_0
    if(IS_OS_8_OR_LATER) {
        // Use one or the other, not both. Depending on what you put in info.plist
        [self.locationManager requestWhenInUseAuthorization];
        [self.locationManager requestAlwaysAuthorization];
    }
#endif
    [self.locationManager startUpdatingLocation];
    
    [_mapView setDelegate:self];
    _mapView.showsUserLocation = YES;

    
    self.parkingLocationDetailTextView.delegate = self;
    
    self.currentParkingAnnotation = [[MKPointAnnotation alloc] init];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary* savedCurrentParkingCoordinates = [defaults objectForKey:@"savedCurrentParkingCoordinates"];
    
    if(savedCurrentParkingCoordinates)
    {
        

        CLLocationCoordinate2D annotationCoord;
        NSNumber* latitude = savedCurrentParkingCoordinates[@"latitude"];
        NSNumber* longitude = savedCurrentParkingCoordinates[@"longitude"];
        
        annotationCoord.latitude = (CLLocationDegrees)[latitude doubleValue];
        annotationCoord.longitude = (CLLocationDegrees)[longitude doubleValue];
        self.currentParkingAnnotation.coordinate = annotationCoord;
        [_mapView addAnnotation:self.currentParkingAnnotation];
        
        self.currentParkingState = @"parked";
        [self.parkButton setTitle:@"LEAVE" forState:UIControlStateNormal];
        [self.parkButton setBackgroundColor:[UIColor colorWithRed:255/255.0 green:49/255.0 blue:47/255.0 alpha:1]];
        
        self.parkingAddressButton.hidden = NO;
        self.parkingLocationDetailAddButton.hidden = NO;
        
        self.parkingLocationDetailTextView.text = savedCurrentParkingCoordinates[@"detail"];
        
        [self.parkingAddressButton setTitle:@"Searching Location..." forState:UIControlStateNormal];
        
        CLLocation *parkingLocation = [[CLLocation alloc] initWithLatitude:self.currentParkingAnnotation.coordinate.latitude longitude:self.currentParkingAnnotation.coordinate.longitude];
        [self.geocoder reverseGeocodeLocation:parkingLocation completionHandler:^(NSArray *placemarks, NSError *error) {
            NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
            if (error == nil && [placemarks count] > 0) {
                CLPlacemark* placemark = [placemarks lastObject];
                NSString* parkingAddressString = [NSString stringWithFormat:@"%@ %@", placemark.subThoroughfare, placemark.thoroughfare];
                [self.parkingAddressButton setTitle:parkingAddressString forState:UIControlStateNormal];
                
            } else {
                NSLog(@"%@", error.debugDescription);
            }
        } ];
        
        
        
        
    }
    else
    {
        
        self.currentParkingState = @"unparked";
        
    }
    
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
/*
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 800, 800);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
*/
    /*
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.005;
    span.longitudeDelta = 0.005;
    CLLocationCoordinate2D location;
    location.latitude = userLocation.coordinate.latitude;
    location.longitude = userLocation.coordinate.longitude;
    region.span = span;
    region.center = location;
    [_mapView setRegion:region animated:YES];
    */
    
    /*
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = userLocation.coordinate.latitude;
    zoomLocation.longitude= userLocation.coordinate.longitude;
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 1*METERS_PER_MILE, 1*METERS_PER_MILE);
    //MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 1, 1);
    [_mapView setRegion:viewRegion animated:YES];
    */
    
    /*
    MKCoordinateRegion region;
    region.center = userLocation.location.coordinate;
    region.span = MKCoordinateSpanMake(2.0, 2.0); //Zoom distance
    region = [self.mapView regionThatFits:region];
    [self.mapView setRegion:region animated:YES];
    */
    
    
}

- (NSString *)deviceLocation {
 
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = self.locationManager.location.coordinate.latitude;
    zoomLocation.longitude= self.locationManager.location.coordinate.longitude;
    //MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 1*METERS_PER_MILE, 1*METERS_PER_MILE);
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 1000, 1000);
    [_mapView setRegion:viewRegion animated:YES];
    return [NSString stringWithFormat:@"latitude: %f longitude: %f", self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude];
    
    
    
    
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    /*
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = currentLocation.coordinate.latitude;
    zoomLocation.longitude= currentLocation.coordinate.longitude;
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 1000, 1000);
    [_mapView setRegion:viewRegion animated:YES];
    */

}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    
    MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:overlay];
    polylineView.strokeColor = [UIColor purpleColor];
    polylineView.lineWidth = 5.0;
    return polylineView;
    
}


- (IBAction)parkButtonPressed:(id)sender
{
    
    if([self.currentParkingState isEqualToString:@"unparked"])
    {
        
        CLLocationCoordinate2D annotationCoord;
        annotationCoord.latitude = self.locationManager.location.coordinate.latitude;
        annotationCoord.longitude = self.locationManager.location.coordinate.longitude;
        self.currentParkingAnnotation.coordinate = annotationCoord;
        [_mapView addAnnotation:self.currentParkingAnnotation];
        
        
        NSDictionary* savedCurrentParkingCoordinates = @{ @"latitude" : [ NSNumber numberWithDouble: self.locationManager.location.coordinate.latitude], @"longitude" : [NSNumber numberWithDouble: self.locationManager.location.coordinate.longitude]};
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:savedCurrentParkingCoordinates forKey:@"savedCurrentParkingCoordinates"];
        [defaults synchronize];
        
        
        self.currentParkingState = @"parked";
        [self.parkButton setTitle:@"LEAVE" forState:UIControlStateNormal];
        [self.parkButton setBackgroundColor:[UIColor colorWithRed:255/255.0 green:49/255.0 blue:47/255.0 alpha:1]];
 
        self.parkingAddressButton.hidden = NO;
        self.parkingLocationDetailAddButton.hidden = NO;
        [self.parkingAddressButton setTitle:@"Searching Location..." forState:UIControlStateNormal];
        [self.geocoder reverseGeocodeLocation:self.locationManager.location completionHandler:^(NSArray *placemarks, NSError *error) {
            NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
            if (error == nil && [placemarks count] > 0) {
                CLPlacemark* placemark = [placemarks lastObject];
                
                NSString* parkingAddressString = [NSString stringWithFormat:@"%@ %@", placemark.subThoroughfare, placemark.thoroughfare];
                [self.parkingAddressButton setTitle:parkingAddressString forState:UIControlStateNormal];
                
            } else {
                NSLog(@"%@", error.debugDescription);
            }
        } ];
        
        
    }
    else
    {
        
        [self.mapView removeAnnotation:self.currentParkingAnnotation];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"savedCurrentParkingCoordinates"];
        //[[NSUserDefaults] synchronize];
        [self.mapView removeOverlays:self.mapView.overlays];
        
        self.currentParkingState = @"unparked";
        [self.parkButton setTitle:@"PARK" forState:UIControlStateNormal];
        [self.parkButton setBackgroundColor:[UIColor colorWithRed:109/255.0 green:255/255.0 blue:171/255.0 alpha:1]];
        [self.parkingAddressButton setTitle:@"" forState:UIControlStateNormal];
        self.parkingAddressButton.hidden = YES;
        
        self.parkingLocationDetailTextView.text = @"";
        self.parkingLocationDetailAddButton.hidden = YES;
        
        self.parkingLocationDetailTextView.hidden = YES;
        
    }
    
}

- (IBAction)currentLocationButtonPressed:(id)sender
{

    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = self.locationManager.location.coordinate.latitude;
    zoomLocation.longitude= self.locationManager.location.coordinate.longitude;
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 1000, 1000);
    [_mapView setRegion:viewRegion animated:YES];
    
    
}

- (IBAction)parkingAddressButtonPressed:(id)sender {
    

    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = self.currentParkingAnnotation.coordinate.latitude;
    zoomLocation.longitude= self.currentParkingAnnotation.coordinate.longitude;
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 1000, 1000);
    [_mapView setRegion:viewRegion animated:YES];

    CLLocationCoordinate2D coordinates[2];
    
    coordinates[0] = self.locationManager.location.coordinate;
    coordinates[1] = self.currentParkingAnnotation.coordinate;

    /*
    MKPolyline *polyLine = [MKPolyline polylineWithCoordinates:coordinates count:2];
    [_mapView addOverlay:polyLine];
    */
    MKDirectionsRequest *directionsRequest = [[MKDirectionsRequest alloc] init];
    CLPlacemark* thePlacemark;

    MKPlacemark *placemark = [[MKPlacemark alloc] initWithPlacemark:thePlacemark];
    [directionsRequest setSource:[MKMapItem mapItemForCurrentLocation]];
    
    CLLocation *parkingLocation = [[CLLocation alloc] initWithLatitude:self.currentParkingAnnotation.coordinate.latitude longitude:self.currentParkingAnnotation.coordinate.longitude];
    __block MKPlacemark* parkingLocationPlacemark;
                                   
                                   
    [self.geocoder reverseGeocodeLocation:parkingLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
        
        
        if (error == nil && [placemarks count] > 0) {
          parkingLocationPlacemark = [placemarks lastObject];
          [directionsRequest setDestination:[[MKMapItem alloc] initWithPlacemark:parkingLocationPlacemark]];
            directionsRequest.transportType = MKDirectionsTransportTypeAutomobile;
            MKDirections *directions = [[MKDirections alloc] initWithRequest:directionsRequest];
            
            
            
            [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
                
                if(!error)
                {
                   
                    MKRoute *routeDetails;
                    routeDetails = response.routes.lastObject;
                    [self.mapView addOverlay:routeDetails.polyline];
                    
                }
                
            
            }];
                

            
            /**
            [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
                if (error) {
                    NSLog(@"Error %@", error.description);
                } else {
                    
                    
                    MKRoute *routeDetails;
                    routeDetails = response.routes.lastObject;
                    [self.mapView addOverlay:routeDetails.polyline];
                    
                    
                    
                    /*
                    self.destinationLabel.text = [placemark.addressDictionary objectForKey:@"Street"];
                    self.distanceLabel.text = [NSString stringWithFormat:@"%0.1f Miles", routeDetails.distance/1609.344];
                    self.transportLabel.text = [NSString stringWithFormat:@"%u" ,routeDetails.transportType];
                    self.allSteps = @"";
                    for (int i = 0; i < routeDetails.steps.count; i++) {
                        MKRouteStep *step = [routeDetails.steps objectAtIndex:i];
                        NSString *newStep = step.instructions;
                        self.allSteps = [self.allSteps stringByAppendingString:newStep];
                        self.allSteps = [self.allSteps stringByAppendingString:@"\n\n"];
                        self.steps.text = self.allSteps;
                    }
             
             
                }
            }];
             */
            
        
            
        } else {
            NSLog(@"%@", error.debugDescription);
        }
    } ];
    
}

- (IBAction)parkingLocationDetailAddButtonPressed:(id)sender {
    
    //CGRect frame = self.textView.frame;
    
    if([self.parkingLocationDetailAddButton.titleLabel.text isEqualToString:@"+"])
    {
        
        [self.parkingLocationDetailAddButton setTitle:@"-" forState:UIControlStateNormal];
        
        self.parkingLocationDetailTextView.hidden = NO;
        
        CGRect textFrame = self.parkingLocationDetailTextView.frame;
        textFrame.size.height = 600;
        self.parkingLocationDetailTextView.frame = textFrame;
        
        if(self.parkingLocationDetailTextView.text.length == 0)
        {
            
            [self.parkingLocationDetailTextView becomeFirstResponder];
            
        }
        
    }
    else
    {
        
        [self.parkingLocationDetailAddButton setTitle:@"+" forState:UIControlStateNormal];
        
        [self.parkingLocationDetailTextView resignFirstResponder];
        self.parkingLocationDetailTextView.hidden = YES;
        

        if(self.parkingLocationDetailTextView.text.length > 0)
        {
                
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                NSDictionary* savedCurrentParkingCoordinates = [defaults objectForKey:@"savedCurrentParkingCoordinates"];
                
                
                NSNumber* latitude = savedCurrentParkingCoordinates[@"latitude"];
                NSNumber* longitude = savedCurrentParkingCoordinates[@"longitude"];
                
                NSDictionary* newSavedCurrentParkingInfo = @{ @"latitude" : [ NSNumber numberWithDouble:[latitude doubleValue]], @"longitude" : [ NSNumber numberWithDouble:[longitude doubleValue]], @"detail" : self.parkingLocationDetailTextView.text};
                
                [defaults setObject:newSavedCurrentParkingInfo forKey:@"savedCurrentParkingCoordinates"];
                [defaults synchronize];
        }
 
    }

    
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        
        
        self.parkingLocationDetailTextView.hidden = YES;
        [self.parkingLocationDetailAddButton setTitle:@"+" forState:UIControlStateNormal];
        
        if(self.parkingLocationDetailTextView.text.length > 0)
        {
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSDictionary* savedCurrentParkingCoordinates = [defaults objectForKey:@"savedCurrentParkingCoordinates"];

            
            NSNumber* latitude = savedCurrentParkingCoordinates[@"latitude"];
            NSNumber* longitude = savedCurrentParkingCoordinates[@"longitude"];
            
            NSDictionary* newSavedCurrentParkingInfo = @{ @"latitude" : [ NSNumber numberWithDouble:[latitude doubleValue]], @"longitude" : [ NSNumber numberWithDouble:[longitude doubleValue]], @"detail" : self.parkingLocationDetailTextView.text};
            
            [defaults setObject:newSavedCurrentParkingInfo forKey:@"savedCurrentParkingCoordinates"];
            [defaults synchronize];
            
        }
        
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}




@end