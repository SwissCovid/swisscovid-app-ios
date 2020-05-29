/*
 * Copyright (c) 2020 Ubique Innovation AG <https://www.ubique.ch>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

#import <UIKit/UIKit.h>

struct UBColor
{
    NSInteger r;
    NSInteger g;
    NSInteger b;
    NSInteger a;
};

typedef NS_ENUM(NSUInteger, UBImageModificationOpaqueMode)
{
    UBImageModificationOpaqueModeAsOriginal,
    UBImageModificationOpaqueModeOpque,
    UBImageModificationOpaqueModeTransparent,
};


@interface UIImage (UBHelpers)
+ (UIImage *)ub_imageWithColor:(UIColor *)color;

- (UIImage *)ub_imageWithColor:(UIColor *)color;
- (UIImage *)ub_imageByFillingMaskWithColor:(UIColor *)color;

- (UIImage *)ub_imageByScaling:(CGFloat)scale;

- (UIImage *)ub_imageWithOpaqueMode:(UBImageModificationOpaqueMode)opaqueMode
              byApplyingBlockToPixels:(struct UBColor (^)(struct UBColor c, CGPoint p))block;

@end
