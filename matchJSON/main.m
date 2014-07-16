//
//  main.m
//  matchJSON
//
//  Created by Dan on 09.07.14.
//  Copyright (c) 2014 Dan. All rights reserved.
//

#import <stdio.h>
#import <Foundation/Foundation.h>

BOOL allowEmptyArrayOnOneSide = NO;
BOOL allowEmptyDictionaryOnOneSide = NO;
BOOL allowNullOnOneSide = NO;
BOOL compareArrayItemsWithFirstItem = NO;


#define NSLog(FORMAT, ...) printf("%s\n", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);

void compareStructs(id firstStruct, id secondStruct, NSString* scope);


NSString* getClassName(id structure)
{
    NSString* type = NSStringFromClass([structure class]);
    
    if ([type isEqualToString:@"__NSCFString"]) {
        return @"string";
    }
    else if ([type isEqualToString:@"__NSCFConstantString"]) {
        return @"string";
    }
    else if ([type isEqualToString:@"__NSCFNumber"]) {
        return @"number";
    }
    else if ([type isEqualToString:@"__NSCFBoolean"]) {
        return @"boolean";
    }
    else if ([type isEqualToString:@"__NSArrayI"]) {
        return @"array";
    }
    else if ([type isEqualToString:@"__NSCFDictionary"]) {
        return @"dictionary";
    }
    else if ([type isEqualToString:@"NSNull"]) {
        return @"null";
    }
    else {
        return @"unknown";
    }
}



void compareDicts(NSDictionary* firstDict, NSDictionary* secondDict, NSString* scope)
{
    //NSString* newScope = [scope stringByAppendingString:@"/"];
    
    if ((([firstDict count] == 0) || ([secondDict count] == 0)) && allowEmptyDictionaryOnOneSide) return;
    
    NSArray* firstKeys = [[firstDict allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [(NSString*)obj1 compare:(NSString*)obj2];
    }];
                          
    NSArray* secondKeys = [[secondDict allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [(NSString*)obj1 compare:(NSString*)obj2];
    }];
    
    
    NSInteger firstIndex = 0;
    NSInteger secondIndex = 0;
    
    while (YES) {
        
        if ((firstIndex == [firstKeys count]) && (secondIndex == [secondKeys count])) {
            return;
        }
        else if ((firstIndex < [firstKeys count]) && (secondIndex == [secondKeys count])) {
            
            NSLog(@"[>] %@: missing key", [scope stringByAppendingString: firstKeys[firstIndex]]);
            firstIndex++;
            continue;
            
        }
        else if ((firstIndex == [firstKeys count]) && (secondIndex < [secondKeys count])) {
            
            NSLog(@"[<] %@: missing key", [scope stringByAppendingString: secondKeys[secondIndex]]);
            secondIndex++;
            continue;
        }
        else {
            NSString* firstKey = firstKeys[firstIndex];
            NSString* secondKey = secondKeys[secondIndex];
            
            NSComparisonResult result = [firstKey compare:secondKey];
            
            if (result == NSOrderedSame) {
                compareStructs(firstDict[firstKey], secondDict[secondKey], [scope stringByAppendingFormat:@"%@/", firstKey]);
                firstIndex++;
                secondIndex++;
                continue;
            }
            else if (result == NSOrderedAscending) {
                NSLog(@"[>] %@: missing key", [scope stringByAppendingString: firstKeys[firstIndex]]);
                firstIndex++;
                continue;
            }
            else {  //NSOrderedDescending
                NSLog(@"[<] %@: missing key", [scope stringByAppendingString: secondKeys[secondIndex]]);
                secondIndex++;
                continue;
            }
        }
    }
}


