//
//  Solver.h
//  SSAT Solver
//
//  Created by Zackery Leman on 2/13/14.
//  Copyright (c) 2014 Zackery Leman. All rights reserved.
//This algorithm solves SSAT problems in a specific .cnf format.
//It gives the probability of satisfaction and displays the
//possible branches (all possible combinations of literal assignments) of the assignment tree.


#import <Foundation/Foundation.h>
#import "Stack.h"
@interface Solvers : NSObject <NSCopying>

//Total number of literals in the SSAT problem
@property (nonatomic) int numberOfLiterals;

//A 2D array of clauses of the SSAT problem. (The first element of each clause array
//is the number of literal still relevant in the clause)
@property (nonatomic) NSMutableArray *clauses;
//A 2D array listing the clauses for which each literal appears in positively and negatively
@property (nonatomic) NSMutableArray *literalsInClauses;
//Stores the current literal assignments
@property (nonatomic) NSMutableArray *solution;
//Stores the  literal probabilities
@property (nonatomic) NSMutableArray *probability;
// Store which variables have yet to be assigned and preserves selection order
@property (strong, nonatomic) NSMutableArray *unassignedVariables;

//Designated initializer
- (id) initWithProblem:(NSMutableArray *)start numberOfLiterals:(int)numberOfLiterals;
//Checks if the problem after an assignment is unsatisfiable.
- (BOOL) unsat;
//Checks if the problem after an assignment is satisfiable.
- (BOOL) sat;
//Checks if the problem after an assignment causes a unit clause forcing a literal.
- (int) unitClause;
//Assigns a value to a literal
- (void)assign:(int)value;
//Propagates the effects of assigning a literal a value. (i.e Updates the relevant literal count of each clause).
- (void)updateClauses:(int)value;
//Deletes a satisfied clause from all association with any literal that was in it.
- (void)updateliteralsInAllClauses:(int)value;
//Checks if the literal is a choice variable
- (BOOL)isChoiceVariable:(int)value;
//gets the probability that the variable is true
- (double)probabilityIsTrue:(int)value;
//Finds and returns a pure variable if on exists. returns -1 if no pure variables.
- (int)identifyPureVariables;
//Returns the next literal to be assigned given the prescribed assignment order
- (int)getNextLiteral;
//Returns whether a literal is already assigned a value
- (BOOL) isAssigned:(int)check;
/*Takes an array and makes a deep copy of it which it returns*/
- (NSMutableArray*)miniDeepCopy:(NSMutableArray*)arrayToCopy;

//Methods for restoring the state of the data structures after exiting a recursive call

- (void)restoreSolutionArray:(int)value;
- (void)restoreAssignmentArray:(int)value;
- (NSMutableArray*)prepRestoreClauses;
- (void)restoreClauses:(NSMutableArray*)restoreArray;
- (void)restoreLiteralsInClauses;
//Stores the changes in the literalsInClauses array and undoes the changes when exiting a recursive call
@property (nonatomic) NSMutableArray *literalRestore;
@property (strong, nonatomic) Stack *clausesThatDropOut;
@property (nonatomic) NSMutableArray *globalTempArray;
@end
