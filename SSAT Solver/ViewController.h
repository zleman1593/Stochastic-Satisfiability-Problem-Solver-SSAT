//
//  ViewController.h
//  SSAT Solver
//
//  Created by Zackery Leman on 2/13/14.
//  Copyright (c) 2014 Zackery Leman. All rights reserved.
//This algorithm solves SSAT problems in a specific .cnf format.
//It gives the probability of satisfaction and displays the
//possible branches (all possible combinations of literal assignments) of the assignment tree.

#define LOGPROGRES
#define LOGPROGRESS2
#import <UIKit/UIKit.h>
#import "Solvers.h"
@interface ViewController : UIViewController

//An instance of the solvers class.
@property (strong, nonatomic) Solvers *Solver;
@property (nonatomic) NSMutableArray *tempArray;
//A stack holding states that are created before going down a new branch.
// They are popped off after the recursion backtracks, allowing the state to be restored before going down another branch.
@property (strong, nonatomic) Stack *states;
//The main algorithm for solving the SSAT problem. Sets up the logic. The detailed processing methods are in the solvers class.
-(double)SOLVESSAT:(Solvers*)currentstate;
//Calls proper methods to restore the data structures' state
-(void)restoreState:(Solvers *)currentstate with:(int)value;
//Stores the count for each clause before a recursive call is made
@property (strong, nonatomic) Stack *clauseState;


//UI Elements
@property (weak, nonatomic) IBOutlet UILabel *result;
- (IBAction)start:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UITextView *otherfile;
@property (weak, nonatomic) IBOutlet UITextView *log;


@end
