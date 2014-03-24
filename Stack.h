// Created by Zackery Leman on 2/13/14.
//  Stack.h
//
//  Copyright (c) 2014 All rights reserved.
//

#import <Foundation/Foundation.h>
#import "List.h"

@interface Stack : NSObject

@property (nonatomic, strong) List *stack;
- (void)push:(id)anObject;
- (id)pop;
- (id)peek;
- (BOOL)isEmpty;
- (int)size;
@end

//test kitchen