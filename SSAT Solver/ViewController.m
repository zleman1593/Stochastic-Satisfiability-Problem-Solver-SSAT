//
//  ViewController.m
//  SSAT Solver
//
//  Created by Zackery Leman on 2/13/14.
//  Copyright (c) 2014 Zackery Leman. All rights reserved.
//This algorithm solves SSAT problems in a specific .cnf format.
//It gives the probability of satisfaction and displays the
//possible branches (all possible combinations of literal assignments) of the assignment tree.

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)start:(UIButton *)sender{
    self.states=[[Stack alloc]init];
    self.clauseState=[[Stack alloc]init];;
    self.tempArray=[[NSMutableArray alloc]init];
    //Extracts information from the data file
    NSString *fileName=self.otherfile.text;
    NSString* path = [[NSBundle mainBundle] pathForResource:fileName
                                                     ofType:@"ssat"];
    NSString *content = [NSString stringWithContentsOfFile:path
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];
    NSArray *contentPerLine= [content componentsSeparatedByString:@"\n"];
    
    //Parses input
    for (int i = 0; i < [contentPerLine count]; i++) {
        NSArray *listOfNumbers = [contentPerLine[i] componentsSeparatedByString:@"  "];
        NSMutableArray *finalArray=[listOfNumbers mutableCopy];
        [finalArray removeObject:[NSMutableString stringWithFormat:@"0"]];
        //This is just for the different file format of file test6.ssat
        [finalArray removeObject:[NSMutableString stringWithFormat:@"0\r"]];
        [finalArray removeObject:[NSMutableString stringWithFormat:@"\r"]];
        //
        [finalArray removeObject:[NSMutableString stringWithFormat:@""]];
        [self.tempArray addObject:finalArray];
        [self.tempArray  removeObject:[NSMutableString stringWithFormat:@""]];
        //This is just for the different file format of file test6.ssat
        [self.tempArray  removeObject:[NSMutableString stringWithFormat:@"\r"]];
        //
    }
    
    for (int i = 0; i < [self.tempArray count]; i++) {
        if([(NSMutableArray*)[self.tempArray objectAtIndex:i] count]==0){
            [self.tempArray removeObjectAtIndex:i];
            //Incase the next one that moves down and fill its spot is also zero
            i--;
        }
    }
    //Find the cnf line
    int cnfPosition=0;
    for (int i=0; i!=-1; i++) {
        if ([[self.tempArray[i] objectAtIndex:0] rangeOfString:@"p cnf" options:NSCaseInsensitiveSearch].location != NSNotFound)
        { cnfPosition=i;
            break;
        }
    }
    NSMutableString * problemInfo1=[self.tempArray[cnfPosition] objectAtIndex:0];
    NSArray *holder1 = [problemInfo1 componentsSeparatedByString:@" "];
    NSMutableArray *holdermutable1=[holder1 mutableCopy];
    int numberOfClauses= [holdermutable1[3] intValue];
    int numberOfLiterals=[holdermutable1[2] intValue];
    NSMutableArray *tempProbArray=[[NSMutableArray alloc] init];
    [tempProbArray addObject:@"0"];
    
    
    
    //Delete everything above first clause
    BOOL cont=YES;
    for ( int i=0; cont; i++) {
        if ([[self.tempArray[i] objectAtIndex:0] rangeOfString:@"c" options:NSCaseInsensitiveSearch].location != NSNotFound)
        {
            [self.tempArray removeObjectAtIndex:0];
            i--;
        }
        else{cont=NO;}
    }
    //Build the probabilities data structure
    for (int i=0; i<numberOfLiterals; i++) {
        [tempProbArray addObject:[[self.tempArray objectAtIndex:numberOfClauses+i] objectAtIndex:1 ]];
    }
    NSData *buffer= [NSKeyedArchiver archivedDataWithRootObject: tempProbArray];
    
    //Adds the count to the beginning of the clauses
    for (int i = 0; i < [self.tempArray count]; i++) {
        int count=[(NSMutableArray*)[self.tempArray objectAtIndex:i] count];
        [[self.tempArray objectAtIndex:i] insertObject:[NSMutableString stringWithFormat:@"%i", count] atIndex:0];
    }
    
    //Insert a dummy clause at position 0
    [self.tempArray insertObject:[NSMutableArray arrayWithObjects:@"0",@"0",@"0",nil] atIndex:0];
    
    //Trim off everything below the last clause
    NSRange deletion;
    deletion.length=[self.tempArray count]-numberOfClauses-1;
    deletion.location=numberOfClauses+1;
    [self.tempArray removeObjectsInRange:deletion];
    
    
    //Initialize the solver object with the initial clauses data structure
    self.Solver=[[Solvers alloc] initWithProblem:self.tempArray numberOfLiterals:numberOfLiterals];
    
    //Give the object the probabilities data structure
    [self.Solver setProbability:[NSKeyedUnarchiver unarchiveObjectWithData: buffer]];
    
    //Start the algorithm
    NSLog(@"Solution:");
    NSLog(@"Note: (literal)= branch is satisfied whether this literal is true or false ");
    double result=[self SOLVESSAT:self.Solver];
    //Display the results
    NSLog(@"Psat=( %f )", result);
     [self.result setText:[NSString stringWithFormat:@" Result: %f",result]];
}


