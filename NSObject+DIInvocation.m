// (c) 2010, Deep IT, Uncle MiF
// COMMON FILE: Common

#import "NSObject+DIInvocation.h"
#include <stdarg.h>

/* ::: Just for information ::: */
#if (defined DEBUG) && (defined VERBOSE)
#ifdef __OBJC_GC__
#warning Selected Configuration: GC Environment
#else
#warning Selected Configuration: AR-Pool Environment
#endif
#endif	

#ifndef __OBJC_GC__
@interface DIInvocationProducerDeallocatorHelper : NSObject
{
	id object;
}

-(id)initWithObject:(id)newObject;
-(void)dealloc;

@end

@implementation DIInvocationProducerDeallocatorHelper

-(id)initWithObject:(id)newObject
{
#if (defined DEBUG) && (defined VERBOSE)
	NSLog(@"%s",__PRETTY_FUNCTION__);
#endif	
	if (!newObject)
	{
		[self release];
		return nil;
	}
	self = [super init];
	if (self)
		object = newObject;
	return self;
}

-(void)dealloc
{
#if (defined DEBUG) && (defined VERBOSE)
	NSLog(@"%s",__PRETTY_FUNCTION__);
#endif	
	[object dealloc];
	[super dealloc];
}

@end

#endif

@implementation DIInvocationProducer

+(void)load
{
#if (defined DEBUG) && (defined VERBOSE)
	NSLog(@"%s",__PRETTY_FUNCTION__);
#endif	
}

+(void)initialize
{
#if (defined DEBUG) && (defined VERBOSE)
	NSLog(@"%s",__PRETTY_FUNCTION__);
#endif
}

+(id)alloc
{
#if (defined DEBUG) && (defined VERBOSE)
	NSLog(@"%s",__PRETTY_FUNCTION__);
#endif
	return NSAllocateObject(self, 0, NSDefaultMallocZone());
}

-(void)finalize
{
#if (defined DEBUG) && (defined VERBOSE)
	NSLog(@"%s",__PRETTY_FUNCTION__);
#endif
	ivcRef = nil;
}

-(void)dealloc
{
#if (defined DEBUG) && (defined VERBOSE)
	NSLog(@"%s",__PRETTY_FUNCTION__);
#endif
	ivcRef = nil;
	if (invocation)
		[invocation autorelease], invocation = nil;
	NSDeallocateObject(self);
}

-(oneway void)release
{
#ifndef __OBJC_GC__
	[refHelper release];
#endif
}

-(id)retain
{
#ifndef __OBJC_GC__
	[refHelper retain];
#endif
	return self;
}

-(id)autorelease
{
#ifndef __OBJC_GC__
	[refHelper autorelease];
#endif
	return self;
}

-(NSUInteger)retainCount
{
#ifndef __OBJC_GC__
	return [refHelper retainCount];
#else
	return 1;
#endif
}

-(void)doesNotRecognizeSelector:(SEL)aSelector
{
#if (defined DEBUG) && (defined VERBOSE)
	NSLog(@"%s",__PRETTY_FUNCTION__);
#endif
	[NSObject doesNotRecognizeSelector:aSelector];
}

-(id)initWithTarget:(id)aTarget outInvocation:(NSInvocation* *)ref
{
#if (defined DEBUG) && (defined VERBOSE)
	NSLog(@"%s",__PRETTY_FUNCTION__);
#endif
	if (ref)
		*ref = nil;
	if (!aTarget)
	{
#ifndef __OBJC_GC__
		[self dealloc];
#endif
		return nil;
	}
	target = aTarget;
	ivcRef = ref;
	return self;
}

+(id)producerForObject:(id)aTarget
{
#if (defined DEBUG) && (defined VERBOSE)
	NSLog(@"%s",__PRETTY_FUNCTION__);
#endif
	return [self producerForObject:aTarget outInvocation:nil];
}

+(id)producerForObject:(id)aTarget outInvocation:(NSInvocation* *)ivcRef
{
#if (defined DEBUG) && (defined VERBOSE)
	NSLog(@"%s",__PRETTY_FUNCTION__);
#endif
	if (ivcRef)
		*ivcRef = nil;
	if (!aTarget)
		return nil;
	DIInvocationProducer * producer = [[self alloc] initWithTarget:aTarget outInvocation:ivcRef];
#ifndef __OBJC_GC__
	if (producer)
		producer->refHelper = [[[DIInvocationProducerDeallocatorHelper alloc] initWithObject:producer] autorelease];
#endif
	return producer;
}

