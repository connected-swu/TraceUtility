//
//  main.m
//  TraceUtility
//

#import "TraceParsingUtility.h"
#import "XRTrace+TUDataExporting.h"


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        [TraceParsingUtility initializePlugins];
        NSString *traceDirectory = @"/Users/__/Desktop/TraceParsingTest/";
        [TraceParsingUtility forEachTraceFileInDirectoryPath:traceDirectory
                                                     perform:
         ^(NSString *traceFileNameWithoutExtension, XRTrace *trace) {
             [trace tu_exportActivityInstrumentCpuUsageDataWithDirectory:traceDirectory
                                                                  prefix:traceFileNameWithoutExtension];
             [trace tu_exportCoreAnimationInstrumentFpsDataWithDirectory:traceDirectory
                                                                  prefix:traceFileNameWithoutExtension];
             [trace close];
         }];
    }
    return 0;
}
