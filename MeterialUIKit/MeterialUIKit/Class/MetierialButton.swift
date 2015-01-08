//
//  MetierialButton.swift
//  MeterialUIKit
//
//  Created by damingdan on 15/1/7.
//  Copyright (c) 2015年 com.metalmind. All rights reserved.
//

import UIKit

// MARK: Useful constants
public let MetierialButton_tapCircleDiameterMedium:CGFloat = 305.0;
public let MetierialButton_tapCircleDiameterSmall = MetierialButton_tapCircleDiameterMedium/2;
public let MetierialButton_tapCircleDiameterLarge = MetierialButton_tapCircleDiameterMedium*1.5;
private let MetierialButton_tapCircleDiameterDefault:CGFloat = -1;

// Constants used for tweaking the look/feel of:
// -shadow radius:
private let loweredShadowRadius:CGFloat = 1.5;
private let raisedShadowRadius:CGFloat = 4.5;

// -shadow location:
private let loweredShadowYOffset:CGFloat = 1.0;
private let raisedShadowYOffset:CGFloat = 4.0;
private let raisedShadowXOffset:CGFloat = 2.0;

// -shadow opacity:
private let loweredShadowOpacity:Float = 0.7;
private let raisedShadowOpacity:Float = 0.5;

// -animation durations:
private let AnimationDurationConstant:Double = 0.12;
private let tapCircleGrowthDurationConstant = AnimationDurationConstant*2;
private let fadeOutDurationConstant = AnimationDurationConstant*4;

// -the tap-circle's size:
private let tapCircleDiameterStartValue:CGFloat = 5.0;// for the mask

// -the tap-circle's beauty:
private let tapFillConstant:CGFloat = 0.16;
private let clearBGTapFillConstant:CGFloat = 0.12;
private let clearBGFadeConstant:CGFloat = 0.12;

private let tapFillColor = UIColor(white: 0.1, alpha: tapFillConstant);
private let clearBgDumpTapFillColor = UIColor(white: 0.3, alpha: clearBGTapFillConstant);
private let clearBgDumpFadeColor = UIColor(white: 0.3, alpha: clearBGFadeConstant);

@IBDesignable
public class MetierialButton: UIButton, UIGestureRecognizerDelegate {
    /** The corner radius which propagates through to the sub layers. */
    @IBInspectable
    public var cornerRadius:CGFloat = loweredShadowRadius {
        willSet {
            backgroundColorFadeLayer.cornerRadius = newValue;
            layer.cornerRadius = newValue;
            if isRaised {
                layer.shadowPath = UIBezierPath(roundedRect: downRect, cornerRadius: newValue).CGPath;
            }
            layoutSubviews();
        }
    }
    
    /** A flag to set to YES to use Smart Color, or NO to use a custom color scheme. While Smart Color is the default (usesSmartColor = YES), customization is cool too. */
    @IBInspectable
    public var usesSmartColor = true
    
    /** The UIColor to use for the circle which appears where you tap. NOTE: Setting this defeats the "Smart Color" ability of the tap circle. Alpha values less than 1 are recommended. */
    public var tapCircleColor:UIColor?
    
    /** The UIColor to fade clear backgrounds to. NOTE: Setting this defeats the "Smart Color" ability of the background fade. An alpha value of 1 is recommended, as the fade is a constant (clearBGFadeConstant) defined in the BFPaperButton.m. This bothers me too. */
    public var backgroundFadeColor:UIColor?
    
    /** The CGFloat value representing the Diameter of the tap-circle. By default it will be the result of MAX(self.frame.width, self.frame.height). Any value less than zero will result in default being used. The constants: tapCircleDiameterLarge, tapCircleDiameterMedium, and tapCircleDiameterSmall are also available for use. */
    @IBInspectable
    public var tapCircleDiameter:CGFloat = MetierialButton_tapCircleDiameterDefault
    
    /** A flag to set to YES to have the tap-circle ripple from point of touch. If this is set to NO, the tap-circle will always ripple from the center of the button. Default is YES. */
    @IBInspectable
    public var rippleFromTapLocation:Bool = true;
    
    /** A flag to set to YES to have the tap-circle ripple beyond the bounds of the button. If this is set to NO, the tap-circle will be clipped to the button's bounds. Default is NO. */
    @IBInspectable
    public var rippleBeyondBounds:Bool = false;
    
