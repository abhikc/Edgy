//
//  DelaunayTriangle.m
//  DelaunayTest
//
//  Created by Mike Rotondo on 7/17/11.
//  Copyright 2011 Stanford. All rights reserved.
//

#import "DelaunayTriangle.h"
#import "DelaunayTriangulation.h"
#import "DelaunayEdge.h"
#import "DelaunayPoint.h"


@implementation DelaunayTriangle
@synthesize edges;
@synthesize startPoint;
@synthesize color;

+ (DelaunayTriangle *) triangleWithEdges:(NSArray *)edges andStartPoint:(DelaunayPoint *)startPoint;
{
    DelaunayTriangle *triangle = [[[self alloc] init] autorelease];
    triangle.edges = edges;
    triangle.startPoint = startPoint;
    for (DelaunayEdge *edge in edges)
    {
        [edge.triangles addObject:triangle];
    }
    triangle.color = [UIColor colorWithRed:(float)rand() / RAND_MAX
                                     green:(float)rand() / RAND_MAX
                                      blue:(float)rand() / RAND_MAX
                                     alpha:1.0];
    return triangle;
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[self class]])
    {
        return [[NSSet setWithArray:self.edges] isEqualToSet:[NSSet setWithArray:((DelaunayTriangle*)object).edges]];
    }
    return NO;
}
- (NSUInteger)hash
{
    return [[NSSet setWithArray:self.edges] hash];
}

- (BOOL)containsPoint:(DelaunayPoint *)point
{
    DelaunayPoint *edgeStartPoint = self.startPoint;
    for (DelaunayEdge *edge in self.edges)
    {
        if (![edge pointOnLeft:point withStartPoint:edgeStartPoint])
            return NO;
        edgeStartPoint = [edge otherPoint:edgeStartPoint];
    }
    return YES;
}

- (CGPoint)circumcenter
{
    DelaunayPoint *p1 = [self startPointOfEdge:[self.edges objectAtIndex:0]];
    DelaunayPoint *p2 = [self startPointOfEdge:[self.edges objectAtIndex:1]];
    DelaunayPoint *p3 = [self startPointOfEdge:[self.edges objectAtIndex:2]];

    CGPoint midpoint1 = CGPointMake((p1.x + p2.x) / 2.0, (p1.y + p2.y) / 2.0);    
    float m1 = (p2.y - p1.y) / (p2.x - p1.x);
    float perpendicularM1 = -1 / m1;
    float c1 = -perpendicularM1 * midpoint1.x + midpoint1.y;
    
    CGPoint midpoint2 = CGPointMake((p2.x + p3.x) / 2.0, (p2.y + p3.y) / 2.0);
    float m2 = (p3.y - p2.y) / (p3.x - p2.x);
    float perpendicularM2 = -1 / m2;
    float c2 = -perpendicularM2 * midpoint2.x + midpoint2.y;
    
    CGPoint midpoint3 = CGPointMake((p3.x + p1.x) / 2.0, (p3.y + p1.y) / 2.0);
    float m3 = (p1.y - p3.y) / (p1.x - p3.x);
    float perpendicularM3 = -1 / m3;
    float c3 = -perpendicularM3 * midpoint3.x + midpoint3.y;
    
    if (m1 == 0)
    {
        perpendicularM1 = perpendicularM3;
        c1 = c3;
    }
    else if (m2 == 0)
    {
        perpendicularM2 = perpendicularM3;
        c2 = c3;
    }

    float circumcenterX = (c2 - c1) / (perpendicularM1 - perpendicularM2);
    float circumcenterY = perpendicularM1 * circumcenterX + c1;
    
    return CGPointMake(circumcenterX, circumcenterY);
}

- (BOOL)inFrameTriangleOfTriangulation:(DelaunayTriangulation *)triangulation
{
    return [[NSSet setWithArray: self.points] intersectsSet:triangulation.frameTrianglePoints];
}

- (NSArray *)points
{
    NSMutableArray *points = [NSMutableArray arrayWithCapacity:3];
    DelaunayPoint *edgeStartPoint = self.startPoint;
    for (DelaunayEdge *edge in self.edges)
    {
        [points insertObject:edgeStartPoint atIndex:[points count]];
        edgeStartPoint = [edge otherPoint:edgeStartPoint];
    }
    return points;
}

