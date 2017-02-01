//
//  NSArray+TUFunctional.h
//  TraceUtility
//

#import <Foundation/Foundation.h>

typedef id (^TuReduceBlock)(id accumulator, id nextValue);
typedef id (^TuMapBlock)(id value);
typedef BOOL (^TuFilterBlock)(id value);


@interface NSArray (TUFunctional)
- (id)tu_reduce:(TuReduceBlock)block initialAccumulator:(id)accumulator;
- (id)tu_map:(TuMapBlock)block;
- (id)tu_filter:(TuFilterBlock)block;
@end
