// Created by Zackery Leman on 2/13/14.
//  Node.h
//  

//  Copyright (c) 2014 All rights reserved.
//Sets up a node object for the list


#import <Foundation/Foundation.h>

@interface Node : NSObject

@property (nonatomic) id data;
@property (nonatomic, strong) Node *next;

@end
