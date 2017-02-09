//
//  UIViewControllerTransitionsMacro.h
//  ModalTransitionAnimator
//
//  Created by Steve Kim on 5/12/16.
//
//

#ifndef UIViewControllerTransitionsMacro_h
#define UIViewControllerTransitionsMacro_h

#define CGRectMakeX(rect, x) CGRectMake(x, rect.origin.y, rect.size.width, rect.size.height)
#define CGRectMakeXY(rect, x, y) CGRectMake(x, y, rect.size.width, rect.size.height)
#define CGRectMakeY(rect, y) CGRectMake(rect.origin.x, y, rect.size.width, rect.size.height)
#define CGRectMakeW(rect, w) CGRectMake(rect.origin.x, rect.origin.y, w, rect.size.height)
#define CGRectMakeWH(rect, w, h) CGRectMake(rect.origin.x, rect.origin.y, w, h)
#define CGRectMakeH(rect, h) CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, h)

#endif /* UIViewControllerTransitionsMacro_h */
