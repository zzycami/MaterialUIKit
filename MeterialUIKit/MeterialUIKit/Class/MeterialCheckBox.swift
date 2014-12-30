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
     optional func checkboxChangedState(checkBox: MeterialCheckBox);
}

/** A nice recommended value for size. (eg. [[BFPaperCheckbox alloc] initWithFrame:CGRectMake(x, y, bfPaperCheckboxDefaultRadius * 2, bfPaperCheckboxDefaultRadius * 2)]; */
public let CheckboxDefaultRadius:CGFloat = 39.0;
// -animation durations:
let AnimationDurationConstant:CGFloat = 0.12;
let TapCircleGrowthDurationConstant:CGFloat = AnimationDurationConstant*2;
// -tap-circle's size:
let TapCircleDiameterStartValue:CGFloat = 1.0;
// -tap-circle's beauty:
let TapFillConstant:CGFloat = 0.3;
// -checkbox's beauty:
let CheckboxSideLength:CGFloat = 9.0;
// -animation function names:
// For spinning box clockwise while shrinking:
let box_spinClockwiseAnimationLeftLine = "leftLineSpin";
let box_spinClockwiseAnimationTopLine = "topLineSpin";
let box_spinClockwiseAnimationRightLine = "rightLineSpin";
let box_spinClockwiseAnimationBottomLine = "bottomLineSpin";
// For spinning box counterclockwise while growing:
let box_spinCounterclockwiseAnimationLeftLine = "leftLineSpin2";
let box_spinCounterclockwiseAnimationTopLine = "topLineSpin2";
let box_spinCounterclockwiseAnimationRightLine = "rightLineSpin2";
let box_spinCounterclockwiseAnimationBottomLine = "bottomLineSpin2";
// For drawing an empty checkbox:
let box_drawLeftLine = "leftLineStroke";
let box_drawTopLine = "topLineStroke";
let box_drawRightLine = "rightLineStroke";
let box_drawBottomLine = "bottomLineStroke";
// For drawing checkmark:
let mark_drawShortLine = "smallCheckmarkLine";
let mark_drawLongLine = "largeCheckmarkLine";
// For removing checkbox:
let box_eraseLeftLine = "leftLineStroke2";
let box_eraseTopLine = "topLineStroke2";
let box_eraseRightLine = "rightLineStroke2";
let box_eraseBottomLine = "bottomLineStroke2";
// removing checkmark:
let mark_eraseShortLine = "smallCheckmarkLine2";
let mark_eraseLongLine = "largeCheckmarkLine2";