- (NSSet *)neighbors
{
    NSMutableSet *neighbors = [NSMutableSet setWithCapacity:3];
    for (DelaunayEdge *edge in self.edges)
    {
        DelaunayTriangle *neighbor = [edge neighborOf:self];
        if (neighbor != nil)
            [neighbors addObject:neighbor];
    }
    return neighbors;
}

- (DelaunayPoint *)pointNotInEdge:(DelaunayEdge *)edge
{
    if (edge == [self.edges objectAtIndex:0])
        return [((DelaunayEdge *)[self.edges objectAtIndex:2]) otherPoint:self.startPoint];
    else if (edge == [self.edges objectAtIndex:1])
        return self.startPoint;
    else if (edge == [self.edges objectAtIndex:2])
        return [((DelaunayEdge *)[self.edges objectAtIndex:0]) otherPoint:self.startPoint];
    else
    {
        NSLog(@"ASKED FOR POINT NOT IN EDGE THAT IS NOT IN THIS TRIANGLE");
        return nil;
    }
}

- (DelaunayEdge *)edgeStartingWithPoint:(DelaunayPoint *)point
{
    DelaunayPoint *edgeStartPoint = self.startPoint;
    for (DelaunayEdge *edge in self.edges)
    {
        if (edgeStartPoint == point)
            return edge;
        edgeStartPoint = [edge otherPoint:edgeStartPoint];
    }
    NSLog(@"ASKED FOR THE EDGE STARTING WITH A POINT THAT IS NOT IN THIS TRIANGLE");
    return nil;
}
- (DelaunayEdge *)edgeEndingWithPoint:(DelaunayPoint *)point
{
    DelaunayPoint *edgeStartPoint = self.startPoint;
    for (DelaunayEdge *edge in self.edges)
    {
        if ([edge otherPoint:edgeStartPoint] == point)
            return edge;
        edgeStartPoint = [edge otherPoint:edgeStartPoint];
    }
    NSLog(@"ASKED FOR THE EDGE ENDING WITH A POINT THAT IS NOT IN THIS TRIANGLE");
    return nil;
}

- (DelaunayPoint *)startPointOfEdge:(DelaunayEdge *)edgeInQuestion
{
    DelaunayPoint *edgeStartPoint = self.startPoint;
    for (DelaunayEdge *edge in self.edges)
    {
        if (edge == edgeInQuestion)
            return edgeStartPoint;
        edgeStartPoint = [edge otherPoint:edgeStartPoint];
    }
    NSLog(@"ASKED FOR THE START POINT OF EDGE THAT IS NOT IN THIS TRIANGLE");
    return nil;
}
- (DelaunayPoint *)endPointOfEdge:(DelaunayEdge *)edgeInQuestion
{
    DelaunayPoint *edgeStartPoint = self.startPoint;
    for (DelaunayEdge *edge in self.edges)
    {
        if (edge == edgeInQuestion)
            return [edge otherPoint:edgeStartPoint];
        edgeStartPoint = [edge otherPoint:edgeStartPoint];
    }
    NSLog(@"ASKED FOR THE END POINT OF EDGE THAT IS NOT IN THIS TRIANGLE");
    return nil;    
}

- (void)remove
{
    for (DelaunayEdge *edge in self.edges)
    {
        [edge.triangles removeObject:self];
    }
}

- (void)drawInContext:(CGContextRef)ctx
{
    DelaunayPoint *edgeStartPoint = self.startPoint;
    CGContextMoveToPoint(ctx, edgeStartPoint.x, edgeStartPoint.y);
    for (DelaunayEdge *edge in self.edges)
    {
        DelaunayPoint *p2 = [edge otherPoint:edgeStartPoint];
        edgeStartPoint = p2;
        
        CGContextAddLineToPoint(ctx, p2.x, p2.y);
    }
    CGContextAddLineToPoint(ctx, edgeStartPoint.x, edgeStartPoint.y);
}


@end
