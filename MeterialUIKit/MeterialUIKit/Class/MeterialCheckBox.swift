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
private let AnimationDurationConstant = 0.18;
private let TapCircleGrowthDurationConstant = AnimationDurationConstant*2;
// -tap-circle's size:
private let TapCircleDiameterStartValue:CGFloat = 1.0;
// -tap-circle's beauty:
private let TapFillConstant:CGFloat = 0.3;
// -checkbox's beauty:
private let CheckboxSideLength:CGFloat = 9.0;
// -animation function names:
// For spinning box clockwise while shrinking:
private let box_spinClockwiseAnimationLeftLine = "leftLineSpin";
private let box_spinClockwiseAnimationTopLine = "topLineSpin";
private let box_spinClockwiseAnimationRightLine = "rightLineSpin";
private let box_spinClockwiseAnimationBottomLine = "bottomLineSpin";
// For spinning box counterclockwise while growing:
private let box_spinCounterclockwiseAnimationLeftLine = "leftLineSpin2";
private let box_spinCounterclockwiseAnimationTopLine = "topLineSpin2";
private let box_spinCounterclockwiseAnimationRightLine = "rightLineSpin2";
private let box_spinCounterclockwiseAnimationBottomLine = "bottomLineSpin2";
// For drawing an empty checkbox:
private let box_drawLeftLine = "leftLineStroke";
private let box_drawTopLine = "topLineStroke";
private let box_drawRightLine = "rightLineStroke";
private let box_drawBottomLine = "bottomLineStroke";
// For drawing checkmark:
private let mark_drawShortLine = "smallCheckmarkLine";
private let mark_drawLongLine = "largeCheckmarkLine";
// For removing checkbox:
private let box_eraseLeftLine = "leftLineStroke2";
private let box_eraseTopLine = "topLineStroke2";
private let box_eraseRightLine = "rightLineStroke2";
private let box_eraseBottomLine = "bottomLineStroke2";
// removing checkmark:
private let mark_eraseShortLine = "smallCheckmarkLine2";
private let mark_eraseLongLine = "largeCheckmarkLine2";

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
//        if frame == CGRectZero {
//            defaultFrame.size = CGSizeMake(CheckboxDefaultRadius*2, CheckboxDefaultRadius*2);
//        }
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
        
        //isChecked ? drawCheckmark(false) : drawCheckBoxAnimated(false);
        
        self.addTarget(self, action: "onCheckBoxTouchDown:", forControlEvents: UIControlEvents.TouchDown);
        self.addTarget(self, action: "onCheckBoxTouchUpAndSwitchStates:", forControlEvents: UIControlEvents.TouchUpInside);
        self.addTarget(self, action: "onCheckBoxTouchUp:", forControlEvents: UIControlEvents.TouchUpOutside);
        self.addTarget(self, action: "onCheckBoxTouchUp:", forControlEvents: UIControlEvents.TouchCancel);
        
        var tapGuesture = UITapGestureRecognizer(target: self, action: nil);
        tapGuesture.delegate = self;
        self.gestureRecognizers = [tapGuesture];
        
        UIView.setAnimationDidStopSelector("animationDidStop:finished:");
    }
    
    private var initializing:Bool = true;
    
    public override func layoutSubviews() {
        // The attirbutes of the view is not initialize in the init function, in layoutSubviews, all the attributes have been initialized. so , we can do some thing here.
        println("layoutSubviews:\(isChecked), finishedAnimations:\(finishedAnimations)");
        var frame = self.frame;
        println("frame :\(frame)");
        
        if initializing {
            isChecked ? drawCheckmark(false) : drawCheckBoxAnimated(false);
            initializing = false;
        }
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
        // As long as this comment remains, Animating the change will take the regular path, statically changing the state will take a second path. I would like to combine the two but right now this is faster and easier.
        if animated {
            _switchStateAnimated(animated);
        }else {
            isChecked ? uncheckAnimated(animated) : checkAnimated(animated);
        }
    }
    
    /**
    *  Use this function to manually check the checkbox. Does nothing if already checked.
    *
    *  @param animated A BOOL flag to choose whether or not to animate the change.
    */
    public func checkAnimated(animated:Bool) {
        if isChecked {
            return;
        }
        isChecked = true;
        self.delegate?.checkboxChangedState?(self);
        if animated {
            self.spinCheckbox(animated, angle1: M_PI_4, angle2: -5*M_PI_4, radiusDenominator: 4, duration: AnimationDurationConstant);
        }else {
            self.drawCheckmark(animated);
        }
    }
    
    /**
    *  Use this function to manually uncheck the checkbox. Does nothing if already unchecked.
    *
    *  @param animated A BOOL flag to choose whether or not to animate the change.
    */
    public func uncheckAnimated(animated:Bool) {
        if !isChecked {
            return;
        }
        isChecked = false;
        self.delegate?.checkboxChangedState?(self);
        if animated {
            self.shrinkAwayCheckmark(animated);
        }else {
            self.drawCheckmark(animated);
        }
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
        //UIView.setAnimationDidStopSelector("animationDidStop:finished:");
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
        fadeInAnimation.fromValue = 0.0;
        fadeInAnimation.toValue = 1.0;
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
            fadeOutAnimation.removedOnCompletion = false;
            
            tempAnimationLayer?.addAnimation(fadeOutAnimation, forKey: "opacityAnimation");
        }
    }
    
    private func spinCheckbox(animated:Bool, angle1:Double, angle2:Double, radiusDenominator:CGFloat, duration:Double) {
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
        var slightOffsetForCheckmarkCentering = CGPointMake(4, 9);// Hardcoded in the most offensive way. Forgive me Father, for I have sinned.
        
        var newLeftPath = self.createCenteredLineWithRadius(radius, angle: angle2, offset: CGPointMake(-offset - slightOffsetForCheckmarkCentering.x, -offset + slightOffsetForCheckmarkCentering.y));
        var newTopPath = self.createCenteredLineWithRadius(radius, angle: angle1, offset: CGPointMake(offset - slightOffsetForCheckmarkCentering.x, -offset + slightOffsetForCheckmarkCentering.y));
        var newRightPath = self.createCenteredLineWithRadius(radius, angle: angle2, offset: CGPointMake(offset - slightOffsetForCheckmarkCentering.x, offset + slightOffsetForCheckmarkCentering.y));
        var newBottomPath = self.createCenteredLineWithRadius(radius, angle: angle1, offset: CGPointMake(-offset - slightOffsetForCheckmarkCentering.x, offset + slightOffsetForCheckmarkCentering.y));
        
        if animated {
            var newPaths = [newLeftPath, newTopPath, newRightPath, newBottomPath];
            var lines = [lineLeft, lineTop, lineRight, lineBottom];
            var animationkeys = ["spinLeftLine", "spinTopLine", "spinRightLine", "spinBottomLine"];
            var counterValues = [box_spinCounterclockwiseAnimationLeftLine, box_spinCounterclockwiseAnimationTopLine, box_spinCounterclockwiseAnimationRightLine, box_spinCounterclockwiseAnimationBottomLine];
            var values = [box_spinClockwiseAnimationLeftLine, box_spinClockwiseAnimationTopLine, box_spinClockwiseAnimationRightLine, box_spinClockwiseAnimationBottomLine];
            for i in 0...3 {
                var lineAnimation = CABasicAnimation(keyPath: "path");
                lineAnimation.removedOnCompletion = false;
                lineAnimation.duration = duration;
                lineAnimation.fromValue = lines[i].path;
                lineAnimation.toValue = newPaths[i];
                lineAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear);
                lineAnimation.delegate = self;
                lineAnimation.setValue(self.isChecked ?values[i]:counterValues[i], forKey: "id");
                lines[i].addAnimation(lineAnimation, forKey: animationkeys[i]);
            }
        }
        
        self.lineLeft.path = newLeftPath;
        self.lineTop.path = newTopPath;
        self.lineRight.path = newRightPath;
        self.lineBottom.path = newBottomPath;
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
    
    private func drawCheckmark(animated:Bool) {
        self.lineTop.opacity = 0;
        self.lineLeft.opacity = 0;
        
        var checkmarkSmallSideLength = CheckboxSideLength * 0.6;
        var checkmarkLargeSideLength = CheckboxSideLength * 1.3;
        
        var smallSideOffset = CGPointMake(-9, 5);       // Hardcoded in the most offensive way.
        var largeSideOffset = CGPointMake(3.5, 0.5);    // Hardcoded in the most offensive way. Forgive me father, for I have sinned!
        
        // Right path will become the large part of the checkmark:
        var newRightPath = self.createCenteredLineWithRadius(checkmarkLargeSideLength, angle: -5 * M_PI_4, offset: largeSideOffset);
        
        // Bottom path will become the small part of the checkmark:
        var newBottomPath = self.createCenteredLineWithRadius(checkmarkSmallSideLength, angle: M_PI_4, offset: smallSideOffset);
        
        if animated {
            var lineRightAnimation = CABasicAnimation(keyPath: "path");
            lineRightAnimation.removedOnCompletion = false;
            lineRightAnimation.duration = AnimationDurationConstant;
            lineRightAnimation.fromValue = lineRight.path;
            lineRightAnimation.toValue = newRightPath;
            lineRightAnimation.setValue(mark_drawLongLine, forKey: "id");
            lineRightAnimation.delegate = self;
            lineRightAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear);
            lineRight.addAnimation(lineRightAnimation, forKey: "animateRightLinePath");
            
            var lineBottomAnimation = CABasicAnimation(keyPath: "path");
            lineBottomAnimation.removedOnCompletion = false;
            lineBottomAnimation.duration = AnimationDurationConstant;
            lineBottomAnimation.fromValue = lineBottom.path;
            lineBottomAnimation.toValue = newBottomPath;
            lineBottomAnimation.setValue(mark_drawShortLine, forKey: "id");
            lineBottomAnimation.delegate = self;
            lineBottomAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear);
            lineBottom.addAnimation(lineBottomAnimation, forKey: "animateBottomLinePath");
        }else {
            lineRight.strokeColor = checkmarkColor.CGColor;
            lineLeft.strokeColor = checkmarkColor.CGColor;
        }
        
        lineRight.path = newRightPath;
        lineBottom.path = newBottomPath;
    }
    
    private func shrinkAwayCheckmark(animated:Bool) {
        finishedAnimations = false;
        checkmarkSidesCompletedAnimating = 0;
        
        var radiusDenominator:CGFloat = 18;
        var ratioDenominator = radiusDenominator * 4;
        var radius = CheckboxSideLength/radiusDenominator;
        var ratio = CheckboxSideLength/ratioDenominator;
        var offset = radius - ratio;
        var slightOffsetForCheckmarkCentering = CGPointMake(3, 11);// Hardcoded in the most offensive way. Forgive me Father, for I have sinned.
        
        var newRightPath:CGPathRef = createCenteredLineWithRadius(radius, angle: -5 * M_PI_4, offset: CGPointMake(offset - slightOffsetForCheckmarkCentering.x, offset + slightOffsetForCheckmarkCentering.y));
        var newBottomPath:CGPathRef = createCenteredLineWithRadius(radius, angle: M_PI_4, offset: CGPointMake(-offset - slightOffsetForCheckmarkCentering.x, offset + slightOffsetForCheckmarkCentering.y));
        
        if animated {
            var newPaths = [newRightPath, newBottomPath];
            var lines = [lineRight, lineBottom];
            var values = [mark_eraseLongLine, mark_eraseShortLine];
            var pathAnimationKeys = ["animateRightLinePath", "animateBottomLinePath"];
            var colorAnimationKeys = ["animateRightLineStrokeColor", "animateBottomLineStrokeColor"];
            
            for i in 0...1 {
                var pathAnimation = CABasicAnimation(keyPath: "path");
                pathAnimation.removedOnCompletion = false;
                pathAnimation.duration = AnimationDurationConstant;
                pathAnimation.fromValue = lines[i].path;
                pathAnimation.toValue = newPaths[i];
                pathAnimation.setValue(values[i], forKey: "id");
                pathAnimation.delegate = self;
                pathAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear);
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

        lineRight.path = newRightPath;
        lineBottom.path = newBottomPath;
        
        lineLeft.strokeColor = tintColor!.CGColor;
        lineTop.strokeColor = tintColor!.CGColor;
        lineRight.strokeColor = tintColor!.CGColor;
        lineBottom.strokeColor = tintColor!.CGColor;
    }
    
    // This fucntion only modyfies the checkbox. When it's animation is complete, it calls a function to draw the checkmark.
    private func shrinkAwayCheckboxAnimated(animated:Bool) {
        lineLeft.opacity = 1;
        lineTop.opacity = 1;
        lineRight.opacity = 1;
        lineBottom.opacity = 1;
        
        var radiusDenominator:CGFloat = 20;
        var ratioDenominator = radiusDenominator * 4;
        var radius = CheckboxSideLength/radiusDenominator;
        var ratio = CheckboxSideLength/ratioDenominator;
        var offset = radius - ratio;
        var slightOffsetForCheckmarkCentering = CGPointMake(4, 9);// Hardcoded in the most offensive way. Forgive me Father, for I have sinned.
        var duration = AnimationDurationConstant/4;
        
        var newLeftPath:CGPathRef = createCenteredLineWithRadius(radius, angle: -5 * M_PI_4, offset: CGPointMake(-offset - slightOffsetForCheckmarkCentering.x, -offset + slightOffsetForCheckmarkCentering.y));
        var newTopPath:CGPathRef = createCenteredLineWithRadius(radius, angle: M_PI_4, offset: CGPointMake(offset - slightOffsetForCheckmarkCentering.x, -offset + slightOffsetForCheckmarkCentering.y));
        var newRightPath:CGPathRef = createCenteredLineWithRadius(radius, angle: -5 * M_PI_4, offset: CGPointMake(offset - slightOffsetForCheckmarkCentering.x, offset + slightOffsetForCheckmarkCentering.y));
        var newBottomPath:CGPathRef = createCenteredLineWithRadius(radius, angle: M_PI_4, offset: CGPointMake(-offset - slightOffsetForCheckmarkCentering.x, offset + slightOffsetForCheckmarkCentering.y));
        
        if animated {
            var newPaths = [newLeftPath, newTopPath, newRightPath, newBottomPath];
            var lines = [lineLeft, lineTop, lineRight, lineBottom];
            var values = [box_eraseLeftLine, box_eraseTopLine, box_eraseRightLine, box_eraseBottomLine];
            var pathAnimationKeys = ["animateLeftLinePath", "animateTopLinePath", "animateRightLinePath", "animateBottomLinePath"];
            var colorAnimationKeys = ["animateLeftLineStrokeColor", "animateTopLineStrokeColor", "animateRightLineStrokeColor", "animateBottomLineStrokeColor"];
            
            for i in 0...3 {
                var pathAnimation = CABasicAnimation(keyPath: "path");
                pathAnimation.removedOnCompletion = false;
                pathAnimation.duration = duration;
                pathAnimation.fromValue = lines[i].path;
                pathAnimation.toValue = newPaths[i];
                pathAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear);
                lines[i].addAnimation(pathAnimation, forKey: pathAnimationKeys[i]);
                
                var colorAnimation = CABasicAnimation(keyPath: "strokeColor");
                colorAnimation.removedOnCompletion = false;
                colorAnimation.duration = duration;
                colorAnimation.fromValue = lines[i].strokeColor;
                colorAnimation.toValue = tintColor!.CGColor;
                colorAnimation.setValue(values[i], forKey: "id");
                colorAnimation.delegate = self;
                colorAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear);
                lines[i].addAnimation(colorAnimation, forKey: colorAnimationKeys[i]);
            }
        }
        
        lineLeft.path = newLeftPath;
        lineTop.path = newTopPath;
        lineRight.path = newRightPath;
        lineBottom.path = newBottomPath;
        
        lineLeft.strokeColor = checkmarkColor.CGColor;
        lineTop.strokeColor = checkmarkColor.CGColor;
        lineRight.strokeColor = checkmarkColor.CGColor;
        lineBottom.strokeColor = checkmarkColor.CGColor;
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
            self.spinCheckbox(true, angle1: M_PI_4, angle2: -5*M_PI_4, radiusDenominator: 4, duration: AnimationDurationConstant);
        }else {
            // Shrink checkMARK:
            self.shrinkAwayCheckmark(true);
        }
        self.fadeTapCircleOut();
    }
    
    override public func animationDidStop(animation:CAAnimation, finished flag:Bool) {
        var key = animation.valueForKey("id") as? String;
        //println("key:\(key)");
        if (key == "fadeCircleOut") {
            if self.deathRowForCircleLayers.count > 0 {
                self.deathRowForCircleLayers[0].removeFromSuperlayer();
                self.deathRowForCircleLayers.removeAtIndex(0);
            }
        }else if(key == box_drawLeftLine ||
            key == box_drawTopLine ||
            key == box_drawRightLine ||
            key == box_drawBottomLine) {
            self.checkboxSidesCompletedAnimating++ ;
            if self.checkboxSidesCompletedAnimating >= 4 {
                self.checkboxSidesCompletedAnimating = 0;
                self.finishedAnimations = true;
                println("FINISHED drawing BOX");
            }
        }else if(key == box_spinClockwiseAnimationLeftLine ||
            key == box_spinClockwiseAnimationTopLine ||
            key == box_spinClockwiseAnimationRightLine ||
            key == box_spinClockwiseAnimationBottomLine) {
            self.checkboxSidesCompletedAnimating++ ;
            if self.checkboxSidesCompletedAnimating >= 4 {
                self.checkboxSidesCompletedAnimating = 0;
                self.shrinkAwayCheckboxAnimated(true);
                println("FINISHED spinning box CCW");
            }
        }else if(key == box_spinCounterclockwiseAnimationLeftLine ||
            key == box_spinCounterclockwiseAnimationTopLine ||
            key == box_spinCounterclockwiseAnimationRightLine ||
            key == box_spinCounterclockwiseAnimationBottomLine) {
                self.checkboxSidesCompletedAnimating++ ;
                if self.checkboxSidesCompletedAnimating >= 4 {
                    self.checkboxSidesCompletedAnimating = 0;
                    self.finishedAnimations = true;
                    self.drawCheckBoxAnimated(true);
                    println("FINISHED spinning box CCW");
                }
        }else if(key == mark_drawShortLine ||
                key == mark_drawLongLine) {
                self.checkmarkSidesCompletedAnimating++ ;
                if self.checkmarkSidesCompletedAnimating >= 2 {
                    self.checkmarkSidesCompletedAnimating = 0;
                    self.finishedAnimations = true;
                    println("FINISHED drawing checkmark");
                }
        }else if(key == mark_eraseShortLine ||
            key == mark_eraseLongLine) {
                self.checkmarkSidesCompletedAnimating++ ;
                if self.checkmarkSidesCompletedAnimating >= 2 {
                    self.checkmarkSidesCompletedAnimating = 0;
                    self.spinCheckbox(true, angle1: M_PI_4, angle2: -5*M_PI_4, radiusDenominator: 4, duration: AnimationDurationConstant/2);
                    println("FINISHED shrinking checkmark");
                }
        }else if(key == box_eraseLeftLine ||
            key == box_eraseTopLine ||
            key == box_eraseRightLine ||
            key == box_eraseBottomLine) {
                self.checkboxSidesCompletedAnimating++ ;
                if self.checkboxSidesCompletedAnimating >= 4 {
                    self.checkboxSidesCompletedAnimating = 0;
                    self.drawCheckmark(true);
                    println("FINISHED spinning box CCW");
                }
        }
    }
}
