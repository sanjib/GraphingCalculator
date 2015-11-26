//
//  GraphingViewController.swift
//  GraphingCalculator
//
//  Created by Sanjib Ahmad on 11/15/15.
//  Copyright © 2015 Object Coder. All rights reserved.
//

import UIKit

class GraphingViewController: UIViewController, GraphingViewDataSource {
    private struct Constants {
        static let ScaleAndOrigin = "scaleAndOrigin"
    }
    
    @IBOutlet weak var graphingView: GraphingView! {
        didSet {
            graphingView.dataSource = self
            if let scaleAndOrigin = userDefaults.objectForKey(Constants.ScaleAndOrigin) as? [String: String] {
                graphingView.scaleAndOrigin = scaleAndOrigin
            }
        }
    }
    
    var program: AnyObject?
    var graphLabel: String? {
        didSet {
            title = graphLabel
        }
    }
    private let userDefaults = NSUserDefaults.standardUserDefaults()
    
    func graphPlot(sender: GraphingView) -> [(x: Double, y: Double)]? {
        let minXDegree = Double(sender.minX) * (180 / M_PI)
        let maxXDegree = Double(sender.maxX) * (180 / M_PI)
        
        var plots = [(x: Double, y: Double)]()
        let brain = CalculatorBrain()
        
        if let program = program {
            brain.program = program
            
            // Performance fix to remove sluggish behavior (specially when screen is zoomed out):
            // a. the difference between minXDegree and maxXDegree will be high when zoomed out
            // b. the screen width has a fixed number of pixels, so we need to iterate only
            //    for the number of available pixels
            // c. loopIncrementSize ensures that the count of var plots will always be fixed to
            //    the number of available pixels for screen width
            let loopIncrementSize = (maxXDegree - minXDegree) / sender.availablePixelsInXAxis
            
            for (var i = minXDegree; i <= maxXDegree; i = i + loopIncrementSize) {
                let radian = Double(i) * (M_PI / 180)
                brain.variableValues["M"] = radian
                let evaluationResult = brain.evaluateAndReportErrors()
                switch evaluationResult {
                case let .Success(y):
                    if y.isNormal || y.isZero {
                        plots.append((x: radian, y: y))
                    }
                default: break
                }
            }
        }
        
        return plots
    }
    
    @IBAction func zoomGraph(gesture: UIPinchGestureRecognizer) {
        if gesture.state == .Changed {
            graphingView.scale *= gesture.scale
            
            // save the scale
            saveScaleAndOrigin()
            gesture.scale = 1
        }
    }
    
    @IBAction func moveGraph(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .Ended: fallthrough
        case .Changed:
            let translation = gesture.translationInView(graphingView)

            if graphingView.graphOrigin == nil {
                graphingView.graphOrigin = CGPoint(
                    x: graphingView.center.x + translation.x,
                    y: graphingView.center.y + translation.y)
            } else {
                graphingView.graphOrigin = CGPoint(
                    x: graphingView.graphOrigin!.x + translation.x,
                    y: graphingView.graphOrigin!.y + translation.y)
            }
            
            // save the graphOrigin
            saveScaleAndOrigin()
            
            // set back to zero, otherwise will be cumulative
            gesture.setTranslation(CGPointZero, inView: graphingView)
        default: break
        }
    }
    
    @IBAction func moveOrigin(gesture: UITapGestureRecognizer) {
        switch gesture.state {
        case .Ended:
            graphingView.graphOrigin = gesture.locationInView(view)
            
            // save the graphOrigin
            saveScaleAndOrigin()
        default: break
        }
    }
    
    private func saveScaleAndOrigin() {
        userDefaults.setObject(graphingView.scaleAndOrigin, forKey: Constants.ScaleAndOrigin)
        userDefaults.synchronize()
    }
    
    // Detect device rotation and adjust origin to center instead of upper-left:
    // if graph origin is far off center, then rotation change might move it off-screen so
    // calcualtion also makes a subtle adjustment based on the ratio of the height and with change
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        var xDistanceFromCenter: CGFloat
        var yDistanceFromCenter: CGFloat
        if let graphOrigin = graphingView.graphOrigin {
            xDistanceFromCenter = graphingView.center.x - graphOrigin.x
            yDistanceFromCenter = graphingView.center.y - graphOrigin.y
        } else {
            xDistanceFromCenter = graphingView.center.x
            yDistanceFromCenter = graphingView.center.y
        }
        
        let widthBeforeRotation = graphingView.bounds.width
        let heightBeforeRotation = graphingView.bounds.height
        
        coordinator.animateAlongsideTransition(nil) { context in
            
            let widthAfterRotation = self.graphingView.bounds.width
            let heightAfterRotation = self.graphingView.bounds.height
            
            let widthChangeRatio = widthAfterRotation / widthBeforeRotation
            let heightChangeRatio = heightAfterRotation / heightBeforeRotation

            self.graphingView.graphOrigin = CGPoint(
                x: self.graphingView.center.x - (xDistanceFromCenter * widthChangeRatio),
                y: self.graphingView.center.y - (yDistanceFromCenter * heightChangeRatio)
            )
        }
    }
    
}
