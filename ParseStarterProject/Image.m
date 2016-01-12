//
//  Image.m
//  ParseStarterProject
//
//  Created by Aditya Narayan on 1/8/16.
//
//

#import "Image.h"

@implementation Image

-(NSString*)description{
  return [NSString stringWithFormat:@"\n Image ID: %@ \n Image Owner: %@ \nActivities: %@", _imageId, _imageOwner, _activities];
}

@end
