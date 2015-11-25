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
            if let scaleAndOrigin = NSUserDefaults.standardUserDefaults().objectForKey(Constants.ScaleAndOrigin) as? [String: String] {
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
    
    func graphPlot(sender: GraphingView) -> [(x: Double, y: Double)]? {
        let minXDegree = Double(sender.minX) * (180 / M_PI)
        let maxXDegree = Double(sender.maxX) * (180 / M_PI)
        
        var plots = [(x: Double, y: Double)]()
        let brain = CalculatorBrain()
        
        if let program = program {
            brain.program = program
            
            // Performance fix to remove sluggish behavior (specially when screen is zoomed out):
            // a. the difference between minXDegree and maxXDegree will be high
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
        NSUserDefaults.standardUserDefaults().setObject(graphingView.scaleAndOrigin, forKey: Constants.ScaleAndOrigin)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
}
