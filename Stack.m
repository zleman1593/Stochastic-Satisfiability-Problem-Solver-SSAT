// Created by Zackery Leman on 2/13/14.
//  Stack.m
//  Copyright (c) 2014. All rights reserved.
//

#import "Stack.h"

@implementation Stack

- (id)init
{
    if (self = [super init]) {
        self.stack = [[List alloc] init];
    }
    return self;
}


- (void)push:(id)anObject {
    [self.stack addToHead:anObject];
}
- (id)pop {
    return [self.stack removeFromHead];
}
- (id)peek {
    return [self.stack getHeadData];
}
- (BOOL)isEmpty {
    return [self.stack isEmpty];
}
- (int)size {
    return [self.stack size];
}

@end

//Also test