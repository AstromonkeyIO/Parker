//
//  ViewController.h
//  Parker
//
//  Created by Tom Lee on 6/4/15.
//  Copyright (c) 2015 Tom Lee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <MapKit/MKAnnotation.h>


@interface ViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *parkButton;
@property (weak, nonatomic) IBOutlet UIButton *currentLocationButton;
@property (weak, nonatomic) IBOutlet UILabel *currentLocationButtonContainer;
@property (weak, nonatomic) IBOutlet UIButton *parkingAddressButton;
@property (weak, nonatomic) IBOutlet UILabel *parkButtonContainer;
@property (weak, nonatomic) IBOutlet UIButton *menuButton;
@property (weak, nonatomic) IBOutlet UILabel *menuButtonContainer;
@property (weak, nonatomic) IBOutlet UIButton *parkingLocationDetailAddButton;
@property (weak, nonatomic) IBOutlet UITextView *parkingLocationDetailTextView;
@property (weak, nonatomic) IBOutlet UIView *popup;
@property (weak, nonatomic) IBOutlet UITextView *popupText;
@property (weak, nonatomic) IBOutlet UIButton *popupNevermindButton;
@property (weak, nonatomic) IBOutlet UIButton *popupSaveSpotButton;
@property (weak, nonatomic) IBOutlet UIView *parkingSpotSavedSuccessMessage;



@end

