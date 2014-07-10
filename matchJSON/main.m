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
BOOL compareJustFirstItemsOfArrays = NO;
BOOL compareArrayItemsMutually = NO;


#define NSLog(FORMAT, ...) printf("%s\n", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);

void compareStructs(id firstStruct, id secondStruct, NSString* scope);



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
    if (!compareJustFirstItemsOfArrays) {
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
        if ((([firstArray count] == 0) || ([secondArray count] == 0)) && allowEmptyArrayOnOneSide) return;
        
        compareStructs(firstArray[0], secondArray[0], [scope stringByAppendingString:@"0/"]);
        
    }
}


void compareStructs(id firstStruct, id secondStruct, NSString* scope)
{
    if ([firstStruct isKindOfClass:[NSDictionary class]] && [secondStruct isKindOfClass:[NSDictionary class]]) {
        compareDicts(firstStruct, secondStruct, scope);
    }
    else if ([firstStruct isKindOfClass:[NSArray class]] && [secondStruct isKindOfClass:[NSArray class]]) {
        compareArrays(firstStruct, secondStruct, scope);
    }
    else if ([firstStruct isKindOfClass:[NSString class]] && [secondStruct isKindOfClass:[NSString class]]) {
        return;
    }
    else if ([firstStruct isKindOfClass:[NSNumber class]] && [secondStruct isKindOfClass:[NSNumber class]]) {
        return;
    }
    else if ([firstStruct isKindOfClass:[NSNull class]] && [secondStruct isKindOfClass:[NSNull class]]) {
        return;
    }
    else {
        
        if (allowNullOnOneSide) {
            if ([firstStruct isKindOfClass:[NSNull class]] || [secondStruct isKindOfClass:[NSNull class]]) {
                return;
            }
        }
        
        if ([scope hasSuffix:@"/"]) {
            scope = [scope substringToIndex:[scope length] - 1];
        }
        
        NSLog(@"[!] %@: type mismatch - [<]: %@, [>]: %@", scope, [firstStruct class], [secondStruct class]);
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
            NSLog(@"    -f  compare just first items of arrays");
            NSLog(@"    -m  compare array items mutually");
            
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
                compareJustFirstItemsOfArrays = YES;
            }
            else if ([param isEqualTo:@"-m"]) {
                compareArrayItemsMutually = YES;
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