@IBDesignable
public class MeterialCheckBox: UIButton, UIGestureRecognizerDelegate {
    // MARK: Default Initializers
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        self.setupWithRadius();
    }
    
    public override init() {
        super.init();
        self.setupWithRadius();
    }
    
    public override init(frame: CGRect) {
        var defaultFrame = frame;
        defaultFrame.size = CGSizeMake(CheckboxDefaultRadius*2, CheckboxDefaultRadius*2);
        super.init(frame: defaultFrame);
        self.setupWithRadius();
    }
    
    // MARK: Custom Initializers
    func setupWithRadius() {
//        println("checkbox frame(\(frame.origin.x), \(frame.origin.y), \(frame.size.width), \(frame.size.height))");
//        println("checkbox bounds(\(bounds.origin.x), \(bounds.origin.y), \(bounds.size.width), \(bounds.size.height))");
        self.tintColor = UIColor.colorWith(0x616161);
        self.layer.masksToBounds = true;
        self.clipsToBounds = true;
        self.layer.shadowOpacity = 0.0;
        self.layer.cornerRadius = self.radius;
        self.backgroundColor = UIColor.clearColor();
        
        for layer in [lineLeft, lineBottom, lineRight, lineTop] {
            layer.fillColor = UIColor.clearColor().CGColor;
            layer.anchorPoint = CGPointZero;
            layer.lineJoin = kCALineJoinRound;
            layer.lineCap = kCALineCapSquare;
            layer.contentsScale = self.layer.contentsScale;
            layer.lineWidth = 2.0;
            layer.strokeColor = self.tintColor!.CGColor;
            
            // initialize with an empty path so we can animate the path w/o having to check for NULLs.
            var dummyPath:CGPathRef = CGPathCreateMutable();
            layer.path = dummyPath;
            
            self.layer.addSublayer(layer);
        }
        
        drawCheckBoxAnimated(false);
        
        self.addTarget(self, action: "onCheckBoxTouchDown:", forControlEvents: UIControlEvents.TouchUpInside);
        self.addTarget(self, action: "onCheckBoxTouchUpAndSwitchStates:", forControlEvents: UIControlEvents.TouchUpInside);
        self.addTarget(self, action: "onCheckBoxTouchUp:", forControlEvents: UIControlEvents.TouchUpOutside);
        self.addTarget(self, action: "onCheckBoxTouchUp:", forControlEvents: UIControlEvents.TouchCancel);
        
        var tapGuesture = UITapGestureRecognizer(target: self, action: nil);
        tapGuesture.delegate = self;
        
        UIView.setAnimationDidStopSelector("animationDidStop:finished:");
    }
    
    // MARK: Gesture Recognizer Delegate
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        var location:CGPoint = touch.locationInView(self);
        println("location: x = \(location.x), y = \(location.y)");
        tapPoint = location;
        return false;// Disallow recognition of tap gestures. We just needed this to grab that tasty tap location.
    }
    
    
    // MARK: Public Interface
    /** A UIColor to use for the checkmark color. Note that self.tintColor will be used for the square box color. */
    @IBInspectable
    public var checkmarkColor:(UIColor) = UIColor.colorWith(0x259b24);
    
    /** A flag to set to YES to have the tap-circle ripple from point of touch. If this is set to NO, the tap-circle will always ripple from the center of the button. Default is YES. */
    @IBInspectable
    public var rippleFromTapLocation:Bool = true;
    
    /** The UIColor to use for the circle which appears where you tap to check the box. NOTE: Setting this defeats the "Smart Color" ability of the tap circle. Alpha values less than 1 are recommended. */
    @IBInspectable
    public var tapCirclePositiveColor:UIColor?
    
    /** The UIColor to use for the circle which appears where you tap to uncheck the box. NOTE: Setting this defeats the "Smart Color" ability of the tap circle. Alpha values less than 1 are recommended. */
    @IBInspectable
    public var tapCircleNegativeColor:UIColor?
    
    /** A BOOL representing the state of the checkbox. YES means checked, NO means unchecked. **/
    @IBInspectable
    public var isChecked:Bool = false;
    
    /** A delegate to use our protocol with! */
    var delegate:MeterialCheckboxDelegate?
    
    
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
    
    
    // MARK: Pirvate Method And Property
    private var centerPoint:CGPoint = CGPointZero;
    private var tapPoint:CGPoint = CGPointZero;
    private var lineLeft:CAShapeLayer = CAShapeLayer(); // Also used for checkmark left, shorter line.
    private var lineTop:CAShapeLayer = CAShapeLayer();
    private var lineRight:CAShapeLayer = CAShapeLayer();
    private var lineBottom:CAShapeLayer = CAShapeLayer(); // Also used for checkmark right, longer line.
    private var rippleAnimationQueue:[CAShapeLayer] = [];
    private var deathRowForCircleLayers:[CAShapeLayer] = [];// This is where old circle layers go to be killed :(
    private var radius:CGFloat = CheckboxDefaultRadius;
    private var checkboxSidesCompletedAnimating:Int = 0; // This should bounce between 0 and 4, representing the number of checkbox sides which have completed animating.
    private var checkmarkSidesCompletedAnimating:Int = 0; // This should bounce between 0 and 2, representing the number of checkmark sides which have completed animating.
    private var finishedAnimations:Bool = true;
    
    private func drawCheckBoxAnimated(animated:Bool) {
        lineLeft.opacity = 1;
        lineTop.opacity = 1;
        lineRight.opacity = 1;
        lineBottom.opacity = 1;
        
        var newLeftPath:CGPathRef = createCenteredLineWithRadius(CheckboxSideLength, angle: M_PI_2, offset: CGPointMake(-CheckboxSideLength, 0));
        var newTopPath:CGPathRef = createCenteredLineWithRadius(CheckboxSideLength, angle: 0, offset: CGPointMake(0, -CheckboxSideLength));
        var newRightPath:CGPathRef = createCenteredLineWithRadius(CheckboxSideLength, angle: M_PI_2, offset: CGPointMake(CheckboxSideLength, 0));
        var newBottomPath:CGPathRef = createCenteredLineWithRadius(CheckboxSideLength, angle: 0, offset: CGPointMake(0, CheckboxSideLength));
        
        if animated {
        }
        
        lineLeft.path = newLeftPath;
        lineTop.path = newTopPath;
        lineRight.path = newRightPath;
        lineBottom.path = newBottomPath;
        
        lineLeft.strokeColor = tintColor!.CGColor;
        lineTop.strokeColor = tintColor!.CGColor;
        lineRight.strokeColor = tintColor!.CGColor;
        lineBottom.strokeColor = tintColor!.CGColor;
    }
    
    public override func prepareForInterfaceBuilder() {
    }
    
    func createCenteredLineWithRadius(radius:CGFloat, angle:Double, offset:CGPoint)->CGPathRef {
        centerPoint = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
        var path = CGPathCreateMutable();
        
        var c = CGFloat(cos(angle));
        var s = CGFloat(sin(angle));
        
        CGPathMoveToPoint(path, nil,
            centerPoint.x + offset.x + radius*c,
            centerPoint.y + offset.y + radius*s);
        CGPathAddLineToPoint(path, nil,
            centerPoint.x + offset.x - radius*c,
            centerPoint.y + offset.y - radius*s);
        return path;
    }
    
    func onCheckBoxTouchDown(sender: MeterialCheckBox) {
        println("Touch down handler");
    }
    
    func onCheckBoxTouchUp(sender: MeterialCheckBox) {
        println("Touch up handler");
    }
    
    func onCheckBoxTouchUpAndSwitchStates(sender: MeterialCheckBox) {
        println("Touch Up handler with switching states");
    }
    
    override public func animationDidStop(animation:CAAnimation, finished flag:Bool) {
    }
}
