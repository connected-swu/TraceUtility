//
//  XRTrace+TUDataExporting.m
//  TraceUtility
//

#import "XRTrace+TUDataExporting.h"
#import "XRInstrument+TUPrivate.h"
#import "XRRun+TUPrivate.h"
#import "TraceParsingUtility.h"
#import "NSString+TUFilePathing.h"


@implementation XRTrace (TUDataExporting)

- (void)tu_exportActivityInstrumentCpuUsageDataWithDirectory:(NSString *)directory
                                                      prefix:(NSString *)prefix {
    [self tu_forAllInstrumentsAndRunOfClass:NSClassFromString(@"XRActivityInstrumentRun")
                                    perform:
     ^(XRInstrument *instrument, XRRun *run) {
         NSMutableArray *data = [run valueForKey:@"_data"];
         NSMutableString *csvString = [NSMutableString stringWithString:@"CPU Usage(%)"];
         
         for (NSDictionary *entry in data) {
             NSArray *processes = entry[@"Processes"];
             for (NSDictionary *item in processes) {
                 if ([item[@"Command"] isEqualToString:@"GreenwichNative"]) {
                     [csvString appendFormat:@"\n%@", item[@"CPUUsage"]];
                 }
             }
         }
         
         NSString *csvFilePath = [directory tu_slash:prefix
                                               title:@"cpu_usage"
                                                 uid:[NSString tu_uidFor:instrument run:run]
                                                 ext:@"csv"];
         [TraceParsingUtility saveData:csvString
                                 toCsv:csvFilePath];
     }];
}

- (void)tu_exportCoreAnimationInstrumentFpsDataWithDirectory:(NSString *)directory
                                                      prefix:(NSString *)prefix {
    [self tu_forAllInstrumentsAndRunOfClass:NSClassFromString(@"XRVideoCardRun")
                                    perform:
     ^(XRInstrument *instrument, XRRun *run) {
         NSMutableArray *data = [run valueForKey:@"_data"];
         NSMutableString* csvString = [NSMutableString stringWithString:
                                       @"Time Stamp,Frames Per Second"];
         
         for (int i = 0; i < [data count]; i++) {
             [csvString appendFormat:@"\n%@,%@",
              data[i][@"XRVideoCardRunTimeStamp"],
              data[i][@"FramesPerSecond"]];
         }
         
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
