//
//  XRDevice+TUPrivate.h
//  TraceUtility
//

#import <Foundation/Foundation.h>


@interface XRDevice : NSObject
- (NSString *)deviceIdentifier;
- (NSString *)deviceDisplayName;
- (NSString *)deviceDescription;
- (NSString *)productType;
- (NSString *)productVersion;
- (NSString *)buildVersion;
@end
