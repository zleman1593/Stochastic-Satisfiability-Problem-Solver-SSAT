//
//  Solver.m
//  SSAT Solver
//
//  Created by Zackery Leman on 2/13/14.
//  Copyright (c) 2014 Zackery Leman. All rights reserved.
//This algorithm solves SSAT problems in a specific .cnf format.
//It gives the probability of satisfaction and displays the
//possible branches (all possible combinations of literal assignments) of the assignment tree.
#import "Solvers.h"

@implementation Solvers

- (id) initWithProblem:(NSMutableArray *)start numberOfLiterals:(int)numberOfLiterals{
    
    if (self = [super init])
    {
        
        self.clauses=start;
        self.literalsInClauses=[[ NSMutableArray alloc] init];
        self.unassignedVariables=[[NSMutableArray alloc]init];
        self.solution=[[NSMutableArray alloc]init];
        self.probability=[[NSMutableArray alloc]init];
        self.numberOfLiterals=numberOfLiterals;
        //For restoring data structure
        self.ClausesThatDropOut=[[Stack alloc]init];
        self.globalTempArray=[[NSMutableArray alloc]init];
        self.literalRestore=[[NSMutableArray alloc]init];
        
        // Now build the "literalsInClauses" data structure
        
        //First step: Add empty arrays to each position in the main array to represent
        //negative and positive clauses for each literal
        for (int i = 1; i < (numberOfLiterals*2)+2; i++) {
            [self.literalsInClauses insertObject:[NSMutableArray arrayWithObjects:nil] atIndex:0];
            //Also prepare the restore data structure
            [self.literalRestore insertObject:[NSMutableArray arrayWithObjects:nil] atIndex:0];
        }
        
        
        //Step 2: Create a temporary array where the count is deleted from position 0 so that it does not confuse the rest of the algorithm
        NSMutableArray *clausesWithNoCount=[self miniDeepCopy:self.clauses];
        for (int i = 1; i < [clausesWithNoCount count]; i++)  {
            [[clausesWithNoCount objectAtIndex:i] removeObjectAtIndex:0];
        }
        
        //Now clauses are added to the arrays
        for (int i = 1; i < [clausesWithNoCount count]; i++) {
            for (int j = 1; j <=numberOfLiterals; j++) {
                int negatedTestValue=(fabs(j)*-1);
                int positiveTestValue=fabs(j);
                
                //When a literal is negated in a clause add that clause to the negated list for that literal
                if ( [[clausesWithNoCount objectAtIndex:i] containsObject:[NSMutableString stringWithFormat:@"%i",negatedTestValue]]) {
                    [[self.literalsInClauses objectAtIndex:(j*2)-1] insertObject:[NSMutableString stringWithFormat:@"%i",i] atIndex:0];
                    // These lines are only duplicated to accommodate an additional space before a literal.
                }else if ([[clausesWithNoCount objectAtIndex:i] containsObject:[NSMutableString stringWithFormat:@" %i",negatedTestValue]]){
                    [[self.literalsInClauses objectAtIndex:(j*2)-1] insertObject:[NSMutableString stringWithFormat:@"%i",i]atIndex:0];
                }
                //When a literal is not negated in a clause add that clause to the positive list for that literal
                if ([[clausesWithNoCount objectAtIndex:i] containsObject:[NSMutableString stringWithFormat:@"%i",positiveTestValue]]) {
                    [[self.literalsInClauses objectAtIndex:(j*2)] insertObject:[NSMutableString stringWithFormat:@"%i",i]atIndex:0];
                    // These lines are only duplicated to accommodate an additional space before a literal.
                } else if ([[self.clauses objectAtIndex:i] containsObject:[NSMutableString stringWithFormat:@" %i",positiveTestValue]]){
                    [[self.literalsInClauses objectAtIndex:(j*2)] insertObject:[NSMutableString stringWithFormat:@"%i",i] atIndex:0];
                }
                
            }
        }
        
        
        // Now initialize the "solution" data structure.
        //Index 0 is irrelevant.
        [self.solution addObject:@"0"];
        for (int i=0; i<numberOfLiterals; i++) {
            [self.solution addObject:@"-1"];
        }
        
        //Initialize the unassignedVariables array
        for (int i=0; i<numberOfLiterals; i++) {
            int value=i+1;
            [self.unassignedVariables addObject:[NSMutableString stringWithFormat:@"%i",value]];
        }
        
    }
    //Returns the newly created object
    return self;
    
}





- (BOOL) unsat{
    for (int i = 1; i < [self.clauses count]; i++) {
        if ([[[self.clauses objectAtIndex:i] objectAtIndex:0] intValue]==0) {
            return YES;
        }
    }
    return  NO;
}


- (BOOL) sat{
    for (int i = 1; i < [self.solution count]; i++) {
        
        if ([[self.solution  objectAtIndex:i] intValue]<0) {
            
            int total=0;
            for (int i = 1; i<(self.numberOfLiterals*2)+1; i++){
                total= total+[(NSMutableArray*)[self.literalsInClauses objectAtIndex:i] count];
            }
            if (total==0) {
                if([self.solution containsObject:@"-1"]){
                    //NOTE:  NSLog(@"At least one variable has still not been set, is irrelevant, and can be set true or false without affecting P(sat)");
                }
                //Satisfied if you run out of clauses to try and satisfy
                return  YES;
            }
            return NO;
        }
    }
    //If all variables have been assigned then it is satisfied
    return  YES;
}