-(NSInvocation*)producedInvocation
{
#if (defined DEBUG) && (defined VERBOSE)
	NSLog(@"%s",__PRETTY_FUNCTION__);
#endif
	return [[invocation retain] autorelease];
}

-(void)forwardInvocation:(NSInvocation *)anInvocation
{
#if (defined DEBUG) && (defined VERBOSE)
	NSLog(@"%s",__PRETTY_FUNCTION__);
#endif
	[invocation autorelease], invocation = [anInvocation retain];
	[invocation setTarget:target];
	if (ivcRef)
		*ivcRef = [[anInvocation retain] autorelease];
}

-(NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
#if (defined DEBUG) && (defined VERBOSE)
	NSLog(@"%s",__PRETTY_FUNCTION__);
#endif
	return [target methodSignatureForSelector:aSelector];
}

@end

@implementation NSObject (DIInvocation)

#define DIVoidIVCCode \
NSInvocation * ivc = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:aSelector]];\
[ivc setTarget:self];\
[ivc setSelector:aSelector];\
return ivc;

#define DIIVCCodeWithArgs \
NSMethodSignature * mSig = [self methodSignatureForSelector:aSelector];\
NSInvocation * ivc = [NSInvocation invocationWithMethodSignature:mSig];\
[ivc setTarget:self];\
[ivc setSelector:aSelector];\
int argIdx = 2;\
va_list ap;\
va_start(ap,first);\
void* argVal = first;\
unsigned argsCnt = [mSig numberOfArguments];\
argsCnt -= 2;\
while (argsCnt-- && argVal)\
{\
[ivc setArgument:argVal atIndex:argIdx];\
argIdx++;\
argVal = va_arg(ap,void*);\
}\
va_end(ap);\
return ivc;

+(NSInvocation*)invocationForSelector:(SEL)aSelector
{
#if (defined DEBUG) && (defined VERBOSE)
	NSLog(@"%s",__PRETTY_FUNCTION__);
#endif
	DIVoidIVCCode
}

-(NSInvocation*)invocationForSelector:(SEL)aSelector
{
#if (defined DEBUG) && (defined VERBOSE)
	NSLog(@"%s",__PRETTY_FUNCTION__);
#endif
	DIVoidIVCCode
}

+(NSInvocation*)invocationForSelector:(SEL)aSelector withArguments:(void*)first,...
{
#if (defined DEBUG) && (defined VERBOSE)
	NSLog(@"%s",__PRETTY_FUNCTION__);
#endif
	DIIVCCodeWithArgs
}

-(NSInvocation*)invocationForSelector:(SEL)aSelector withArguments:(void*)first,...
{
#if (defined DEBUG) && (defined VERBOSE)
	NSLog(@"%s",__PRETTY_FUNCTION__);
#endif
	DIIVCCodeWithArgs
}

+(id/* DIInvocationProducer* */)producedInvocation:(NSInvocation* *)ivcRef
{
#if (defined DEBUG) && (defined VERBOSE)
	NSLog(@"%s",__PRETTY_FUNCTION__);
#endif
	return [DIInvocationProducer producerForObject:[self class] outInvocation:ivcRef];
}

-(id/* DIInvocationProducer* */)producedInvocation:(NSInvocation* *)ivcRef
{
#if (defined DEBUG) && (defined VERBOSE)
	NSLog(@"%s",__PRETTY_FUNCTION__);
#endif
	return [DIInvocationProducer producerForObject:self outInvocation:ivcRef];
}

+(id/* DIInvocationProducer* */)invocationProducer
{
#if (defined DEBUG) && (defined VERBOSE)
	NSLog(@"%s",__PRETTY_FUNCTION__);
#endif
	return [DIInvocationProducer producerForObject:[self class]];
}

-(id/* DIInvocationProducer* */)invocationProducer
{
#if (defined DEBUG) && (defined VERBOSE)
	NSLog(@"%s",__PRETTY_FUNCTION__);
#endif
	return [DIInvocationProducer producerForObject:self];
}

@end
