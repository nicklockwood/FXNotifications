Purpose
--------------

FXNotifications is a category on `NSNotificationCenter` that provides an improved block-based API that is simpler and easier to use, and avoids the various retain cycle and memory leak pitfalls of the official API.

For more details, see this article: http://sealedabstract.com/code/nsnotificationcenter-with-blocks-considered-harmful/ and this gist: https://gist.github.com/nicklockwood/7559729


Supported iOS & SDK Versions
-----------------------------

* Supported build target - iOS 9.3 / Mac OS 10.11 (Xcode 7.3, Apple LLVM compiler 7.0)
* Earliest supported deployment target - iOS 7.0 / Mac OS 10.10
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

    - (id)addObserver:(id)observer
              forName:(nullable NSString *)name
               object:(nullable id)object
                queue:(NSOperationQueue *)queue
           usingBlock:(void (^)(NSNotification *note, id observer))block;
             
This method is a hybrid of the two built-in notification observer methods. The observer parameter is required, and represents the owner of the block argument. When the observer is released, the block will be released as well.

The name, object, queue and block arguments work as they do in the normal block-based observer method. The queue parameter is optional - if nil is passed then the block will be executed on whichever queue the notification is posted from. To avoid retain cycles in your block, you can refer to the weak observer parameter that is passed as a second argument.

The method returns a token value that can be used to stop observing the notification, use the standard `-removeObserver:` method  of `NSNotificationCenter`, e.g.

    [[NSNotificationCenter defaultCenter] removeObserver:token];
    
However, you can simply discard this token and the token will be deregistered automatically when the observer is released. There is no need to call removeObserver: in the observer's dealloc method; this is done automatically.

Also, if you wish, you can deregister the observer itself using the `-removeObserver:` or `-removeObserver:name:object:` methods of `NSNotificationCenter`, so the only reason to store the token is if you wish to distinguish between multiple registrations of the same observer with the same selector.

A typical usage might be:

    [[NSNotificationCenter defaultCenter] addObserver:self
                                              forName:NSSomeNotificationName
                                               object:nil
                                                queue:[NSOperationQueue mainQueue]
                                           usingBlock:^(NSNotification *note, id observer) {
                                                          NSLog(@"self: %@", observer); // look, no leaks!
                                                      }];
                                                      

Release Notes
-------------------

Version 1.1.1

- Removed implicit assumption that observers are NSObject subclasses (fixes issues with Swift)
- Added nullability annotations

Version 1.1

- FXNotifications no longer captures the current queue if nil is passed as the queue parameter. Instead, the block will simply be executed on whichever queue the notification is posted on.
- Observer is no longer passed as a weak parameter to the block, which means that it is guaranteed not to be released during the block's execution
- addObserver method now returns a unique token each time it is called, allowing it to be used in the same way as the standard implementation for fine-grained reregistration (use of the token is optional however, you can safely discard it if not needed)
- Now conforms to `-Weverything` warning level
                                                      
Version 1.0.2

- Fixed bug where observer could not be re-attached after being removed

Version 1.0.1

- Fixed bug where removing the observer didn't work
- The queue parameter now defaults to `[NSOperationQueue currentQueue]` if nil
- Added CocoaPods podspec

Version 1.0

- Initial release
