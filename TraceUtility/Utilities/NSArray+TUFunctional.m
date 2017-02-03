//
//  NSArray+TUFunctional.m
//  TraceUtility
//

#import "NSArray+TUFunctional.h"


@implementation NSArray (TUFunctional)

- (id)tu_reduce:(TuReduceBlock)block initialAccumulator:(id)accumulator {
    for (id nextItem in self) {
        accumulator = block(accumulator, nextItem);
    }
    return accumulator;
}

- (id)tu_map:(TuMapBlock)block {
    return [self tu_reduce:^id(NSMutableArray *accumulator, id nextValue) {
        [accumulator addObject:block(nextValue)];
        return accumulator;
    } initialAccumulator:[NSMutableArray array]];
}

- (id)tu_filter:(TuFilterBlock)block {
    return [self tu_reduce:^id(NSMutableArray *accumulator, id nextValue) {
        if (block(nextValue)) {
            [accumulator addObject:nextValue];
        }
        return accumulator;
    } initialAccumulator:[NSMutableArray array]];
}

@end
