//
//  GraphingViewController.swift
//  GraphingCalculator
//
//  Created by Sanjib Ahmad on 11/15/15.
//  Copyright © 2015 Object Coder. All rights reserved.
//

import UIKit

class GraphingViewController: UIViewController, GraphingViewDataSource {
    @IBOutlet weak var graphingView: GraphingView!
    
    var program: AnyObject? {
        didSet {
            print(program)
        }
    }
    
    var graphLabel: String? {
        didSet {
            print(graphLabel)
        }
    }
    
    func graphPlot(sender: GraphingView) -> [Double]? {
        
        return nil
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
