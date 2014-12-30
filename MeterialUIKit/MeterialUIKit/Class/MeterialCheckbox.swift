//
//  MeterialCheckbox.swift
//  MeterialUIKit
//
//  Created by damingdan on 14/12/30.
//  Copyright (c) 2014年 com.metalmind. All rights reserved.
//

import UIKit

extension UIColor {
    class func colorWith(value:Int)->UIColor {
        var redValue = CGFloat(value & 0xFF0000 >> 16)/255.0;
        var greenValue = CGFloat(value & 0x00FF00 >> 8)/255.0;
        var blueValue = CGFloat(value & 0x0000FF)/255.0;
        return UIColor(red: redValue, green: greenValue, blue: blueValue, alpha: 1);
    }
}

@objc public protocol MeterialCheckboxDelegate: NSObjectProtocol {
    /** An optional protocol method for detecting when the checkbox state changed. You can check its current state here with 'checkbox.isChecked'. */
     optional func checkboxChangedState(checkBox: MeterialCheckbox);
}

public class MeterialCheckbox: UIButton, UIGestureRecognizerDelegate {

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /** A UIColor to use for the checkmark color. Note that self.tintColor will be used for the square box color. */
    public var checkmarkColor:(UIColor) = UIColor.colorWith(0x259b24);
    
    /** A flag to set to YES to have the tap-circle ripple from point of touch. If this is set to NO, the tap-circle will always ripple from the center of the button. Default is YES. */
    public var rippleFromTapLocation:Bool = true;
    
    /** The UIColor to use for the circle which appears where you tap to check the box. NOTE: Setting this defeats the "Smart Color" ability of the tap circle. Alpha values less than 1 are recommended. */
    public var tapCirclePositiveColor:UIColor?
    
    /** The UIColor to use for the circle which appears where you tap to uncheck the box. NOTE: Setting this defeats the "Smart Color" ability of the tap circle. Alpha values less than 1 are recommended. */
    public var tapCircleNegativeColor:UIColor?
    
    /** A BOOL representing the state of the checkbox. YES means checked, NO means unchecked. **/
    public var isChecked = false;
    
    /** A delegate to use our protocol with! */
    var delegate:MeterialCheckboxDelegate?
    
    /** A nice recommended value for size. (eg. [[BFPaperCheckbox alloc] initWithFrame:CGRectMake(x, y, bfPaperCheckboxDefaultRadius * 2, bfPaperCheckboxDefaultRadius * 2)]; */
    public let CheckboxDefaultRadius:CGFloat = 39.0;
    
    /**
    *  Use this function to manually/programmatically switch the state of this checkbox.
    *
    *  @param animated A BOOL flag to choose whether or not to animate the change.
    */
    public func switchStatesAnimated(animated:Bool) {
        
    }
    
    /**
    *  Use this function to manually check the checkbox. Does nothing if already checked.
    *
    *  @param animated A BOOL flag to choose whether or not to animate the change.
    */
    public func checkAnimated(animated:Bool) {
    }
    
    /**
    *  Use this function to manually uncheck the checkbox. Does nothing if already unchecked.
    *
    *  @param animated A BOOL flag to choose whether or not to animate the change.
    */
    public func uncheckAnimated(animated:Bool) {
    }
    
    
    private var centerPoint:CGPoint = CGPointZero;
    private var tapPoint:CGPoint = CGPointZero;
    private var lineLeft:CAShapeLayer; // Also used for checkmark left, shorter line.
    private var lineTop:CAShapeLayer;
    private var lineRight:CAShapeLayer;
    private var lineBottom:CAShapeLayer; // Also used for checkmark right, longer line.
    private var rippleAnimationQueue:[CAShapeLayer] = [];
    private var deathRowForCircleLayers:[CAShapeLayer] = [];// This is where old circle layers go to be killed :(
    private var radius:CGFloat = 0;
    private var checkboxSidesCompletedAnimating:Int = 0; // This should bounce between 0 and 4, representing the number of checkbox sides which have completed animating.
    private var checkmarkSidesCompletedAnimating:Int = 0; // This should bounce between 0 and 2, representing the number of checkmark sides which have completed animating.
    private var finishedAnimations:Bool;
    // -animation durations:
    let AnimationDurationConstant:CGFloat = 0.12;
    let TapCircleGrowthDurationConstant:CGFloat = 0.12*2;
    // -tap-circle's size:
    let TapCircleDiameterStartValue:CGFloat = 1.0;
    // -tap-circle's beauty:
    let TapFillConstant:CGFloat = 0.3;
    // -checkbox's beauty:
    let CheckboxSideLength:CGFloat = 9.0;
    
    // -animation function names:
    // For spinning box clockwise while shrinking:
    
}
