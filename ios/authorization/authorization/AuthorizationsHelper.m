//
//  AuthorizationsHelper.m
//  react_native_packages
//
//  Created by RuweiLi on 2017/8/21.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import "AuthorizationsHelper.h"
#import <objc/runtime.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreLocation/CoreLocation.h>

#define Authorized @"Authorized"
#define AuthorizedAlways @"AuthorizedAlways"
#define AuthorizedWhenInUse @"AuthorizedWhenInUse"
#define Denied @"Denied"
#define NotDetermined @"NotDetermined"
#define Restricted @"Restricted"

const void *LocationManagerObjKey = @"LocationManagerObjKey";

typedef NS_ENUM(NSInteger,AuthorizationType) {
  CAMERA = 0,
  LIBRARY,
  MIKE,
  ALWAYSLOCATION,
  USELOCATION,
  LOCATION = USELOCATION,
};

@interface AuthorizationsHelper ()<CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
@end

@implementation AuthorizationsHelper

- (NSDictionary *)constantsToExport {
  return @{ @"LIBRARY": @(LIBRARY),
            @"CAMERA" : @(CAMERA),
            @"MIKE" : @(MIKE),
            @"LOCATION" : @(LOCATION),
            @"ALWAYSLOCATION": @(ALWAYSLOCATION),
            @"USELOCATION" : @(USELOCATION)};
}

- (CLLocationManager *)locationManager {
  if (!_locationManager) {
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
  }
  return _locationManager;
}

RCT_EXPORT_MODULE(AuthorizationsHelper);

RCT_EXPORT_METHOD(check:(NSInteger)type
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  
  NSMutableDictionary *obj = [NSMutableDictionary dictionary];
  obj[@"resolve"] = resolve;
  obj[@"reject"] = reject;
  
  switch (type) {
    case LIBRARY:
      [self performSelectorOnMainThread:@selector(checkPhotoLibrary:) withObject:obj waitUntilDone:YES];
      break;
    case CAMERA:
    {
      obj[@"MediaType"] = AVMediaTypeVideo;
      [self performSelectorOnMainThread:@selector(checkVideoOrAudio:) withObject:obj waitUntilDone:YES];
    }
      break;
    case MIKE:
    {
      obj[@"MediaType"] = AVMediaTypeAudio;
      [self performSelectorOnMainThread:@selector(checkVideoOrAudio:) withObject:obj waitUntilDone:YES];
    }
      break;
    case ALWAYSLOCATION:
    {
      obj[@"type"] = @"Always";
      [self performSelectorOnMainThread:@selector(checkLocation:) withObject:obj waitUntilDone:YES];
    }
      break;
    case USELOCATION:
    {
      obj[@"type"] = @"InUse";
      [self performSelectorOnMainThread:@selector(checkLocation:) withObject:obj waitUntilDone:YES];
    }
      break;
      break;
    default:
      break;
  }
}


- (void)checkPhotoLibrary:(NSDictionary *)obj {
  __block RCTPromiseResolveBlock resolve = obj[@"resolve"];
  
  PHAuthorizationStatus photoAuthorStatus = [PHPhotoLibrary authorizationStatus];
  switch (photoAuthorStatus) {
    case PHAuthorizationStatusAuthorized:
      resolve(Authorized);
      break;
    case PHAuthorizationStatusDenied:
      resolve(Denied);
      break;
    case PHAuthorizationStatusNotDetermined:
    {
      [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusAuthorized) {
          resolve(Authorized);
        }else{
          resolve(Denied);
        }
      }];
    }
      break;
    case PHAuthorizationStatusRestricted:
      resolve(Restricted);
      break;
    default:
      break;
  }
}


- (void)checkVideoOrAudio:(NSDictionary *)obj {
  __block RCTPromiseResolveBlock resolve = obj[@"resolve"];
  NSString *type = obj[@"MediaType"];
  
  AVAuthorizationStatus AVstatus = [AVCaptureDevice authorizationStatusForMediaType:type];
  switch (AVstatus) {
    case AVAuthorizationStatusAuthorized:
      resolve(Authorized);
      break;
    case AVAuthorizationStatusDenied:
      resolve(Denied);
      break;
    case AVAuthorizationStatusNotDetermined:
    {
      [AVCaptureDevice requestAccessForMediaType:type completionHandler:^(BOOL granted) {        if (granted) {
          resolve(Authorized);
        }else{
          resolve(Denied);
        }
      }];
    }
      break;
    case AVAuthorizationStatusRestricted:
      resolve(Restricted);
      break;
    default:
      break;
  }
}

- (void)checkLocation:(NSDictionary *)obj {
  __block RCTPromiseResolveBlock resolve = obj[@"resolve"];
  
  CLAuthorizationStatus CLstatus = [CLLocationManager authorizationStatus];
  switch (CLstatus) {
    case kCLAuthorizationStatusAuthorizedAlways:
      resolve(AuthorizedAlways);
      break;
    case kCLAuthorizationStatusAuthorizedWhenInUse:
      resolve(AuthorizedWhenInUse);
      break;
    case kCLAuthorizationStatusDenied:
      resolve(Denied);
      break;
    case kCLAuthorizationStatusNotDetermined:
    {
      objc_setAssociatedObject(self.locationManager, LocationManagerObjKey, obj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
      if ([obj[@"type"] isEqualToString:@"Always"]) {
        [self.locationManager requestAlwaysAuthorization];
      } else {
        [self.locationManager requestWhenInUseAuthorization];
      }
    }
      break;
    case kCLAuthorizationStatusRestricted:
      resolve(Restricted);
      break;
    default:
      break;
  }
}


#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
  NSDictionary *obj = objc_getAssociatedObject(manager, LocationManagerObjKey);
  
  if ([obj isKindOfClass:[NSDictionary class]]) {
    
    __block RCTPromiseResolveBlock resolve = obj[@"resolve"];
    
    switch (status) {
      case kCLAuthorizationStatusAuthorizedAlways:
        resolve(AuthorizedAlways);
        break;
      case kCLAuthorizationStatusAuthorizedWhenInUse:
        resolve(AuthorizedWhenInUse);
        break;
      case kCLAuthorizationStatusDenied:
        resolve(Denied);
        break;
      case kCLAuthorizationStatusRestricted:
        resolve(Restricted);
        break;
      default:
        break;
    }
  }
}
@end
