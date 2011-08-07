//
//  DelaunayTestViewController.m
//  DelaunayTest
//
//  Created by Mike Rotondo on 7/17/11.
//  Copyright 2011 Stanford. All rights reserved.
//

#import "DelaunayTestViewController.h"
#import "DelaunayView.h"
#import "DelaunayPoint.h"
#import "VoronoiCell.h"

@implementation DelaunayTestViewController
@synthesize triangulation;
@synthesize interpaderpSwitch;
@synthesize interpolating;

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self reset];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self reset];
}

- (void)reset
{
    self.triangulation = [DelaunayTriangulation triangulation];
    ((DelaunayView *)self.view).triangulation = triangulation;
    self.interpaderpSwitch.on = NO;
    self.interpolating = NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (interpolating)
    {
        UITouch *touch = (UITouch *)[touches anyObject];
        CGPoint loc = [touch locationInView:self.view];
        DelaunayPoint *newPoint = [DelaunayPoint pointAtX:loc.x andY:loc.y];
        [self.triangulation interpolateWeightsWithPoint:newPoint];
        [self.view setNeedsDisplay];
    }
    else
    {
        UITouch *touch = (UITouch *)[touches anyObject];
        CGPoint loc = [touch locationInView:self.view];
        DelaunayPoint *newPoint = [DelaunayPoint pointAtX:loc.x andY:loc.y];
        [self.triangulation addPoint:newPoint];

        
        BOOL mirror = NO;
        if ( mirror )
        {
            CGSize size = self.view.bounds.size;
            
            // top left
            CGPoint mirrorLoc = CGPointMake(-loc.x, -loc.y);
            newPoint = [DelaunayPoint pointAtX:mirrorLoc.x andY:mirrorLoc.y];
            [self.triangulation addPoint:newPoint];
            
            // top
            mirrorLoc = CGPointMake(loc.x, -loc.y);
            newPoint = [DelaunayPoint pointAtX:mirrorLoc.x andY:mirrorLoc.y];
            [self.triangulation addPoint:newPoint];
            
            // top right
            mirrorLoc = CGPointMake(size.width + loc.x, -loc.y);
            newPoint = [DelaunayPoint pointAtX:mirrorLoc.x andY:mirrorLoc.y];
            [self.triangulation addPoint:newPoint];
            
            // left
            mirrorLoc = CGPointMake(-loc.x, loc.y);
            newPoint = [DelaunayPoint pointAtX:mirrorLoc.x andY:mirrorLoc.y];
            [self.triangulation addPoint:newPoint];
            
            // right
            mirrorLoc = CGPointMake(size.width + loc.x, loc.y);
            newPoint = [DelaunayPoint pointAtX:mirrorLoc.x andY:mirrorLoc.y];
            [self.triangulation addPoint:newPoint];
            
            // bottom left
            mirrorLoc = CGPointMake(-loc.x, size.height + loc.y);
            newPoint = [DelaunayPoint pointAtX:mirrorLoc.x andY:mirrorLoc.y];
            [self.triangulation addPoint:newPoint];
            
            // bottom
            mirrorLoc = CGPointMake(loc.x, size.height + loc.y);
            newPoint = [DelaunayPoint pointAtX:mirrorLoc.x andY:mirrorLoc.y];
            [self.triangulation addPoint:newPoint];
            
            // bottom right
            mirrorLoc = CGPointMake(size.width + loc.x, size.height + loc.y);
            newPoint = [DelaunayPoint pointAtX:mirrorLoc.x andY:mirrorLoc.y];
            [self.triangulation addPoint:newPoint];
        }
        
        
        [self.view setNeedsDisplay];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (interpolating)
    {
        UITouch *touch = (UITouch *)[touches anyObject];
        CGPoint loc = [touch locationInView:self.view];
        DelaunayPoint *newPoint = [DelaunayPoint pointAtX:loc.x andY:loc.y];
        [self.triangulation interpolateWeightsWithPoint:newPoint];
        [self.view setNeedsDisplay];
    }
}

- (IBAction)toggleInterpolation:(UISwitch *)sender
{
    self.interpolating = sender.on;
}

@end
