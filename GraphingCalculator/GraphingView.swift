//
//  GraphingView.swift
//  GraphingCalculator
//
//  Created by Sanjib Ahmad on 11/18/15.
//  Copyright © 2015 Object Coder. All rights reserved.
//

import UIKit

class GraphingView: UIView {

    private var graphCenter: CGPoint {
        return convertPoint(center, fromView: superview)
    }
    
    

    override func drawRect(rect: CGRect) {
        let axes = AxesDrawer(color: UIColor.blueColor())
//        let axes = AxesDrawer(color: UIColor.redColor(), contentScaleFactor: 1)
        axes.drawAxesInRect(bounds, origin: graphCenter, pointsPerUnit: 5)
        
    }

}
