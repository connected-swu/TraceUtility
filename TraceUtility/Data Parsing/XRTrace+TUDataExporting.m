//
//  XRTrace+TUDataExporting.m
//  TraceUtility
//

#import "XRTrace+TUDataExporting.h"
#import "XRInstrument+TUPrivate.h"
#import "XRRun+TUPrivate.h"
#import "TraceParsingUtility.h"
#import "TuFpsData.h"
#import "NSString+TUFilePathing.h"
#import "NSArray+TUFunctional.h"


@implementation XRTrace (TUDataExporting)

- (void)tu_exportActivityInstrumentCpuUsageDataForProcess:(NSString *)processName
                                            withDirectory:(NSString *)directory
                                                   prefix:(NSString *)prefix {
    [self tu_forAllInstrumentsAndRunOfClass:NSClassFromString(@"XRActivityInstrumentRun")
                                    perform:
     ^(XRInstrument *instrument, XRRun *run) {
         NSMutableArray *data = [run valueForKey:@"_data"];
         
         // 1)  Process data
         NSArray <NSNumber *> *dataPoints = [data tu_map:^id(NSDictionary *rawDataEntry) {
             NSArray <NSDictionary *> *processes = rawDataEntry[@"Processes"];
             return [[processes tu_filter:^BOOL(NSDictionary *process) {
                 return [process[@"Command"] isEqualToString:processName];
             }] firstObject][@"CPUUsage"];
         }];
         // Removing first data entry since it is always 0
         dataPoints = [dataPoints subarrayWithRange:NSMakeRange(1, dataPoints.count-1)];
         
         // 2)  Data analysis
         NSNumber *averageCpuUsage = @([[dataPoints tu_reduce:^id(NSNumber *total, NSNumber *usage) {
             return @([total floatValue] + [usage floatValue]);
         } initialAccumulator:@(0)] floatValue] / (float)dataPoints.count);
         NSMutableArray <NSNumber *> *sortedDataPoints = dataPoints.mutableCopy;
         [sortedDataPoints sortUsingSelector:@selector(compare:)];
         
         // 3)  Construct CSV data
         NSMutableString *csvString = [NSMutableString stringWithString:@"CPU Usage(%)"];
         [dataPoints tu_reduce:^id(NSMutableString *accumulator, NSNumber *cpuUsage) {
             [accumulator appendFormat:@"\n%@", cpuUsage];
             return accumulator;
         } initialAccumulator:csvString];
         [csvString appendString:@"\n\n"];
         [csvString appendFormat:@"\nAverage CPU usage:,%@", averageCpuUsage];
         [csvString appendFormat:@"\nMin usage:,%@", [sortedDataPoints firstObject]];
         [csvString appendFormat:@"\nMax usage:,%@", [sortedDataPoints lastObject]];
         
         // 4) Save data to file
         NSString *csvFilePath = [directory tu_slash:prefix
                                               title:@"cpu_usage"
                                                 uid:[NSString tu_uidFor:instrument run:run]
                                                 ext:@"csv"];
         [TraceParsingUtility saveData:csvString
                                 toCsv:csvFilePath];
     }];
}

