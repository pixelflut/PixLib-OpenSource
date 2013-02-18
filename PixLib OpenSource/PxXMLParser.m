/*
 * Copyright (c) 2013 pixelflut GmbH, http://pixelflut.net
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 */

//
//  PxXMLParser.m
//  PixLib OpenSource
//
//  Created by Jonathan Cichon on 18.02.13.
//

#import "PxXMLParser.h"
#import "PxCore.h"

@interface PxXMLParser () <NSXMLParserDelegate>
@property(nonatomic, strong) NSXMLParser *parser;
@property(nonatomic, strong) NSMutableArray *objectStack;
@property(nonatomic, strong) NSDictionary *mapping;

@property(nonatomic, strong) id returnValue;

@end

@implementation PxXMLParser

+ (id)parseFile:(NSString*)path mapping:(NSDictionary *)mapping {
    id ret = nil;
    @autoreleasepool {
        NSInputStream *stream = [NSInputStream inputStreamWithFileAtPath:path];
        PxXMLParser *p = [[PxXMLParser alloc] initWithParser:[[NSXMLParser alloc] initWithStream:stream] mapping:mapping];
        ret = [p parse];
    }
    return ret;
}

+ (id)parseData:(NSData*)data mapping:(NSDictionary *)mapping {
    id ret = nil;
    @autoreleasepool {
        PxXMLParser *p = [[PxXMLParser alloc] initWithParser:[[NSXMLParser alloc] initWithData:data] mapping:mapping];
        ret = [p parse];
    }
    return ret;
}

+ (id)parseString:(NSString*)data mapping:(NSDictionary *)mapping {
    id ret = nil;
    @autoreleasepool {
        PxXMLParser *p = [[PxXMLParser alloc] initWithParser:[[NSXMLParser alloc] initWithData:[data dataUsingEncoding:NSUTF8StringEncoding]] mapping:mapping];
        ret = [p parse];
    }
    return ret;
}

- (id)initWithParser:(NSXMLParser *)parser mapping:(NSDictionary *)mapping {
    self = [super init];
    if (self) {
        _parser = parser;
        [_parser setDelegate:self];
        [_parser setShouldProcessNamespaces:YES];
        [_parser setShouldReportNamespacePrefixes:NO];
        [_parser setShouldResolveExternalEntities:NO];
            
        _mapping = mapping;
    }
    return self;
}

- (id)parse {
    [_parser parse];
    return _returnValue;
}

#pragma mark - XML Parsing

- (void)parserDidStartDocument:(NSXMLParser *)parser {
    _objectStack = [[NSMutableArray alloc] initWithCapacity:16];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    _objectStack = nil;
}

- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validError {
    PxError(@"NSXMLParser: Validation error at line: %d column: %d description: %@",[parser lineNumber],[parser columnNumber],validError);
    _objectStack = nil;
    _returnValue = nil;
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    PxError(@"NSXMLParser: Parse error at line: %d column: %d description: %@",[parser lineNumber],[parser columnNumber],parseError);
    _objectStack = nil;
    _returnValue = nil;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
    
    id workingObject = [_objectStack lastObject];
    id newObject = nil;
    NSString *camelCaseElementName = [elementName stringByCamelizeString:NO];
    
    Class klass = [_mapping objectForKey:camelCaseElementName];
    if (klass) {
        newObject = [[klass alloc] init];
    } else {
        newObject = [[NSMutableDictionary alloc] init];
    }
    
    NSString *key;
    for (key in attributeDict) {
        if([key isEqualToString: @"id"]) {
            [newObject setValue:[attributeDict valueForKey:key] forKey: @"identifier"];
        } else if(![key isEqualToString: @"type"]) {
            // TODO: add camelcase as parsing option
            [newObject setValue:[attributeDict valueForKey:key] forKey:[key stringByCamelizeString:NO]];
        }
    }
    
    if(workingObject == nil) {
        _returnValue = newObject;
    } else if([workingObject isKindOfClass:[NSMutableArray class]]) {
        [workingObject addObject:newObject];
    } else {
        [workingObject setValue:newObject forKey:camelCaseElementName];
    }
    [_objectStack addObject:newObject];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    id workingObject = [_objectStack lastObject];
    if ([workingObject isKindOfClass:[NSMutableDictionary class]]) {
        if ([(NSDictionary*)workingObject valueForKey:@"__px_value_dict__"]) {
            [workingObject setValue:[(NSString*)[workingObject valueForKey:@"__px_value_dict__"] stringByAppendingString:string] forKey:@"__px_value_dict__"];
        } else {
            [workingObject setValue:string forKey:@"__px_value_dict__"];
        }
    } else if ([workingObject isKindOfClass:[NSMutableString class]]) {
        [workingObject appendString:string];
    }
}


- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    [_objectStack removeLastObject];
}

@end