- (int) unitClause{
    //Checks the count of clause to see if it is "1" indicating a unit clause.
    //Finds  and returns the forced variable in that clause
    for (int i = 1; i < [self.clauses count]; i++) {
        if ([[[self.clauses objectAtIndex:i] objectAtIndex:0] intValue]==1) {
            for (int j=1; j <[(NSMutableArray*)[self.clauses objectAtIndex:i]count]; j++) {
                int number=[[[self.clauses objectAtIndex:i] objectAtIndex:j] intValue];
                int absnumber=fabs(number);
                if ([self.solution[absnumber]intValue]<0) {
                    return number;
                }
            }
        }
        
    }
    return  -1;
}

-(void) assign:(int)value{
    //Setting to zero is True
    //Setting to 1 or anything else is False
    int sign;
    if (value<0) {
        sign=1;
    } else {
        sign=0;
    }
    //Adds the assignment of the literal to the solution array
    [self.solution replaceObjectAtIndex:fabs(value) withObject:[NSString stringWithFormat:@"%d",sign]];
    
    //Updates the clauses count
    [self updateClauses:value];
    //Adds which clauses were satisfied and dropped out of consideration
    [self.clausesThatDropOut push:[self miniDeepCopy:self.globalTempArray]];
    //Reset this temporary array
    self.globalTempArray=[[NSMutableArray alloc]init];
    //When a literal is assigned a value remove it from the unassigned literal array
    [self.unassignedVariables removeObject:[NSMutableString stringWithFormat:@"%i",(int)fabs(value)]];
}


- (void)updateClauses:(int)value{
    for (int i = 1; i < [self.clauses count]; i++) {
        for (int j=1; j <[(NSMutableArray*)[self.clauses objectAtIndex:i]count]; j++) {
            int number=[[[self.clauses objectAtIndex:i] objectAtIndex:j] intValue];
            //Finds the value in every clause it is in and determines if it is negated or not.
            //Determines the effect of the assignment.
            if (fabs(number)==fabs(value)) {
                //If clause becomes satisfied by assignment
                if (number>0 && value>0) {
                    [[self.clauses objectAtIndex:i] replaceObjectAtIndex:0 withObject:@"-1"];
                    //If any clause becomes satisfied then update the "literalsInClauses" data structure to remove that clause
                    [self updateliteralsInAllClauses:i];
                }
                //If one literal drops out because its assignment means it can no longer help
                else if (number<0 && value>0) {
                    int count=[[[self.clauses objectAtIndex:i] objectAtIndex:0] intValue];
                    count=count-1;
                    [[self.clauses objectAtIndex:i] replaceObjectAtIndex:0 withObject:[NSString stringWithFormat:@"%d",count]];
                }
                //If one literal drops out because its assignment means it can no longer help
                else if (number>0 && value<0){
                    int count=[[[self.clauses objectAtIndex:i] objectAtIndex:0] intValue];
                    count=count-1;
                    [[self.clauses objectAtIndex:i] replaceObjectAtIndex:0 withObject:[NSString stringWithFormat:@"%d",count]];
                    
                }
                //If clause becomes satisfied by assignment
                else if (number<0 && value<0){
                    [[self.clauses objectAtIndex:i] replaceObjectAtIndex:0 withObject:@"-1"];
                    //If any clause becomes satisfied then update the "literalsInClauses" data structure to remove that clause
                    [self updateliteralsInAllClauses:i];
                    
                }
                
            }
        }
    }
}

/*Remove the clause wherever it appears in the 2D array*/
- (void)updateliteralsInAllClauses:(int)value{
    for (int i = 1; i < [self.literalsInClauses count]; i++) {
        
        //check if it is in each literal and if so, it was removed, so add to the restore data structure
        if ([[self.literalsInClauses objectAtIndex:i] containsObject:[NSMutableString stringWithFormat:@"%d",value]]) {
            [[self.literalRestore objectAtIndex:i] addObject:[NSMutableString stringWithFormat:@"%d",value]];
            //If the array being built does not already contain  this dropped clause it is added
            if (![self.globalTempArray containsObject:[NSMutableString stringWithFormat:@"%d",value]]) {
                [self.globalTempArray addObject:[NSMutableString stringWithFormat:@"%d",value]];
            }
        }
        [[self.literalsInClauses objectAtIndex:i] removeObject:[NSMutableString stringWithFormat:@"%d",value]];
    }
}


/**/
- (BOOL)isChoiceVariable:(int)value{
    if ([[self.probability objectAtIndex:fabs(value)] doubleValue]==-1) {
        return YES;
    }
    return NO;
}

/**/
- (double)probabilityIsTrue:(int)value{
    return [[self.probability objectAtIndex:fabs(value)] doubleValue];
}

/*Allows the state to be duplicated so that a copy
 *(snapshot of the state) can be stored in a stack
 This is a deprecated method, not used in this version of the algorithm*/
