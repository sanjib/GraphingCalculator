//
//  GraphingViewController.swift
//  GraphingCalculator
//
//  Created by Sanjib Ahmad on 11/15/15.
//  Copyright © 2015 Object Coder. All rights reserved.
//

import UIKit

class GraphingViewController: UIViewController, GraphingViewDataSource {
    @IBOutlet weak var graphingView: GraphingView! {
        didSet { graphingView.dataSource = self }
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
        
        for i in Int(minXDegree)...Int(maxXDegree) {
            let radian = Double(i) * (M_PI / 180)
            
            if program != nil {
                brain.program = program!
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
            
            // set back to zero, otherwise will be cumulative
            gesture.setTranslation(CGPointZero, inView: graphingView)
        default: break
        }
    }
    
    @IBAction func moveOrigin(gesture: UITapGestureRecognizer) {
        switch gesture.state {
        case .Ended: graphingView.graphOrigin = gesture.locationInView(view)
        default: break
        }
    }
    
}
