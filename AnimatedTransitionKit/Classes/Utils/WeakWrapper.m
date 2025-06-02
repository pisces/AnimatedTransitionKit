//  BSD 2-Clause License
//
//  Copyright (c) 2016 ~, Steve Kim
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  * Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//
//  * Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
//  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
//  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
//  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
//  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
//  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  WeakWrapper.m
//  AnimatedTransitionKit
//
//  Created by Steve Kim on 5/30/25.
//

#import "WeakWrapper.h"
#import <objc/runtime.h>

@implementation WeakWrapper
- (instancetype)initWithValue:(_Nullable id)value {
    self = [super init];
    if (self) {
        _value = value;
    }
    return self;
}
@end

void setWeakAssociatedObject(id host, const void *key, _Nullable id value) {
    WeakWrapper *wrapper = [[WeakWrapper alloc] initWithValue:value];
    objc_setAssociatedObject(host, key, wrapper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

id getAssociatedObject(id host, const void *key) {
    id value = objc_getAssociatedObject(host, key);
    if ([value isKindOfClass:[WeakWrapper class]]) {
        WeakWrapper *wrapper = (WeakWrapper *) value;
        return wrapper.value;
    }
    return value;
}
