//
//  CalculatorViewController.swift
//  Calculator
//
//  Created by Sanjib Ahmad on 10/24/15.
//  Copyright © 2015 Object Coder. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var history: UILabel!
    
    private struct DefaultDisplayResult {
        static let Startup: Double = 0
        static let Error = "Error!"
    }
    
    private var userIsInTheMiddleOfTypingANumber = false
    private let defaultHistoryText = " "
    
    private var brain = CalculatorBrain()

    @IBAction func clear() {
        brain.clearStack()
        brain.variableValues.removeAll()
        displayResult = CalculatorBrainEvaluationResult.Success(DefaultDisplayResult.Startup)
        history.text = defaultHistoryText
    }
    
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTypingANumber {
            if digit != "." || display.text!.rangeOfString(".") == nil {
                display.text = display.text! + digit
            }
        } else {
            display.text = digit
            userIsInTheMiddleOfTypingANumber = true
        }
    }

    @IBAction func undo() {
        if userIsInTheMiddleOfTypingANumber == true {
            if display.text!.characters.count > 1 {
                display.text = String(display.text!.characters.dropLast())
            } else {
                displayResult = CalculatorBrainEvaluationResult.Success(DefaultDisplayResult.Startup)
            }
        } else {
            brain.removeLastOpFromStack()
            displayResult = brain.evaluateAndReportErrors()
        }
    }
    
    @IBAction func changeSign() {
        if userIsInTheMiddleOfTypingANumber {
            if displayValue != nil {
                displayResult = CalculatorBrainEvaluationResult.Success(displayValue! * -1)
                
                // set userIsInTheMiddleOfTypingANumber back to true as displayResult will set it to false
                userIsInTheMiddleOfTypingANumber = true
            }
        } else {
            displayResult = brain.performOperation("ᐩ/-")
        }
    }
    
    @IBAction func pi() {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        displayResult = brain.pushConstant("π")
    }
    
    @IBAction func setM() {
        userIsInTheMiddleOfTypingANumber = false
        if displayValue != nil {
            brain.variableValues["M"] = displayValue!
        }
        displayResult = brain.evaluateAndReportErrors()
    }
    
    @IBAction func getM() {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        displayResult = brain.pushOperand("M")
    }    
    
    @IBAction func operate(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        if let operation = sender.currentTitle {
            displayResult = brain.performOperation(operation)
        }
    }
    
    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumber = false
        if displayValue != nil {
            displayResult = brain.pushOperand(displayValue!)
        }
    }
    
    private var displayValue: Double? {
        if let displayValue = NSNumberFormatter().numberFromString(display.text!) {
            return displayValue.doubleValue
        }
        return nil
    }
    
    private var displayResult: CalculatorBrainEvaluationResult? {
        get {
            if let displayValue = displayValue {
                return .Success(displayValue)
            }
            if display.text != nil {
                return .Failure(display.text!)
            }
            return .Failure("Error")
        }
        set {
            if newValue != nil {
                switch newValue! {
                case let .Success(displayValue):
                    display.text = "\(displayValue)"
                case let .Failure(error):
                    display.text = error
                }
            } else {
                display.text = DefaultDisplayResult.Error
            }
            userIsInTheMiddleOfTypingANumber = false
            
            if !brain.description.isEmpty {
                history.text = " \(brain.description.joinWithSeparator(", ")) ="
            } else {
                history.text = defaultHistoryText
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var destination: UIViewController? = segue.destinationViewController
        if let navCon = destination as? UINavigationController {
            destination = navCon.visibleViewController
        }
        if let gvc = destination as? GraphingViewController {
            gvc.program = brain.program
            if let graphLabel = brain.description.last {
                gvc.graphLabel = graphLabel
            }
        }
    }

}

