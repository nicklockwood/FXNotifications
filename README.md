Purpose
--------------

FXNotifications is a category on NSNotificationCenter that provides an improved block-based API that is simpler and easier to use, and avoids the various retain cycle and memory leak pitfalls of the official API.

For more details, see this article: http://sealedabstract.com/code/nsnotificationcenter-with-blocks-considered-harmful/ and this gist: https://gist.github.com/nicklockwood/7559729


Supported iOS & SDK Versions
-----------------------------

* Supported build target - iOS 7.1 / Mac OS 10.9 (Xcode 5.1, Apple LLVM compiler 5.1)
* Earliest supported deployment target - iOS 5.0 / Mac OS 10.7
* Earliest compatible deployment target - iOS 5.0 / Mac OS 10.7

NOTE: 'Supported' means that the library has been tested with this version. 'Compatible' means that the library should work on this iOS version (i.e. it doesn't rely on any unavailable SDK features) but is no longer being tested for compatibility and may require tweaking or bug fixes to run correctly.


ARC Compatibility
------------------

FXNotifications requires ARC and uses weak references.


Thread Safety
--------------

It is safe to add and remove observers concurrently on different threads using the FXNotification methods. Callback blocks will be executed on the specified queue.


Installation & Usage
--------------------

To use FXNotifications, just drag the FXNotifications.h and .m files into your project and import the header file in your class.


Methods
------------

FXNotifications extends NSNotificationCenter with a single method

    - (void)addObserver:(id)observer
                forName:(NSString *)name
                 object:(id)object
                  queue:(NSOperationQueue *)queue
             usingBlock:(void (^)(NSNotification *note, __weak id observer))block;
             
This method is a hybrid of the two built-in notification observer methods. The observer parameter is required, and represents the owner of the block argument. When the observer is released, the block will be released as well.

The name, object, queue and block arguments work as they do in the normal block-based observer method. The queue parameter defaults to [NSOperationQueue currentQueue] if nil. To avoid retain cycles in your block, you can refer to the weak observer parameter that is passed as a second argument.

There is no token value returned; to stop observing the notification, use the standard `-removeObserver:` or `-removeObserver:name:object:` methods of NSNotificationCenter. There is no need to call removeObserver: in the observer's dealloc method; this is done automatically.

An typical usage might be:

    [[NSNotificationCenter defaultCenter] addObserver:self
                                              forName:NSSomeNotificationName
                                               object:nil
                                                queue:[NSOperationQueue mainQueue]
                                           usingBlock:^(NSNotification *note, __weak id observer) {
                                                          NSLog(@"self: %@", observer); // look, no leaks!
                                                      }];
                                                      

Release Notes
-------------------
                                                      
Version 1.0.2

- Fixed bug where observer could not be re-attached after being removed

Version 1.0.1

- Fixed bug where removing the observer didn't work
- The queue parameter now defaults to [NSOperationQueue currentQueue] if nil
- Added CocoaPods podspec

Version 1.0

- Initial release