- (void)tu_exportCoreAnimationInstrumentFpsDataWithDirectory:(NSString *)directory
                                                      prefix:(NSString *)prefix
                                                      option:(TuFpsDataOption)option {
    [self tu_forAllInstrumentsAndRunOfClass:NSClassFromString(@"XRVideoCardRun")
                                    perform:
     ^(XRInstrument *instrument, XRRun *run) {
         NSMutableArray *data = [run valueForKey:@"_data"];
         
         // 1)  Filter the data based on option
         NSArray <TuFpsData *> *dataPoints = [[data tu_map:^id(NSDictionary *rawFpsData) {
             NSNumber *frames = rawFpsData[@"FramesPerSecond"];
             switch (option) {
                 default:
                 case TuFpsDataOptionDefault:
                     break;
                 case TuFpsDataOptionTreat0as60:
                     frames = ([frames integerValue] == 0) ? @60 : frames;
                     break;
                 case TuFpsDataOptionIgnore0s:
                     frames = ([frames integerValue] == 0) ? nil : frames;
                     break;
             }
             return [TuFpsData withTimeStamp:rawFpsData[@"XRVideoCardRunTimeStamp"]
                                      frames:frames] ? : [NSNull null];
         }] tu_filter:^BOOL(id dataItem) {
             return ![dataItem isEqual:[NSNull null]];
         }];
         
         // 2)  Bucket the data for analysis
         NSDictionary <NSNumber *, NSArray *> *bucketedData = [dataPoints tu_reduce:^id(NSMutableDictionary <NSNumber *, NSMutableArray *> *accumulator, TuFpsData *data) {
             NSNumber *key = @([data.frames integerValue]/10);
             if ([data.frames integerValue] == 60) {
                 key = @5;
             }
             NSMutableArray *bucket = accumulator[key];
             if (!bucket) {
                 bucket = [NSMutableArray array];
                 accumulator[key] = bucket;
             }
             [bucket addObject:data];
             return accumulator;
         } initialAccumulator:[NSMutableDictionary dictionary]];
         
         // 3)  Data analysis
         NSNumber *percentJanky = @((float)(bucketedData[@0].count +
                                            bucketedData[@1].count +
                                            bucketedData[@2].count) / (float)dataPoints.count);
         NSArray <NSNumber *> *sortedKeys = [bucketedData.allKeys sortedArrayUsingSelector:@selector(compare:)];
         NSMutableArray <TuFpsData *> *lowestFrameBucket = bucketedData[[sortedKeys firstObject]].mutableCopy;
         [lowestFrameBucket sortUsingComparator:^NSComparisonResult(TuFpsData * _Nonnull obj1, TuFpsData * _Nonnull obj2) {
             return [obj1.frames compare:obj2.frames];
         }];
         NSMutableArray <TuFpsData *> *highestFrameBucket = bucketedData[[sortedKeys lastObject]].mutableCopy;
         [highestFrameBucket sortUsingComparator:^NSComparisonResult(TuFpsData * _Nonnull obj1, TuFpsData * _Nonnull obj2) {
             return [obj1.frames compare:obj2.frames];
         }];
         NSNumber *minFrames = [lowestFrameBucket firstObject].frames;
         NSNumber *maxFrames = [highestFrameBucket lastObject].frames;

         // 4)  Construct CSV data
         NSMutableString *csvString = [NSMutableString stringWithString:
                                       @"Time Stamp,Frames Per Second"];
         [dataPoints tu_reduce:^id(NSMutableString *accumulator, TuFpsData *data) {
             [accumulator appendFormat:@"\n%@,%@", data.timeStamp, data.frames];
             return accumulator;
         } initialAccumulator:csvString];
         [csvString appendString:@"\n\n"];
         [csvString appendFormat:@"\nJanky frames:,%@", percentJanky];
         [csvString appendFormat:@"\nMin FPS:,%@", minFrames];
         [csvString appendFormat:@"\nMax FPS:,%@", maxFrames];
         [csvString appendFormat:@"\n0-9:,%@", @(bucketedData[@0].count)];
         [csvString appendFormat:@"\n10-19:,%@", @(bucketedData[@2].count)];
         [csvString appendFormat:@"\n20-29:,%@", @(bucketedData[@3].count)];
         [csvString appendFormat:@"\n30-39:,%@", @(bucketedData[@3].count)];
         [csvString appendFormat:@"\n40-49:,%@", @(bucketedData[@4].count)];
         [csvString appendFormat:@"\n50-60:,%@", @(bucketedData[@5].count)];
         
         // 5)  Save data to file
         NSString *csvFilePath = [directory tu_slash:prefix
                                               title:@"fps"
                                                 uid:[NSString tu_uidFor:instrument run:run]
                                                 ext:@"csv"];
         [TraceParsingUtility saveData:csvString
                                 toCsv:csvFilePath];
     }];
}


#pragma mark - Other helpers

- (NSArray <XRInstrument *> *)tu_allInstruments {
    return self.basicInstruments.allInstruments;
}

- (void)tu_forAllInstrumentsAndRunOfClass:(Class)klazz
                                  perform:(void (^)(XRInstrument *instrument, XRRun *run))task {
    for (XRInstrument *instrument in [self tu_allInstruments]) {
        for (XRRun *run in instrument.allRuns) {
            if ([run isKindOfClass:klazz] && task) {
                task(instrument, run);
            }
        }
    }
}

@end