    /** A flag to set to YES to CHANGE a flat button to raised, or set to NO to CHANGE a raised button to flat. If you used one of the provided custom initializers, you should probably leave this parameter alone. If you instantiated via storyboard or IB and want to change from riased to flat, this is the parameter for you! */
    @IBInspectable
    public var isRaised:Bool = false {
        willSet {
            downRect = CGRectMake(0, 0, bounds.width, bounds.height + loweredShadowYOffset);
            upRect = CGRectMake(0 - raisedShadowXOffset, bounds.origin.y + raisedShadowYOffset, bounds.width + 2*raisedShadowXOffset, bounds.height + raisedShadowYOffset);
            if newValue {
                // Draw shadow
                layer.shadowColor = UIColor(white: 0.2, alpha: 1.0).CGColor;
                layer.shadowOffset = CGSizeMake(0.1, 1.0);
                layer.shadowOpacity = loweredShadowOpacity;
                layer.shadowRadius = loweredShadowRadius;
                layer.shadowPath = UIBezierPath(roundedRect: downRect, cornerRadius: cornerRadius).CGPath;
            }else {
                layer.shadowOpacity = 0;
            }
        }
    }
    
    /** A property governing the title font. It is settable via UIAppearance! */
    @IBInspectable
    public var titleFont:UIFont? {
        willSet {
            self.titleLabel?.font = newValue;
        }
    }
    
    // Appearance property accessor method, to see http://stackoverflow.com/questions/26170522/appearance-proxies-ui-appearance-selector-in-swift
    public func setTitleFont(font:UIFont) {
        self.titleFont = font;
    }
    
    
    // MARK: Private property
    private var downRect = CGRectZero;
    
    private var upRect = CGRectZero;
    
    private var tapPoint = CGPointZero;
    
    private var letGo = false;
    
    private var growthFinished = false;
    
    private var backgroundColorFadeLayer = CALayer();
    
    private var rippleAnimationQueue:[CAShapeLayer] = [];
    
    // This is where old circle layers go to be killed :(
    private var deathRowForCircleLayers:[CAShapeLayer] = [];
    
    /* Notes on RAISED vs FLAT and SMART COLOR vs NON SMART COLOR:
    *
    * RAISED
    *  Has a shadow, so a clear background will look silly.
    *  It has only a tap-circle color. No background-fade.
    *
    * FLAT
    *  Has no shadow, therefore clear backgrounds look fine.
    *  If the background is clear, it also has a background-fade
    *  color to help visualize the button and its frame.
    *
    * SMART COLOR
    *  Will use the titleLabel's font color to pick
    *  a tap circle color and, if the background is clear, will
    *  also pick a lighter background fade color.
    *
    * NON SMART COLOR
    *  Will use a translucent gray tap-circle
    *  and, if the background is clear, a lighter translucent
    *  graybackground-fade color.
    *
    * to see http://www.google.com/design/spec/components/buttons.html#
    */
    
    // MARK: Custom Initializers
    /**
    *  Initializes a MetierialButton without a frame. Can be Raised of Flat.
    *
    *  @param raised A BOOL flag to determine whether or not this instance should be raised or flat. YES = Raised, NO = Flat.
    *
    *  @return A (Raised or Flat) MetierialButton without a frame!
    */
    public init(raised:Bool) {
        super.init();
        self.setupRaised(raised);
    }
    
    
    /**
    *  Initializes a MetierialButton with a frame. Can be Raised of Flat.
    *
    *  @param frame  A CGRect to use as the button's frame.
    *  @param raised A BOOL flag to determine whether or not this instance should be raised or flat. YES = Raised, NO = Flat.
    *
    *  @return A (Raised or Flat) MetierialButton with a frame!
    */
    public init(frame: CGRect, raised:Bool) {
        super.init(frame: frame);
        self.setupRaised(raised);
    }

    
    
