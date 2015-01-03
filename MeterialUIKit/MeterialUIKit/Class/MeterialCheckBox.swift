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
let AnimationDurationConstant = 0.18;
let TapCircleGrowthDurationConstant = AnimationDurationConstant*2;
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
        if frame == CGRectZero {
            defaultFrame.size = CGSizeMake(CheckboxDefaultRadius*2, CheckboxDefaultRadius*2);
        }
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
        
        self.addTarget(self, action: "onCheckBoxTouchDown:", forControlEvents: UIControlEvents.TouchDown);
        self.addTarget(self, action: "onCheckBoxTouchUpAndSwitchStates:", forControlEvents: UIControlEvents.TouchUpInside);
        self.addTarget(self, action: "onCheckBoxTouchUp:", forControlEvents: UIControlEvents.TouchUpOutside);
        self.addTarget(self, action: "onCheckBoxTouchUp:", forControlEvents: UIControlEvents.TouchCancel);
        
        var tapGuesture = UITapGestureRecognizer(target: self, action: nil);
        tapGuesture.delegate = self;
        self.gestureRecognizers = [tapGuesture];
        
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
    
    
    // MARK: Animation
    private func growTapCircle() {
        // Spawn a growing circle that "ripples" through the button:
        var tapCircleDiameterEndValue = self.rippleFromTapLocation ? self.radius*4 : self.radius*2;// if the circle comes from the center, its the perfect size. otherwise it will be quite small.
        var tapCircleFinalDiameter = self.rippleFromTapLocation ? self.radius*4 : self.radius*2;// if the circle comes from the center, its the perfect size. otherwise it will be quite small.
        
        // Create a UIView which we can modify for its frame value later (specifically, the ability to use .center):
        var tapCircleLayerSizerView = UIView(frame: CGRectMake(0, 0, tapCircleFinalDiameter, tapCircleFinalDiameter));
        tapCircleLayerSizerView.center = self.rippleFromTapLocation ? self.tapPoint : CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
        
        // Calculate starting path:
        var startingRectSizerView = UIView(frame: CGRectMake(0, 0, TapCircleDiameterStartValue, TapCircleDiameterStartValue));
        startingRectSizerView.center = tapCircleLayerSizerView.center;
        
        // Create starting circle path:
        var startingCirclePath = UIBezierPath(roundedRect: startingRectSizerView.frame, cornerRadius: TapCircleDiameterStartValue/2);
        
        // Calculate ending path:
        var endingRectSizerView = UIView(frame: CGRectMake(0, 0, tapCircleDiameterEndValue, tapCircleDiameterEndValue));
        endingRectSizerView.center = tapCircleLayerSizerView.center;
        
        // Cretae ending circle path:
        var endingCirclePath = UIBezierPath(roundedRect: endingRectSizerView.frame, cornerRadius: tapCircleDiameterEndValue/2);
        
        // Create tap circle:
        var tapCicle = CAShapeLayer();
        tapCicle.strokeColor = UIColor.clearColor().CGColor;
        tapCicle.borderColor = UIColor.clearColor().CGColor;
        tapCicle.borderWidth = 0;
        tapCicle.path = startingCirclePath.CGPath;
        // Set tap circle layer's background color:
        if self.isChecked {
            // It is currently checked, so we are unchecking it:
            if let negativeColor = self.tapCircleNegativeColor {
                tapCicle.fillColor = negativeColor.CGColor;
            }else {
                tapCicle.fillColor = UIColor.colorWith(0x616161).CGColor;
            }
        }else {
            // It is currently unchecked, so we are checking it:
            if let positiveColor = self.tapCirclePositiveColor {
                tapCicle.fillColor = positiveColor.CGColor;
            }else {
                tapCicle.fillColor = self.checkmarkColor.CGColor;
            }
        }
        // Add tap circle to array and view:
        rippleAnimationQueue.append(tapCicle);
        layer.insertSublayer(tapCicle, atIndex: 0);
        
        /*
        * Animations:
        */
        // Grow tap-circle animation (performed on mask layer):
        UIView.setAnimationDidStopSelector("animationDidStop:finished:");
        var tapCircleGrowthAnimation = CABasicAnimation(keyPath: "path");
        tapCircleGrowthAnimation.delegate = self;
        tapCircleGrowthAnimation.fromValue = startingCirclePath.CGPath;
        tapCircleGrowthAnimation.toValue = endingCirclePath.CGPath;
        tapCircleGrowthAnimation.fillMode = kCAFillModeForwards;
        tapCircleGrowthAnimation.removedOnCompletion = false;
        tapCircleGrowthAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut);
        tapCircleGrowthAnimation.duration = TapCircleGrowthDurationConstant;
        tapCircleGrowthAnimation.setValue("tapGrowth", forKey: "id");
        
        // Fade in self.animationLayer:
        var fadeInAnimation = CABasicAnimation(keyPath: "opacity");
        fadeInAnimation.duration = AnimationDurationConstant;
        fadeInAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear);
        fadeInAnimation.fromValue = 0;
        fadeInAnimation.toValue = 1;
        fadeInAnimation.removedOnCompletion = false;
        fadeInAnimation.fillMode = kCAFillModeForwards;
        
        // Add the animations to the layers:
        tapCicle.addAnimation(tapCircleGrowthAnimation, forKey: "animatePath");
        tapCicle.addAnimation(fadeInAnimation, forKey: "opacityAnimation");
    }
    
    private func fadeTapCircleOut() {
        if rippleAnimationQueue.count > 0 {
            var tempAnimationLayer = self.rippleAnimationQueue.first;
            if tempAnimationLayer != nil {
                self.deathRowForCircleLayers.insert(tempAnimationLayer!, atIndex: 0);
            }
            rippleAnimationQueue.removeAtIndex(0);
            
            var fadeOutAnimation = CABasicAnimation(keyPath: "opacity");
            fadeOutAnimation.setValue("fadeCircleOut", forKey: "id");
            fadeOutAnimation.delegate = self;
            fadeOutAnimation.fromValue = tempAnimationLayer?.opacity;
            fadeOutAnimation.toValue = 0;
            fadeOutAnimation.fillMode = kCAFillModeForwards;
            fadeOutAnimation.duration = AnimationDurationConstant;
            
            tempAnimationLayer?.addAnimation(fadeOutAnimation, forKey: "opacityAnimation");
        }
    }
    
    private func spinCheckbox(animated:Bool, angle1:CGFloat, angle2:CGFloat, radiusDenominator:CGFloat, duration:CGFloat) {
        finishedAnimations = false;
        checkmarkSidesCompletedAnimating = 0;
        
        lineLeft.opacity = 1;
        lineTop.opacity = 1;
        lineRight.opacity = 1;
        lineBottom.opacity = 1;
        
        var ratioDenominator = radiusDenominator*4;
        var radius = CheckboxSideLength/radiusDenominator;
        var ratio = CheckboxSideLength/ratioDenominator;
        var offset = radius - ratio;
        var slightOffsetForCheckmarkCentering = CGPointMake(4, 9);
    }
    
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
            var newPaths = [newLeftPath, newTopPath, newRightPath, newBottomPath];
            var lines = [lineLeft, lineTop, lineRight, lineBottom];
            var vlues = [box_drawLeftLine, box_drawTopLine, box_drawRightLine, box_drawBottomLine];
            var pathAnimationKeys = ["animateLeftLinePath", "animateTopLinePath", "animateRightLinePath", "animateBottomLinePath"];
            var colorAnimationKeys = ["animateLeftLineStrokeColor", "animateTopLineStrokeColor", "animateRightLineStrokeColor", "animateBottomLineStrokeColor"];
            
            for var i = 0;i < 4;i++ {
                var pathAnimation = CABasicAnimation(keyPath: "path");
                pathAnimation.removedOnCompletion = false;
                pathAnimation.duration = AnimationDurationConstant;
                pathAnimation.fromValue = lines[i].path;
                pathAnimation.toValue = newPaths[i];
                pathAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear);
                pathAnimation.setValue(vlues[i], forKey: "id");
                pathAnimation.delegate = self;
                lines[i].addAnimation(pathAnimation, forKey: pathAnimationKeys[i]);
                
                var colorAnimation = CABasicAnimation(keyPath: "strokeColor");
                colorAnimation.removedOnCompletion = false;
                colorAnimation.duration = AnimationDurationConstant;
                colorAnimation.fromValue = lines[i].strokeColor;
                colorAnimation.toValue = tintColor!.CGColor;
                colorAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear);
                lines[i].addAnimation(colorAnimation, forKey: colorAnimationKeys[i]);
            }
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
        growTapCircle();
    }
    
    func onCheckBoxTouchUp(sender: MeterialCheckBox) {
        println("Touch up handler");
        fadeTapCircleOut();
    }
    
    func onCheckBoxTouchUpAndSwitchStates(sender: MeterialCheckBox) {
        println("Touch Up handler with switching states");
        if !finishedAnimations {
            fadeTapCircleOut();
            return;
        }
        _switchStateAnimated(true);
    }
    
    private func _switchStateAnimated(animated:Bool) {
        // Change states:
        isChecked = !isChecked;
        println("self.isCheched:\(isChecked)");
        
        // Notify our delegate that we changed states!
        self.delegate?.checkboxChangedState?(self);
        
        if isChecked {
            // Shrink checkBOX:
        }else {
            // Shrink checkMARK:
        }
        self.fadeTapCircleOut();
    }
    
    override public func animationDidStop(animation:CAAnimation, finished flag:Bool) {
        if (animation.valueForKey("id") as? String) == "fadeCircleOut" {
            if self.deathRowForCircleLayers.count > 0 {
                self.deathRowForCircleLayers[0].removeFromSuperlayer();
                self.deathRowForCircleLayers.removeAtIndex(0);
            }
        }
    }
}
