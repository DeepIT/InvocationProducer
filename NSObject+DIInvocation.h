// (c) 2010, Deep IT, Uncle MiF
// COMMON FILE: Common

#import <Foundation/Foundation.h>

// + NSInvocationBuilder (the private root class) functionality
@interface DIInvocationProducer
{
	Class isa;
	id target;
	NSInvocation* *ivcRef;
	NSInvocation * invocation;
#ifndef 	__OBJC_GC__
	id refHelper;// for ARP-support
#endif
}

+(id)producerForObject:(id)aTarget;
+(id)producerForObject:(id)aTarget outInvocation:(NSInvocation* *)ivcRef;

-(NSInvocation*)producedInvocation;

-(oneway void)release;
-(id)retain;
-(id)autorelease;
-(NSUInteger)retainCount;

@end

@interface NSObject (DIInvocation)

+(NSInvocation*)invocationForSelector:(SEL)aSelector;
-(NSInvocation*)invocationForSelector:(SEL)aSelector;

+(NSInvocation*)invocationForSelector:(SEL)aSelector withArguments:(void*)first,...;// first is argument after self and _cmd (real internal index is 2)
-(NSInvocation*)invocationForSelector:(SEL)aSelector withArguments:(void*)first,...;// first is argument after self and _cmd (real internal index is 2)

+(id/* DIInvocationProducer* */)producedInvocation:(NSInvocation* *)ivcRef;// just "call" a method right with arguments from me to return NSInvocation instance by ref
-(id/* DIInvocationProducer* */)producedInvocation:(NSInvocation* *)ivcRef;// NSInvocation * readyForMagic; [[self returnInvocation:&readyForMagic] fooA:argA fooB:argB]; [readyForMagic invoke];

+(id/* DIInvocationProducer* */)invocationProducer;
-(id/* DIInvocationProducer* */)invocationProducer;

@end

/*

Usage demo:

#import "NSObject+DIInvocation.h"
#import <Foundation/Foundation.h>

@interface Foo:NSObject
@end

@implementation Foo 
+(void)noArgs{ puts(__PRETTY_FUNCTION__); }
-(void)noArgs{ puts(__PRETTY_FUNCTION__); }
+(void)withArgOne:(int)arg1 andArgTwo:(int)arg2{ printf("%s: %i %i\n",__PRETTY_FUNCTION__,arg1,arg2); }
-(void)withArgOne:(int)arg1 andArgTwo:(int)arg2{ printf("%s: %i %i\n",__PRETTY_FUNCTION__,arg1,arg2); }
@end

int main()
{
 NSAutoreleasePool * arp = [NSAutoreleasePool new];

 [[Foo invocationForSelector:@selector(noArgs)] invoke];

 Foo * foo = [[Foo new] autorelease];
 [[foo invocationForSelector:@selector(noArgs)] invoke];

 int a = 11, b = 12, c = 13; 
 [[Foo invocationForSelector:@selector(withArgOne:andArgTwo:) withArguments:&a, &b, nil] invoke];
 [[foo invocationForSelector:@selector(withArgOne:andArgTwo:) withArguments:&a, &b, nil] invoke];

 [[foo invocationForSelector:@selector(withArgOne:andArgTwo:) withArguments:&a, &b] invoke];// nil is optional
 [[foo invocationForSelector:@selector(withArgOne:andArgTwo:) withArguments:&a, &b, &c] invoke];// no more arguments than it needs

	NSInvocation * magicInvocation;
 [[[foo producedInvocation:&magicInvocation] withArgOne:a andArgTwo:b], magicInvocation invoke];// magic rocks

 [arp drain];
 return 0;
}

*/