-(id)mutableCopyWithZone:(NSZone *)zone
{
    Solvers *copy = [[[self class] allocWithZone:zone] init];
    copy.clauses=[self miniDeepCopy:self.clauses];
    copy.literalsInClauses=[self miniDeepCopy:self.literalsInClauses];
    copy.unassignedVariables=[self miniDeepCopy:self.unassignedVariables];
    copy.solution=[self miniDeepCopy:self.solution];
    copy.probability=[self miniDeepCopy:self.probability];
    copy.numberOfLiterals=self.numberOfLiterals;
    copy.literalRestore=[self miniDeepCopy:self.literalRestore];
    copy.globalTempArray=[self miniDeepCopy:self.globalTempArray];
    //copy.clausesThatDropOut=[self miniDeepCopy:self.clausesThatDropOut];
    
    return copy;
}

/*Takes an array and makes a deep copy of it which it returns*/
- (NSMutableArray*)miniDeepCopy:(NSMutableArray*)arrayToCopy{
    NSData *buffer = [NSKeyedArchiver archivedDataWithRootObject: arrayToCopy];
    NSMutableArray *coppiedArray = [NSKeyedUnarchiver unarchiveObjectWithData: buffer];
    return coppiedArray;
}

/*Returns a pure variable with the proper assignment if it found one, or zero if no pure variable*/
- (int)identifyPureVariables{
    for (int i = 1; i<=self.numberOfLiterals; i++){
        if ([self isChoiceVariable:i] && ![self isAssigned:i]) {
            int countOddNegated=[(NSMutableArray*)[self.literalsInClauses objectAtIndex:(i*2)-1] count];
            int countEvenPositive=[(NSMutableArray*)[self.literalsInClauses objectAtIndex:(i*2)] count];
            if (countOddNegated==0 || countEvenPositive==0 ) {
                if (countOddNegated<countEvenPositive) {
                    return i;
                }
                if (countEvenPositive<countOddNegated) {
                    return i*(-1);
                }
                //If both are zero
                return 0;
            }
        }
    }
    return 0;
}

/**/
- (int)getNextLiteral{
    int temp;
    do {
        if ([self.unassignedVariables count]==0) {
            return -1;
        }
        temp= [[self.unassignedVariables objectAtIndex:0]intValue];
        //When obtaining the next literal to be given a value,
        //remove from unassigned literal array.
        [self.unassignedVariables removeObjectAtIndex:0];
    } while ([self isAssigned:fabs(temp)]);
    return temp;
}

/**/
- (BOOL) isAssigned:(int)check{
    if ([[self.solution  objectAtIndex:check] intValue]<0) {
        return NO;
    }
    return  YES;
}

//The below methods simply restore the state of the data structures to what they where right before making a recursive call
- (void)restoreSolutionArray:(int)value{
    [self.solution  replaceObjectAtIndex:fabs(value) withObject:@"-1"];
}

- (void)restoreAssignmentArray:(int)value{
    int i=0;
    if ([self.unassignedVariables count]!=0) {
        
        while ([[self.unassignedVariables objectAtIndex:i] intValue]<(int)fabs(value)) {
            if (i!=[self.unassignedVariables count]-1) {
                i++;
            } else {
                [self.unassignedVariables addObject:[NSMutableString stringWithFormat:@"%i",(int)fabs(value)]];
                break;}
        }
        
        if (i!=[self.unassignedVariables count]-1) {
            
            [self.unassignedVariables insertObject:[NSMutableString stringWithFormat:@"%i",(int)fabs(value)] atIndex:i];
        }
    } else{
        [self.unassignedVariables addObject:[NSMutableString stringWithFormat:@"%i",(int)fabs(value)]];
    }
}

- (NSMutableArray*)prepRestoreClauses{
    NSMutableArray * restoreZeroArray=[[NSMutableArray alloc] init];
    for (int i = 1; i < [self.clauses count]; i++) {
        int value=[[[self.clauses objectAtIndex:i] objectAtIndex:0] intValue];
        [restoreZeroArray addObject:[NSMutableString stringWithFormat:@"%i",value]];
    }
    return restoreZeroArray;
}

- (void)restoreClauses:(NSMutableArray *)restoreArray{
    for (int i = 1; i < [self.clauses count]; i++) {
        [[self.clauses objectAtIndex:i] replaceObjectAtIndex:0 withObject:[restoreArray objectAtIndex:i-1]];
    }
    
}

- (void)restoreLiteralsInClauses{
    NSMutableArray *temp=[self.clausesThatDropOut pop];
    for (int j=[temp count]-1; j>=0; j--) {
        int value=[[temp objectAtIndex:j] intValue];
        
        for (int i=1; i<[self.literalRestore count]; i++) {
            
            if([[[self.literalRestore objectAtIndex:i] lastObject] intValue]==fabs(value)&& value!=0){
                [[self.literalsInClauses objectAtIndex:i] addObject:[[self.literalRestore objectAtIndex:i] lastObject]];
                [[self.literalRestore objectAtIndex:i] removeLastObject];
            }
        }
    }
}

@end