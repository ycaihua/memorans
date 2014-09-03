//
//  MemoransBehavior.m
//  Memorans
//
//  Created by emi on 17/08/14.
//  Copyright (c) 2014 Emiliano D'Alterio. All rights reserved.
//

#import "MemoransBehavior.h"

@interface MemoransBehavior () <UICollisionBehaviorDelegate>

#pragma mark - PROPERTIES

@property(strong, nonatomic) UIPushBehavior *push;
@property(strong, nonatomic) UICollisionBehavior *collision;
@property(strong, nonatomic) UIDynamicItemBehavior *bouncing;

@end

@implementation MemoransBehavior

#pragma mark - SETTERS AND GETTERS

- (UIPushBehavior *)push
{
    if (!_push)
    {
        _push = [[UIPushBehavior alloc] init];
        _push.magnitude = 10000.0f;
        _push.angle = 1.44f;
    }

    return _push;
}

- (UICollisionBehavior *)collision
{
    if (!_collision)
    {
        _collision = [[UICollisionBehavior alloc] init];
        _collision.collisionDelegate = self;
        _collision.translatesReferenceBoundsIntoBoundary = NO;

        CGRect screenBounds = [[UIScreen mainScreen] bounds];

        CGFloat shortSide = MIN(screenBounds.size.width, screenBounds.size.height);
        CGFloat longSide = MAX(screenBounds.size.width, screenBounds.size.height);

        CGPoint topLeft = CGPointMake(0, 0);
        CGPoint topRight = CGPointMake(longSide, 0);
        CGPoint bottomLeft = CGPointMake(0, shortSide);
        CGPoint bottomRight = CGPointMake(longSide, shortSide);

        [_collision addBoundaryWithIdentifier:@"1" fromPoint:topLeft toPoint:topRight];
        [_collision addBoundaryWithIdentifier:@"2" fromPoint:topRight toPoint:bottomRight];
        [_collision addBoundaryWithIdentifier:@"3" fromPoint:bottomRight toPoint:bottomLeft];
        [_collision addBoundaryWithIdentifier:@"4" fromPoint:bottomLeft toPoint:topLeft];
    }

    return _collision;
}

- (UIDynamicItemBehavior *)bouncing
{
    if (!_bouncing)
    {
        _bouncing = [[UIDynamicItemBehavior alloc] init];
        _bouncing.elasticity = 0.9f;
        _bouncing.allowsRotation = YES;
    }

    return _bouncing;
}

#pragma mark - ITEMS

- (void)addItem:(id<UIDynamicItem>)item
{
    [self.push addItem:item];
    [self.collision addItem:item];
    [self.bouncing addItem:item];
}

- (void)removeItem:(id<UIDynamicItem>)item
{
    [self.push removeItem:item];
    [self.collision removeItem:item];
    [self.bouncing removeItem:item];
}

#pragma mark - INIT

- (instancetype)init
{
    self = [super init];

    if (self)
    {
        [self addChildBehavior:self.push];
        [self addChildBehavior:self.collision];
        [self addChildBehavior:self.bouncing];
    }

    return self;
}

- (instancetype)initWithItems:(NSArray *)items
{
    self = [self init];

    if (self)
    {
        for (id<UIDynamicItem> item in items)
        {
            [self addItem:item];
        }
    }

    return self;
}

#pragma mark - UICollisionBehaviorDelegate PROTOCOL

- (void)collisionBehavior:(UICollisionBehavior *)behavior
      beganContactForItem:(id<UIDynamicItem>)item1
                 withItem:(id<UIDynamicItem>)item2
                  atPoint:(CGPoint)p
{
    [self.push removeItem:item1];
    [self.push removeItem:item2];
}

@end
