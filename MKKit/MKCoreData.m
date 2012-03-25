//
//  MKCoreData.m
//  MKKit
//
//  Created by Matthew King on 5/12/10.
//  Copyright 2010-2012 Matt King. All rights reserved.
//

#import "MKCoreData.h"

typedef void (^MKFetchCompletionBlock)(NSMutableArray *results, NSError *error);

//---------------------------------------------------------------
// Interface
//---------------------------------------------------------------

@interface MKCoreData ()

- (id)initWithContext:(NSManagedObjectContext *)context;

@property (nonatomic, copy) MKFetchCompletionBlock fechCompletionBlock;

@end

//---------------------------------------------------------------
// Implementation
//---------------------------------------------------------------

@implementation MKCoreData

@synthesize fechCompletionBlock;

static NSManagedObjectContext *managedObjectContext = nil;
static MKCoreData *sharedData = nil;

#pragma mark - Creation

//---------------------------------------------------------------
// Creataion
//---------------------------------------------------------------

+ (MKCoreData *)sharedData {
    @synchronized(self) {
        if (!managedObjectContext) {
            NSException *exception = [NSException exceptionWithName:@"No context set" reason:@"Context needs to be set first using +[MKCoreData sharedDataWithContext:]" userInfo:nil];
            [exception raise];
        } 
    }
    
	return sharedData;
}

+ (void)sharedDataWithContext:(NSManagedObjectContext *)context {
    @synchronized(self) {
        if (!sharedData) {
            sharedData = [[self alloc] initWithContext:context];
        }   
    }
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedData == nil) {
            sharedData = [super allocWithZone:zone];
            return sharedData;
        }
    }
    return nil;
}

- (id)initWithContext:(NSManagedObjectContext *)context {
	self = [super init];
    if (self) {
		managedObjectContext = context;
	}
	return self;
}

#pragma mark - Accessor Methods

//---------------------------------------------------------------
// Accessor Methods
//---------------------------------------------------------------

- (NSManagedObjectContext *)getContext {
	return managedObjectContext;
}

#pragma mark - Feched Results

//---------------------------------------------------------------
// Fetched Results
//---------------------------------------------------------------

- (NSMutableArray *)fetchedResultsForEntity:(NSString *)entity sortedBy:(NSString *)attribute accending:(BOOL)accendeing {
	NSFetchRequest *request = [[NSFetchRequest alloc] init]; 
	NSEntityDescription *anEntity = [NSEntityDescription entityForName:entity inManagedObjectContext:managedObjectContext]; 
	[request setEntity:anEntity]; 
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:attribute ascending:accendeing]; 
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil]; 
	[request setSortDescriptors:sortDescriptors]; 
	
	[sortDescriptors release]; 
	[sortDescriptor release];
	
	NSError *error; 
	NSMutableArray *mutableFetchResults = [[[managedObjectContext executeFetchRequest:request error:&error] mutableCopy] autorelease]; 
	
	if (mutableFetchResults == nil) { 
		MKErrorHandeling *handeler	= [[MKErrorHandeling alloc] init];
		[handeler applicationDidError:error];
		[handeler release];		
	} 
	
	[request release]; 
	
	return mutableFetchResults;
}

- (void)fetchResultsForEntity:(NSString *)entity sortedBy:(NSString *)attribute accending:(BOOL)accending result:(MKFetchCompletionBlock)result {
    self.fechCompletionBlock = result;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init]; 
	NSEntityDescription *anEntity = [NSEntityDescription entityForName:entity inManagedObjectContext:managedObjectContext]; 
	[request setEntity:anEntity]; 
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:attribute ascending:accending]; 
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil]; 
	[request setSortDescriptors:sortDescriptors]; 
	
	[sortDescriptors release]; 
	[sortDescriptor release];
	
	NSError *error; 
	NSMutableArray *mutableFetchResults = [[[managedObjectContext executeFetchRequest:request error:&error] mutableCopy] autorelease]; 
	
	if (mutableFetchResults == nil) { 
		self.fechCompletionBlock(nil, error);	
	}
    else {
        self.fechCompletionBlock(mutableFetchResults, nil);
    }
	
	[request release]; 
}

#pragma mark - Memory Management

//---------------------------------------------------------------
// Memory
//---------------------------------------------------------------

- (void)removeSharedData {
	sharedData = nil;
	[sharedData release];
	
	[self release];
}

- (void)dealloc {
	[super dealloc];
	
	if (managedObjectContext) {
		managedObjectContext = nil;
		[managedObjectContext release];
	}
	
	[managedObjectContext release];
    self.fechCompletionBlock = nil;
	
	if (sharedData) {
		sharedData = nil;
		[sharedData release];
	}
}

@end
