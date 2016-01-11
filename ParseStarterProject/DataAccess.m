//
//  DataAccess.m
//  ParseStarterProject
//
//  Created by Aditya Narayan on 1/8/16.
//
//

#import "DataAccess.h"

@implementation DataAccess

-(instancetype)init {
  self = [super init];
  
  _parse = [[ParseAccess alloc] init];
  UIImage *image = [UIImage imageNamed:@"default.png"];
  //[_parse signup:@"django" withPassword:@"django" withAvatar:image withFullName:@"Django"];
  [_parse login:@"patrick" withPassword:@"patrick"];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(loggedInNotification:)
                                               name:@"LoginSuccess"
                                             object:nil];
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(logoutNotification:)
                                               name:@"LogoutSuccess"
                                             object:nil];
  return self;
}

- (void)loggedInNotification:(NSNotification*)notification{
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(receiveTestNotification:)
                                               name:@"UpdateDataParse"
                                             object:nil];
  [_parse getImagesWithLimit:10];
}

- (void)logoutNotification:(NSNotification*)notification{
  _images = nil;
  NSLog(@"Logout");
}

- (void)receiveTestNotification:(NSNotification*)notification{
  NSLog(@"NSNotify: %@ updated",[notification.userInfo valueForKey:@"update"]);
  _images = [_parse getLocalImages];
}

@end