-(double)SOLVESSAT:(Solvers*)currentstate{

    if ([currentstate unsat]) {
#ifdef LOGPROGRESS2
        int num=0;
        NSMutableString * branch=[[NSMutableString alloc] init];
        for (int i=1; i<[currentstate.solution count]; i++) {
            num=[currentstate.solution[i] intValue];
            
            if (num==1) {
                [branch appendString:[NSMutableString stringWithFormat:@"%i",i*-1]];
                
            } else if (num==-1){
                [branch appendString:[NSMutableString stringWithFormat:@"(%i)",i]];
                
            } else{
                [branch appendString:[NSMutableString stringWithFormat:@"%i",i]];
            }
            [branch appendString:[NSMutableString stringWithFormat:@" "]];
        }
        [branch appendString:[NSMutableString stringWithFormat:@"    0.0"]];
        NSLog(branch);
#endif
        return 0.0;
    }
    if ([currentstate sat]) {

#ifdef LOGPROGRESS2
        int num=0;
        NSMutableString * branch=[[NSMutableString alloc] init];
        for (int i=1; i<[currentstate.solution count]; i++) {
            num=[currentstate.solution[i] intValue];
            if (num==1) {
                [branch appendString:[NSMutableString stringWithFormat:@"%i",i*-1]];
            } else if (num==-1){
                [branch appendString:[NSMutableString stringWithFormat:@"(%i)",i]];
            } else{
                [branch appendString:[NSMutableString stringWithFormat:@"%i",i]];
            }
            [branch appendString:[NSMutableString stringWithFormat:@" "]];
        }
        [branch appendString:[NSMutableString stringWithFormat:@"    Satisfied"]];
        NSLog(branch);
#endif
        return 1.0;
    }
    
    //check for unit clauses
    int value=[currentstate unitClause];
    if (value!=-1) {
#ifdef LOGPROGRESS
        if (value<0) {
            NSLog(@"%i is forced negative: (u)",  (int) fabs(value));}
        else{NSLog(@"%i is forced positive: (u)", (int)fabs(value));}
#endif
        //Add current state of clause counts to the stack before any further manipulation
        [self.clauseState push:[currentstate prepRestoreClauses]];
        //Now call the method to make the forced assignment and pass the modified state to the recursive call
        [currentstate assign:value];
        //Make recursive call
        double probVSGN=[self SOLVESSAT:currentstate];
        // Now restore the state after the probability of that brach has been determined
        [self restoreState:currentstate with:value];
        //Determine if an adjustment needs to be made
        if ([currentstate isChoiceVariable:fabs(value)]) {
            return probVSGN;
        } else{
            //It is a chance variable so reduce the probability returned
            // by the probability of the forced assignment
            if (value>0) {
                return probVSGN*[currentstate probabilityIsTrue:value];
            }
            return probVSGN*(1-[currentstate probabilityIsTrue:value]);
        }
        
    }
    
    //Check for pure variables
    value=[currentstate identifyPureVariables];
    if (value!=0) {
#ifdef LOGPROGRESS
        if (value<0) {NSLog(@"%i is a pure variable.  Set: Negative", (int) fabs(value));}
        else {NSLog(@"%i is a pure variable: Set: Positive", (int) fabs(value));}
#endif
        [self.clauseState push:[currentstate prepRestoreClauses]];
        //Now call the method to make the forced assignment and pass the modified state to the recursive call
        [currentstate assign:value];
        double probVSGN=[self SOLVESSAT:currentstate];
        // Now restore the state after the probability of that brach has been determined
        [self restoreState:currentstate with:value];
#ifdef LOGPROGRESS
        NSLog(@"Prob:%f",probVSGN);
#endif
        return probVSGN;
    }
    // If no unit clauses or pure variables, get an unassigned var from
    // the first block of variables that contains unassigned variables
    int nextLiteral=[currentstate getNextLiteral];
    [self.clauseState push:[currentstate prepRestoreClauses]];
    
    //Solve the two subproblems by setting literal to False and then to True
#ifdef LOGPROGRESS
    NSLog(@"Choosing %i as false", nextLiteral);
#endif
    //False
    [currentstate assign:(nextLiteral*-1)];
    double probFalse=[self SOLVESSAT:currentstate];
    [ self restoreState:currentstate with:nextLiteral];
    [self.clauseState push:[currentstate prepRestoreClauses]];
    
#ifdef LOGPROGRESS
    NSLog(@"Choosing %i as true", nextLiteral);
#endif
    //True
    [currentstate assign:nextLiteral];
    double probTrue=[self SOLVESSAT:currentstate];
    [self restoreState:currentstate with:nextLiteral];
    
    //If the literal is a choice variable, can return the better one
    if ([currentstate isChoiceVariable:fabs(nextLiteral)]) {
        if (probTrue>probFalse) {
            return  probTrue;
        }
        return probFalse;
    }
    // If the literal is a chance variable, must return the probability weighted
    // average of the satisfaction probabilities of the children
    return (probTrue*[currentstate probabilityIsTrue:nextLiteral])+(probFalse*(1-[currentstate probabilityIsTrue:nextLiteral]));
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)file:(UITextField *)sender {
}

/*Helps restore the data structures*/
-(void)restoreState:(Solvers *)currentstate with:(int)value{
    [currentstate restoreSolutionArray:value];
    [currentstate restoreAssignmentArray:value];
    [currentstate restoreClauses:[self.clauseState pop]];
    [currentstate restoreLiteralsInClauses];
}

@end
