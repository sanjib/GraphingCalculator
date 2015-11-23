//
//  GraphingView.swift
//  GraphingCalculator
//
//  Created by Sanjib Ahmad on 11/18/15.
//  Copyright © 2015 Object Coder. All rights reserved.
//

import UIKit

protocol GraphingViewDataSource: class {
    func graphPlot(sender: GraphingView) -> [Double]?
}

@IBDesignable
class GraphingView: UIView {
    weak var dataSource: GraphingViewDataSource?
    
    @IBInspectable var color: UIColor = UIColor.blueColor() { didSet { setNeedsDisplay() } }
    @IBInspectable var scale: CGFloat = 1.0                 { didSet { setNeedsDisplay() } }
    @IBInspectable var graphOrigin: CGPoint?                { didSet { setNeedsDisplay() } }
    
    private let pointsPerUnit: CGFloat = 50.0
    
    var graphCenter: CGPoint {
        if graphOrigin != nil {
            return convertPoint(graphOrigin!, fromView: superview)
        }
        return convertPoint(center, fromView: superview)
    }

    override func drawRect(rect: CGRect) {
        let axes = AxesDrawer(color: color, contentScaleFactor: contentScaleFactor)
        axes.drawAxesInRect(bounds, origin: graphCenter, pointsPerUnit: pointsPerUnit*scale)        
    }

}
