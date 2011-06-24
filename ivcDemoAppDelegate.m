//
//  ivcDemoAppDelegate.m
//  ivcDemo
//
//  Created by Uncle MiF on 4/19/10.
//  Copyright 2010 Deep IT. All rights reserved.
//

#import "ivcDemoAppDelegate.h"
#import "NSObject+DIInvocation.h"

@implementation ivcDemoAppDelegate

@synthesize window;

-(NSString*)description2
{
	return @"hey...";
}

-(void)test2
{
	NSLog(@"%s",__PRETTY_FUNCTION__);
}

-(float)addVal:(float)val1 toVal:(float)val2
{
	return val1 + val2;
}

-(int)printer:(const char*)fmt,...
{
	va_list list;
	va_start(list,fmt);
	vprintf(fmt,list);
	va_end(list);
	return 13;
}

-(double)summer:(double)first,...
{
	double sum = first;
	va_list list;
	va_start(list,first);
	double cur;
	while((cur = va_arg(list,double)))
	{
		sum += cur;
		NSLog(@"+ %lf -> %lf",cur,sum);
	}
	va_end(list);
	return sum;
}

+(void)noArgs{ puts(__PRETTY_FUNCTION__); }
-(void)noArgs{ puts(__PRETTY_FUNCTION__); }
+(void)withArgOne:(int)arg1 andArgTwo:(int)arg2{ printf("%s: %i %i\n",__PRETTY_FUNCTION__,arg1,arg2); }
-(void)withArgOne:(int)arg1 andArgTwo:(int)arg2{ printf("%s: %i %i\n",__PRETTY_FUNCTION__,arg1,arg2); }	

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[[[self class] invocationForSelector:@selector(noArgs)] invoke];
	
 [[self invocationForSelector:@selector(noArgs)] invoke];
	
 int a = 11, b = 12, c = 13; 
 [[[self class] invocationForSelector:@selector(withArgOne:andArgTwo:) withArguments:&a, &b, nil] invoke];
 [[self invocationForSelector:@selector(withArgOne:andArgTwo:) withArguments:&a, &b, nil] invoke];
	
 [[self invocationForSelector:@selector(withArgOne:andArgTwo:) withArguments:&a, &b] invoke];// nil is optional
 [[self invocationForSelector:@selector(withArgOne:andArgTwo:) withArguments:&a, &b, &c] invoke];// no more arguments than it needs
	
	NSInvocation * ivc;
	
	id ivb = [self producedInvocation:&ivc];
	[ivb description2];
	NSLog(@"ivb: %p",ivb);
	NSLog(@"ivc: %@",ivc);
 [ivc invoke];
	id result;
	result = nil, [ivc getReturnValue:&result];
	NSLog(@"result: %@",result);

	[[DIInvocationProducer producerForObject:self outInvocation:&ivc] test2];
	NSLog(@"ivc: %@",ivc);	
	[ivc invoke];

	id ivcFactory = [self invocationProducer];
	[ivcFactory test2];
	ivc = [ivcFactory producedInvocation];
	NSLog(@"ivc: %@",ivc);	
	[ivc invoke];

	ivcFactory = [DIInvocationProducer producerForObject:self];
	[ivcFactory description];
	ivc = [ivcFactory producedInvocation];
	NSLog(@"ivc: %@",ivc);	
	[ivc invoke];
	result = nil, [ivc getReturnValue:&result];
	NSLog(@"result: %@",result);

	ivcFactory = [[self class] invocationProducer];
	[ivcFactory description];
	ivc = [ivcFactory producedInvocation];
	NSLog(@"ivc: %@",ivc);	
	[ivc invoke];
	result = nil, [ivc getReturnValue:&result];
	NSLog(@"result: %@",result);	

	[[[self class] producedInvocation:&ivc] description];
	NSLog(@"ivc: %@",ivc);	
	[ivc invoke];
	result = nil, [ivc getReturnValue:&result];
	NSLog(@"result: %@",result);	

	[[self producedInvocation:&ivc] addVal:2.0 toVal:40.0];
	NSLog(@"ivc: %@",ivc);	
	[ivc invoke];
	float fResult;
	fResult = 0.0, [ivc getReturnValue:&fResult];
	NSLog(@"result: %f",fResult);	

	ivcFactory = [DIInvocationProducer producerForObject:nil];
	[ivcFactory description];
	ivc = [ivcFactory producedInvocation];
	NSLog(@"ivc: %@",ivc);	
	[ivc invoke];
	result = nil, [ivc getReturnValue:&result];
	NSLog(@"result: %@",result);	
	
	[self printer:"%s, hi!\n","World"];
	
	[[[self producedInvocation:&ivc] printer:"%s, test!\n","variable ivc..."], ivc invoke];
	int iResult;
	iResult = 0; [ivc getReturnValue:&iResult];
	NSLog(@"result: %i",iResult);

	NSLog(@"expecting: %lf",[self summer:(double)11.0,(double)2,(double)3,(double)4,(double)22,(double)0]);

	[[self producedInvocation:&ivc] summer:(double)11,(double)2,(double)3,(double)4,(double)22,(double)0];
	[self performSelectorInBackground:@selector(backgroundInvoke:) withObject:ivc];

	NSMutableString * str = [@"str" mutableCopy];
	[[[NSString producedInvocation:&ivc] stringWithString:str], 
		[ivc retainArguments], [str release],
			ivc invoke];
	result = nil; [ivc getReturnValue:&result];
	NSLog(@"result: %@",result);		

	char * cStr = strdup("cStr");
	[[[NSString producedInvocation:&ivc] stringWithCString:cStr], [ivc retainArguments], (*cStr = 0), free(cStr), ivc invoke];
	result = nil; [ivc getReturnValue:&result];
	NSLog(@"result: %@",result);
	
	int i;
	for (i = 0; i < 100; i++)
	{
		id iProducer = [[[self invocationProducer] retain] autorelease];
		[iProducer summer:(double)11,(double)2,(double)3,(double)4,(double)22,(double)0];
		[iProducer producedInvocation:&ivc];
		[self performSelectorInBackground:@selector(backgroundInvoke:) withObject:ivc];
	}
}

-(void)backgroundInvoke:(NSInvocation*)ivc
{
	NSAutoreleasePool * arp = [NSAutoreleasePool new];
	double dResult;
	[ivc invoke];
	dResult = 0; [ivc getReturnValue:&dResult];
	NSLog(@"%s: result: %lf",__PRETTY_FUNCTION__,dResult);		
	[arp drain];
}

@end