    // MARK: Default Initializers
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        self.setupRaised(true);
    }
    
    public override init() {
        super.init();
        self.setupRaised(true);
    }
    
    public override init(frame: CGRect) {
        var defaultFrame = frame;
        if frame == CGRectZero {
            defaultFrame.size = CGSizeMake(100, 40);
        }
        super.init(frame: defaultFrame);
        self.setupRaised(true);
    }
    
    private func setupRaised(isRaised:Bool) {
        self.isRaised = isRaised;
        
        var endRect = CGRectMake(bounds.origin.x, bounds.origin.y, frame.width, frame.height);
        backgroundColorFadeLayer.frame = endRect;
        backgroundColorFadeLayer.cornerRadius = self.cornerRadius;
        backgroundColorFadeLayer.backgroundColor = UIColor.clearColor().CGColor;
        layer.insertSublayer(backgroundColorFadeLayer, atIndex: 0);
        
        layer.masksToBounds = false;
        clipsToBounds = false;
        
        if isRaised {
            // Draw shadow
            downRect = CGRectMake(0, 0, bounds.width, bounds.height + loweredShadowYOffset);
            upRect = CGRectMake(0 - raisedShadowXOffset, bounds.origin.y + raisedShadowYOffset, bounds.width + 2*raisedShadowXOffset, bounds.height + raisedShadowYOffset);
            
            layer.shadowColor = UIColor(white: 0.2, alpha: 1.0).CGColor;
            layer.shadowOffset = CGSizeMake(0, 1.0);
            layer.shadowOpacity = loweredShadowOpacity;
            layer.shadowRadius = loweredShadowRadius;
            layer.shadowPath = UIBezierPath(roundedRect: downRect, cornerRadius: cornerRadius).CGPath;
        } else {
            layer.shadowOpacity = 0;
        }
        
        addTarget(self, action: "onButtonTouchDown:", forControlEvents: UIControlEvents.TouchDown);
        addTarget(self, action: "onButtonTouchUp:", forControlEvents: UIControlEvents.TouchDragOutside);
        addTarget(self, action: "onButtonTouchUp:", forControlEvents: UIControlEvents.TouchUpInside);
        addTarget(self, action: "onButtonTouchUp:", forControlEvents: UIControlEvents.TouchCancel);
        
        var tapGuestureRecognizer = UITapGestureRecognizer(target: self, action: nil);
        tapGuestureRecognizer.delegate = self;
        self.addGestureRecognizer(tapGuestureRecognizer);
        
        UIView.setAnimationDidStopSelector("animationDidStop:finished:");
    }
    
    // MARK: Gesture Recognizer Delegate
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        var location:CGPoint = touch.locationInView(self);
        println("location: x = \(location.x), y = \(location.y)");
        tapPoint = location;
        return false;// Disallow recognition of tap gestures. We just needed this to grab that tasty tap location.
    }
    
    // MARK:Parent Overrides
    public override var enabled:Bool {
        didSet {
            if isRaised {
                if !enabled {
                    self.layer.shadowOpacity = 0;
                }else {
                    self.layer.shadowOpacity = loweredShadowOpacity;
                }
            }
            self.setNeedsDisplay();
        }
    }
    
    public override func sizeToFit() {
        super.sizeToFit();
        if isRaised {
            downRect = CGRectMake(0, 0, bounds.width, bounds.height + loweredShadowYOffset);
            upRect = CGRectMake(0 - raisedShadowXOffset, bounds.origin.y + raisedShadowYOffset, bounds.width + 2*raisedShadowXOffset, bounds.height + raisedShadowYOffset);
            layer.shadowPath = UIBezierPath(roundedRect: downRect, cornerRadius: cornerRadius).CGPath;
        }
    }
    
    
    //MARK: IBAction Callback Handlers
    func onButtonTouchDown(sender: AnyObject) {
        letGo = false;
        growthFinished = false;
        growTapCircle();
    }
    
    func onButtonTouchUp(sender: AnyObject) {
        letGo = true;
        growTapCircleABit();
        fadeTapCircleOut();
        fadeBGOutAndBringShadowBackToStart();
    }
    
    //MARK: Animation
    public override func animationDidStop(anim: CAAnimation!, finished flag: Bool) {
        var key = anim.valueForKey("id") as String;
        println("animation ENDED \(key)");
        if key == "fadeCircleOut" {
            if deathRowForCircleLayers.count > 0 {
                deathRowForCircleLayers[0].removeFromSuperlayer();
                deathRowForCircleLayers.removeAtIndex(0);
            }
        } else if key == "removeFadeBackgroundDarker" {
            backgroundColorFadeLayer.backgroundColor = UIColor.clearColor().CGColor;
        }
    }
    
    func growTapCircle() {
        println("expanding a tap circle");
        if isRaised {
            // Increase shadow radius:
            var increaseRadius = CABasicAnimation(keyPath: "shadowRadius");
            increaseRadius.fromValue = loweredShadowRadius;
            increaseRadius.toValue = raisedShadowRadius;
            increaseRadius.duration = AnimationDurationConstant;
            increaseRadius.fillMode = kCAFillModeForwards;
            increaseRadius.removedOnCompletion = false;
            
            // Change its frame a bit larger and shift it down a bit:
            var shadowAnimation = CABasicAnimation(keyPath: "shadowPath");
            shadowAnimation.duration = AnimationDurationConstant;
            shadowAnimation.fromValue = UIBezierPath(roundedRect: downRect, cornerRadius: cornerRadius).CGPath;
            shadowAnimation.toValue = UIBezierPath(roundedRect: upRect, cornerRadius: cornerRadius).CGPath;
            shadowAnimation.fillMode = kCAFillModeForwards;
            shadowAnimation.removedOnCompletion = false;
            
            // Lighten the shadow opacity:
            var shadowOpacityAnimation = CABasicAnimation(keyPath: "shadowOpacity");
            shadowAnimation.duration = AnimationDurationConstant;
            shadowAnimation.fromValue = loweredShadowOpacity;
            shadowAnimation.toValue = raisedShadowOpacity;
            shadowAnimation.fillMode = kCAFillModeForwards;
            shadowAnimation.removedOnCompletion = false;
            
            layer.addAnimation(shadowAnimation, forKey: "shadow");
            layer.addAnimation(increaseRadius, forKey: "shadowRadius");
            layer.addAnimation(shadowOpacityAnimation, forKey: "shadowOpacity");
        }
        
        // Spawn a growing circle that "ripples" through the button:
        var endRect = CGRectMake(bounds.origin.x, bounds.origin.y, frame.width, frame.height);
        if backgroundColor == UIColor.clearColor() {
            // CLEAR BACKROUND SHOULD ONLY BE FOR FLAT BUTTONS!!!
            
            // Set the fill color for the tap circle (self.animationLayer's fill color):
            if tapCircleColor? == nil {
                self.tapCircleColor = usesSmartColor ? titleLabel?.textColor.colorWithAlphaComponent(clearBGTapFillConstant) : clearBgDumpTapFillColor;
            }
            
            if backgroundFadeColor? == nil {
                backgroundFadeColor = usesSmartColor ? titleLabel?.textColor : clearBgDumpFadeColor;
            }
            
            // Setup background fade layer:
            backgroundColorFadeLayer.frame = endRect;
            backgroundColorFadeLayer.cornerRadius = cornerRadius;
            backgroundColorFadeLayer.backgroundColor = backgroundFadeColor!.CGColor;
            
            // Fade the background color a bit darker:
            var fadeBackgroundDarker = CABasicAnimation(keyPath: "opacity");
            fadeBackgroundDarker.duration = AnimationDurationConstant;
            fadeBackgroundDarker.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut);
            fadeBackgroundDarker.fromValue = 0;
            fadeBackgroundDarker.toValue = clearBGFadeConstant;
            fadeBackgroundDarker.fillMode = kCAFillModeForwards;
            fadeBackgroundDarker.removedOnCompletion = false;
            
            backgroundColorFadeLayer.addAnimation(fadeBackgroundDarker, forKey: "animateOpacity");
        }else {
            // COLORED BACKGROUNDS (can be smart or dumb):
            if tapCircleColor? == nil {
                self.tapCircleColor = usesSmartColor ? titleLabel?.textColor.colorWithAlphaComponent(tapFillConstant) : tapFillColor;
            }
        }
        
    
        
        // Calculate the tap circle's ending diameter:
        var tapCircleFinalDiameter:CGFloat = tapCircleDiameter < 0 ? max(frame.width, frame.height) : tapCircleDiameter;
        
        // Create a UIView which we can modify for its frame value later (specifically, the ability to use .center):
        var tapCircleLayerSizerView = UIView(frame: CGRectMake(0, 0, tapCircleFinalDiameter, tapCircleFinalDiameter));
        tapCircleLayerSizerView.center = rippleFromTapLocation ? tapPoint : CGPointMake(bounds.midX, bounds.midY);
        
        // Calculate starting path:
        var startingRectSizerView = UIView(frame: CGRectMake(0, 0, tapCircleDiameterStartValue, tapCircleDiameterStartValue));
        startingRectSizerView.center = tapCircleLayerSizerView.center;
        
        // Create starting circle path:
        var startingCirclePath = UIBezierPath(roundedRect: startingRectSizerView.frame, cornerRadius: tapCircleDiameterStartValue/2.0);
        
        // Calculate ending path:
        var endingRectSizerView = UIView(frame: CGRectMake(0, 0, tapCircleFinalDiameter, tapCircleFinalDiameter));
        endingRectSizerView.center = tapCircleLayerSizerView.center;
        
        // Create ending circle path:
        var endingCirclePath = UIBezierPath(roundedRect: endingRectSizerView.frame, cornerRadius: tapCircleFinalDiameter/2.0);
        
        
        // Create tap circle:
        var tapCircle = CAShapeLayer();
        tapCircle.fillColor = tapCircleColor!.CGColor;
        tapCircle.strokeColor = UIColor.clearColor().CGColor;
        tapCircle.borderColor = UIColor.clearColor().CGColor;
        tapCircle.borderWidth = 0;
        tapCircle.path = startingCirclePath.CGPath;
        
        // Create a mask if we are not going to ripple over bounds:
        if !rippleBeyondBounds {
            var mask = CAShapeLayer();
            mask.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).CGPath;
            mask.fillColor = UIColor.blackColor().CGColor;
            mask.strokeColor = UIColor.clearColor().CGColor;
            mask.borderColor = UIColor.clearColor().CGColor;
            mask.borderWidth = 0;
            
            // Set tap circle layer's mask to the mask:
            tapCircle.mask = mask;
        }
        
        // Add tap circle to array and view:
        rippleAnimationQueue.append(tapCircle);
        layer.insertSublayer(tapCircle, above: backgroundColorFadeLayer);

        var tapCircleGrowthAnimation = CABasicAnimation(keyPath: "path");
        tapCircleGrowthAnimation.delegate = self;
        tapCircleGrowthAnimation.setValue("tapGrowth", forKey: "id");
        tapCircleGrowthAnimation.duration = tapCircleGrowthDurationConstant;
        tapCircleGrowthAnimation.fromValue = startingCirclePath.CGPath;
        tapCircleGrowthAnimation.toValue = endingCirclePath.CGPath;
        tapCircleGrowthAnimation.fillMode = kCAFillModeForwards;
        tapCircleGrowthAnimation.removedOnCompletion = false;
        tapCircleGrowthAnimation.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseOut);
        
        // Fade in self.animationLayer:
        var fadeIn = CABasicAnimation(keyPath: "opacity");
        fadeIn.duration = AnimationDurationConstant;
        fadeIn.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseOut);
        fadeIn.fromValue = 0;
        fadeIn.toValue = 1.0;
        fadeIn.fillMode = kCAFillModeForwards;
        fadeIn.removedOnCompletion = false;
        
        // Add the animations to the layers:
        tapCircle.addAnimation(tapCircleGrowthAnimation, forKey: "animatePath");
        tapCircle.addAnimation(fadeIn, forKey: "opacityAnimation");
    }
    
    func growTapCircleABit() {
        // Create a UIView which we can modify for its frame value later (specifically, the ability to use .center):
        var tapCircleDiameterStartValue:CGFloat = tapCircleDiameter < 0 ? max(frame.width, frame.height) : tapCircleDiameter;
        var tapCircleLayerSizerView = UIView(frame: CGRectMake(0, 0, tapCircleDiameter, tapCircleDiameter));
        tapCircleLayerSizerView.center = rippleFromTapLocation ? tapPoint : CGPointMake(bounds.midX, bounds.midY);
        
        // Calculate starting path:
        var startingRectSizerView = UIView(frame: CGRectMake(0, 0, tapCircleDiameterStartValue, tapCircleDiameterStartValue));
        startingRectSizerView.center = tapCircleLayerSizerView.center;
        
        // Create starting circle path:
        var startingCirclePath = UIBezierPath(roundedRect: startingRectSizerView.frame, cornerRadius: tapCircleDiameterStartValue/2.0);
        
        // Calculate ending path:
        var tapCircleDiameterEndValue:CGFloat = tapCircleDiameter < 0 ? max(frame.width, frame.height) : tapCircleDiameter;
        tapCircleDiameterEndValue += 100;
        var endingRectSizerView = UIView(frame: CGRectMake(0, 0, tapCircleDiameterEndValue, tapCircleDiameterEndValue));
        endingRectSizerView.center = tapCircleLayerSizerView.center;
        
        // Create ending circle path:
        var endingCirclePath = UIBezierPath(roundedRect: endingRectSizerView.frame, cornerRadius: tapCircleDiameterEndValue/2.0);
        
        // Get the next tap circle to expand:
        var tapCircle = rippleAnimationQueue.first as CAShapeLayer?;
        
        // Expand tap-circle animation:
        var tapCircleGrowthAnimation = CABasicAnimation(keyPath: "path");
        tapCircleGrowthAnimation.duration = fadeOutDurationConstant;
        tapCircleGrowthAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut);
        tapCircleGrowthAnimation.fromValue = startingCirclePath.CGPath;
        tapCircleGrowthAnimation.toValue = endingCirclePath.CGPath;
        tapCircleGrowthAnimation.fillMode = kCAFillModeForwards;
        tapCircleGrowthAnimation.removedOnCompletion = false;
        
        tapCircle?.addAnimation(tapCircleGrowthAnimation, forKey: "animatePath");
    }
    
    func fadeBGOutAndBringShadowBackToStart() {
        if isRaised {
            // Increase shadow radius:
            var increaseRadius = CABasicAnimation(keyPath: "shadowRadius");
            increaseRadius.fromValue = raisedShadowRadius;
            increaseRadius.toValue = loweredShadowRadius;
            increaseRadius.duration = fadeOutDurationConstant;
            increaseRadius.fillMode = kCAFillModeForwards;
            increaseRadius.removedOnCompletion = false;
            
            // Change its frame a bit larger and shift it down a bit:
            var shadowAnimation = CABasicAnimation(keyPath: "shadowPath");
            shadowAnimation.duration = fadeOutDurationConstant;
            shadowAnimation.fromValue = UIBezierPath(roundedRect: upRect, cornerRadius: cornerRadius).CGPath;
            shadowAnimation.toValue = UIBezierPath(roundedRect: downRect, cornerRadius: cornerRadius).CGPath;
            shadowAnimation.fillMode = kCAFillModeForwards;
            shadowAnimation.removedOnCompletion = false;
            
            // Lighten the shadow opacity:
            var shadowOpacityAnimation = CABasicAnimation(keyPath: "shadowOpacity");
            shadowAnimation.duration = fadeOutDurationConstant;
            shadowAnimation.fromValue = raisedShadowOpacity;
            shadowAnimation.toValue = loweredShadowOpacity;
            shadowAnimation.fillMode = kCAFillModeForwards;
            shadowAnimation.removedOnCompletion = false;
            
            layer.addAnimation(shadowAnimation, forKey: "shadow");
            layer.addAnimation(increaseRadius, forKey: "shadowRadius");
            layer.addAnimation(shadowOpacityAnimation, forKey: "shadowOpacity");
        }
        
        if backgroundColor == UIColor.clearColor() {
            // Fade the background color a bit darker:
            var removeFadeBackgroundDarker = CABasicAnimation(keyPath: "opacity");
            removeFadeBackgroundDarker.delegate = self;
            removeFadeBackgroundDarker.setValue("removeFadeBackgroundDarker", forKey: "id");
            removeFadeBackgroundDarker.duration = AnimationDurationConstant;
            removeFadeBackgroundDarker.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear);
            removeFadeBackgroundDarker.fromValue = clearBGFadeConstant;
            removeFadeBackgroundDarker.toValue = 0;
            removeFadeBackgroundDarker.fillMode = kCAFillModeForwards;
            removeFadeBackgroundDarker.removedOnCompletion = false;
            
            backgroundColorFadeLayer.addAnimation(removeFadeBackgroundDarker, forKey: "removeBGShade");
        }
    }
    
    func fadeTapCircleOut() {
        println("Fading away");
        if rippleAnimationQueue.count > 0 {
            var tempAnimationLayer:CAShapeLayer = rippleAnimationQueue.first!;
            rippleAnimationQueue.removeAtIndex(0);
            
            deathRowForCircleLayers.append(tempAnimationLayer);
            
            var fadeOut = CABasicAnimation(keyPath: "opacity");
            fadeOut.delegate = self;
            fadeOut.setValue("fadeCircleOut", forKey: "id");
            fadeOut.fromValue = tempAnimationLayer.opacity;
            fadeOut.toValue = 0;
            fadeOut.duration = fadeOutDurationConstant;
            fadeOut.fillMode = kCAFillModeForwards;
            fadeOut.removedOnCompletion = false;
            
            tempAnimationLayer.addAnimation(fadeOut, forKey: "opacityAnimation");
        }
    }
    
}
