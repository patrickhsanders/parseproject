//
//  DataAccess.h
//  ParseStarterProject
//
//  Created by Aditya Narayan on 1/8/16.
//
//

#import <Foundation/Foundation.h>
#import "ParseAccess.h"

@interface DataAccess : NSObject

@property (nonatomic, strong) ParseAccess *parse;
@property (nonatomic, strong) NSMutableArray *images;
@property (nonatomic, strong) NSMutableDictionary *users;

@end
