//
//  XRTrace+TUPrivate.h
//  TraceUtility
//

#import <Foundation/Foundation.h>
#import "PFTInstrumentList+TUPrivate.h"


@interface XRTrace : NSObject
- (instancetype)initForCommandLine:(BOOL)commandLine;
- (BOOL)loadDocument:(NSURL *)documentURL error:(NSError **)errpt;
- (void)awakeFromTemplate;
- (void)close;
- (PFTInstrumentList *)basicInstruments;
@end
