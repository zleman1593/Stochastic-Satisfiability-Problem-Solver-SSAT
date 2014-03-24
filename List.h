//Created by Zackery Leman on 2/13/14.
//  List.h
//  Copyright (c) 2014 All rights reserved.
//Sets up the list data structure


#import <Foundation/Foundation.h>
#import "Node.h"

@interface List : NSObject

@property (nonatomic, strong) Node *head;
@property (nonatomic, strong) Node *tail;
@property int count;

- (void)addToHead:(id)anObject;
- (void)addToTail:(id)anObject;
- (id)removeFromHead;
- (id)removeFromTail;
- (void) clear;
- (int) size;
- (id) getHeadData;
- (id) getTailData;
- (BOOL)isEmpty;

@end

//Monley