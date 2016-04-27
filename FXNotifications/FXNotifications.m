//
//  FXNotifications.m
//
//  Version 1.1.1
//
//  Created by Nick Lockwood on 20/11/2013.
//  Copyright (c) 2013 Charcoal Design
//
//  Distributed under the permissive zlib license
//  Get the latest version from here:
//
//  https://github.com/nicklockwood/FXNotifications
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//


#import "FXNotifications.h"
#import <objc/runtime.h>


#pragma GCC diagnostic ignored "-Wobjc-missing-property-synthesis"
#pragma GCC diagnostic ignored "-Wselector"
#pragma GCC diagnostic ignored "-Wgnu"


#import <Availability.h>
#if !__has_feature(objc_arc) || !__has_feature(objc_arc_weak)
#error This class requires automatic reference counting and weak references
#endif


typedef void (^FXNotificationBlock)(NSNotification *note, id observer);


static NSMutableArray *FXNotificationsGetObservers(id object, BOOL create)
{
    @synchronized(object)
    {
        static void *key = &key;
        NSMutableArray *wrappers = objc_getAssociatedObject(object, key);
        if (!wrappers && create)
        {
            wrappers = [NSMutableArray array];
            objc_setAssociatedObject(object, key, wrappers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        return wrappers;
    }
}


@interface FXNotificationObserver : NSObject

@property (nonatomic, weak) NSObject *observer;
@property (nonatomic, weak) NSObject *object;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) FXNotificationBlock block;
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, weak) NSNotificationCenter *center;

- (void)action:(NSNotification *)note;

@end


@implementation FXNotificationObserver

- (void)action:(NSNotification *)note
{
    __strong id strongObserver = self.observer;
    if (self.block && strongObserver)
    {
        if (!self.queue || [NSOperationQueue currentQueue] == self.queue)
        {
            self.block(note, strongObserver);
        }
        else
        {
            [self.queue addOperationWithBlock:^{
                self.block(note, strongObserver);
            }];
        }
    }
}

- (void)dealloc
{
    __strong NSNotificationCenter *strongCenter = _center;
    [strongCenter removeObserver:self];
}

@end


@implementation NSNotificationCenter (FXNotifications)

+ (void)load
{
    SEL original = @selector(removeObserver:name:object:);
    SEL replacement = @selector(FXNotification_removeObserver:name:object:);
    method_exchangeImplementations(class_getInstanceMethod(self, original),
                                   class_getInstanceMethod(self, replacement));
}

- (id)addObserver:(id)observer
          forName:(nullable NSString *)name
           object:(nullable id)object
            queue:(nullable NSOperationQueue *)queue
       usingBlock:(FXNotificationBlock)block
{
    FXNotificationObserver *container = [[FXNotificationObserver alloc] init];
    container.observer = observer;
    container.object = object;
    container.name = name;
    container.block = block;
    container.queue = queue;
    container.center = self;
    
    [FXNotificationsGetObservers(observer, YES) addObject:container];
    [self addObserver:container selector:@selector(action:) name:name object:object];
    return container;
}

- (void)FXNotification_removeObserver:(id)observer name:(NSString *)name object:(id)object
{
    for (FXNotificationObserver *container in [FXNotificationsGetObservers(observer, NO) reverseObjectEnumerator])
    {
        __strong id strongObject = container.object;
        if (container.center == self &&
            (!container.name || !name || [container.name isEqualToString:name]) &&
            (!strongObject || !object || strongObject == object))
        {
            [FXNotificationsGetObservers(observer, NO) removeObject:container];
        }
    }
    if (object_getClass(observer) == [FXNotificationObserver class])
    {
        FXNotificationObserver *container = observer;
        __strong NSObject *strongObserver = container.observer;
        [FXNotificationsGetObservers(strongObserver, NO) removeObject:container];
    }
    [self FXNotification_removeObserver:observer name:name object:object];
}

@end

