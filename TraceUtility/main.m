//
//  main.m
//  TraceUtility
//
//  Created by Qusic on 7/9/15.
//  Copyright (c) 2015 Qusic. All rights reserved.
//

#import "InstrumentsPrivateHeader.h"

#define NSPrint(format, ...) CFShow((__bridge CFStringRef)[NSString stringWithFormat:format, ## __VA_ARGS__])

// Currently hiding all warnings that are printed to console
// Edit scheme and set OS_ACTIVITY_MODE

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // Required. Each instrument is a plugin and we have to load them before we can process their data.
        DVTInitializeSharedFrameworks();
        [DVTDeveloperPaths initializeApplicationDirectoryName:@"Instruments"];
        [XRInternalizedSettingsStore configureWithAdditionalURLs:nil];
        PFTLoadPlugins();
        
        
        // Trace and CSV file paths
        NSString* inputPath = @"/Users/damianmccabe/Desktop/InstrumentsActivity.trace";
        NSString* outputPath = @"/Users/damianmccabe/Desktop/CPUUsage.csv";
        
        // Open a trace document.
        XRTrace *trace = [[XRTrace alloc]initForCommandLine:NO];
        NSError *error;
        [trace loadDocument:[NSURL fileURLWithPath:inputPath] error:&error];
        if (error) {
            NSLog(@"Error: %@", error);
            return 1;
        } else {
            NSPrint(@"Trace successfully loaded from: %@", inputPath);
        }
        [trace awakeFromTemplate];
        
        // Each trace document consists of data from several different instruments.
        for (XRInstrument *instrument in trace.basicInstruments.allInstruments) {
            
            // You can have multiple runs for each instrument.
            for (XRRun *run in instrument.allRuns) {
                NSPrint(@"\n%@: %@ - %@ (%@ %@ %@)\n", instrument.type.name, run.displayName, run.device.deviceDisplayName, run.device.productType, run.device.productVersion, run.device.buildVersion);
                
                NSPrint(@"Class: %@", run.class);
                
                // CPU (Activity Monitor)
                if ([run isKindOfClass:NSClassFromString(@"XRActivityInstrumentRun")]) {
                    NSPrint(@"Parsing CPU Usage");
                    
                    NSMutableArray *data = [run valueForKey:@"_data"];
                    NSMutableString* csvString = [NSMutableString stringWithString:@"CPU Usage(%)"];
                    
                    for (NSDictionary *entry in data) {
                        NSArray *processes = entry[@"Processes"];
                        
                        for (NSDictionary *item in processes) {
                            if ([item[@"Command"] isEqualToString:@"GreenwichNative"]) {
                                [csvString appendFormat:@"\n%@", item[@"CPUUsage"]];
                            }
                            // NSPrint(@"%@ - %@", item[@"Command"], item[@"CPUUsage"]);
                        }
                    }
                    
                    // NSPrint(csvString);
                    
                    [csvString writeToFile:outputPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
                    if (error) {
                        NSLog(@"Error: %@", error);
                        return 1;
                    } else {
                        NSPrint(@"CPU Usage successfully exported to %@", outputPath);
                    }
                }
                
                // FPS (Core Animation)
                if ([run isKindOfClass:NSClassFromString(@"XRVideoCardRun")]) {
                    NSPrint(@"Parsing FPS");
                    
                    NSMutableArray *data = [run valueForKey:@"_data"];
                    NSMutableString* csvString = [NSMutableString stringWithString:
                                                  @"Time Stamp,Frames Per Second"];
                    
                    for (int i = 0; i < [data count]; i++) {
                        [csvString appendFormat:@"\n%@,%@",
                         data[i][@"XRVideoCardRunTimeStamp"],
                         data[i][@"FramesPerSecond"]];
                    }
                    
                    // NSPrint(csvString);
                    
                    [csvString writeToFile:outputPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
                    if (error) {
                        NSLog(@"Error: %@", error);
                        return 1;
                    } else {
                        NSPrint(@"FPS successfully exported to %@", outputPath);
                    }
                }
                
                
                // Allocations
                if ([run isKindOfClass:NSClassFromString(@"XRObjectAllocRun")]) {
                    NSPrint(@" Parsing Allocations");
                    
                    // NSMutableArray *allStats = ((XRObjectAllocRun *) run).allStats;
                    // NSLog(@"ALL STATS: %@", allStats);
                    
                    // int x = ((XRObjectAllocRun *) run).lifecycleFilter;
                    // NSLog(@"LIFECYCLE FILTER: %@", x);
                }
                
                
                // Here is only one example for runs of the instrument Time Profiler. However it is not difficult for other instruments once we get started.
                // TODO: XRSamplerRun has been deprecated in Xcode 8 and the following code won't work with Time Profiler data generated by Instruments in Xcode 8. Use XRAnalysisCore instead:
                // * -[XRMultiProcessBacktraceRepository initWithDevice:trace:runNumber:weightCount:]
                // * weightCount can be obtained in this path: core -> table -> projector -> spec -> dependentVariableCount
                if ([run isKindOfClass:NSClassFromString(@"XRSamplerRun")]) {
                    XRBacktraceRepository *backtraceRepository = ((XRSamplerRun *)run).backtraceRepository;
                    [backtraceRepository refreshTreeRoot]; // Load the tree.
                    
                    // Process the data as you want.
                    static NSMutableArray * (^ const flattenTree)(PFTCallTreeNode *) = ^(PFTCallTreeNode *rootNode) {
                        NSMutableArray *nodes = [NSMutableArray array];
                        if (rootNode) {
                            [nodes addObject:rootNode];
                            for (PFTCallTreeNode *node in rootNode.children) {
                                [nodes addObjectsFromArray:flattenTree(node)];
                            }
                        }
                        return nodes;
                    };
                    NSMutableArray *nodes = flattenTree(backtraceRepository.rootNode);
                    [nodes sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(terminals)) ascending:NO]]];
                    for (PFTCallTreeNode *node in nodes) {
                        // See the header file for more information about properties of nodes.
                        NSPrint(@"%@ %@ %i ms", node.libraryName, node.symbolName, node.terminals);
                    }
                }
            }
            
        }
    }
    return 0;
}
