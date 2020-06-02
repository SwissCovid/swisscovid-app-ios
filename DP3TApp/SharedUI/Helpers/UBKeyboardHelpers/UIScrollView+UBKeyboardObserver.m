/*
 * Copyright (c) 2020 Ubique Innovation AG <https://www.ubique.ch>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

#import "UIScrollView+UBKeyboardObserver.h"

#import "UBKeyboardObserver.h"

#import <objc/runtime.h>

@implementation UIScrollView (UBKeyboardObserver)

- (void)ub_enableDefaultKeyboardObserver
{
    UBKeyboardObserver *observer = [[UBKeyboardObserver alloc] init];
    __weak typeof(self) weakSelf = self;
    observer.callback = ^(CGFloat height) {
        UIEdgeInsets insets = weakSelf.contentInset;
        insets.bottom = [UBKeyboardObserver height:height intoView:weakSelf];
        weakSelf.contentInset = insets;
        weakSelf.scrollIndicatorInsets = insets;
    };
    objc_setAssociatedObject(self, @"keyboardObserver", observer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end