void compareArrays(NSArray* firstArray, NSArray* secondArray, NSString* scope)
{
    if (!compareArrayItemsWithFirstItem) {
        if ([firstArray count] != [secondArray count]) {
            NSLog(@"[!] %@: different item count", scope);
        }
        else {
            for (NSInteger index = 0; index < [firstArray count]; index++) {
                compareStructs(firstArray[index], secondArray[index], [scope stringByAppendingFormat:@"%ld/", (long)index]);
            }
        }
    }
    else {
        if (([firstArray count] == 0) && ([secondArray count] == 0)) {
            return;
        }
        else if ([firstArray count] == 0) {
            if (allowEmptyArrayOnOneSide) return;
            NSLog(@"[<] %@: array is empty", scope);
            return;
        }
        else if ([secondArray count] == 0) {
            if (allowEmptyArrayOnOneSide) return;
            NSLog(@"[>] %@: array is empty", scope);
            return;
        }
        else {
            for (NSInteger index = 0; index < [firstArray count]; index++) {
                compareStructs(firstArray[index], secondArray[0], [scope stringByAppendingFormat:@"%ld/", (long)index]);
            }
        }
    }
}


void compareStructs(id firstStruct, id secondStruct, NSString* scope)
{
//    NSLog(@"[?] %@ [<]: %@, [>]: %@", scope, [firstStruct class], [secondStruct class]);
    
    NSString* firstClass = getClassName(firstStruct);
    NSString* secondClass = getClassName(secondStruct);
    
    
    if ([firstClass isEqualToString:@"dictionary"] && [secondClass isEqualToString:@"dictionary"]) {
        compareDicts(firstStruct, secondStruct, scope);
    }
    else if ([firstClass isEqualToString:@"array"] && [secondClass isEqualToString:@"array"]) {
        compareArrays(firstStruct, secondStruct, scope);
    }
    else if ([firstClass isEqualToString:@"string"] && [secondClass isEqualToString:@"string"]) {
        return;
    }
    else if ([firstClass isEqualToString:@"number"] && [secondClass isEqualToString:@"number"]) {
        return;
    }
    else if ([firstClass isEqualToString:@"null"] && [secondClass isEqualToString:@"null"]) {
        return;
    }
    else {
        
        if (allowNullOnOneSide) {
            if ([firstClass isEqualToString:@"null"] || [secondClass isEqualToString:@"null"]) {
                return;
            }
        }
        
        if ([scope hasSuffix:@"/"]) {
            scope = [scope substringToIndex:[scope length] - 1];
        }
        
        NSLog(@"[!] %@: type mismatch - [<]: %@, [>]: %@", scope, firstClass, secondClass);
    }
}



int main(int argc, const char * argv[])
{

    @autoreleasepool {
        
        if (argc < 3) {
            NSLog(@"Usage: matchJSON <params> <file1.json> <file2.json>");
            NSLog(@"Parameters:");
            NSLog(@"    -n  allow null on one side");
            NSLog(@"    -a  allow empty array on one side");
            NSLog(@"    -d  allow empty dictionary on one side");
            NSLog(@"    -f  compare all array items of file1 with first array item of file2");
            return 0;
        }
        
        NSInteger files = 0;
        NSString *firstFile;
        NSString *secondFile;
        
        for (NSInteger index = 1; index < argc; index++) {
            NSString* param = [NSString stringWithUTF8String:argv[index]];
            
            if ([param isEqualTo:@"-n"]) {
                allowNullOnOneSide = YES;
            }
            else if ([param isEqualTo:@"-a"]) {
                allowEmptyArrayOnOneSide = YES;
            }
            else if ([param isEqualTo:@"-d"]) {
                allowEmptyDictionaryOnOneSide = YES;
            }
            else if ([param isEqualTo:@"-f"]) {
                compareArrayItemsWithFirstItem = YES;
            }
            else {
                if (files == 0) {
                    firstFile = param;
                    files++;
                }
                else if (files == 1) {
                    secondFile = param;
                    files++;
                }
            }
        }
        
        if (files != 2) {
            NSLog(@"Incorrect count of parameters");
            return 0;
        }
        
        NSData *firstData = [NSData dataWithContentsOfFile:firstFile];
        NSData *secondData = [NSData dataWithContentsOfFile:secondFile];
        
        id firstStruct = [NSJSONSerialization JSONObjectWithData:firstData options:kNilOptions error:nil];
        id secondStruct = [NSJSONSerialization JSONObjectWithData:secondData options:kNilOptions error:nil];
        
        compareStructs(firstStruct, secondStruct, @"");
        
    }
    return 0;
}

