//
//  ClockFaceView.swift
//  MeterialUIKit
//
//  Created by damingdan on 14/12/30.
//  Copyright (c) 2014年 com.metalmind. All rights reserved.
//

import UIKit

@IBDesignable
class ClockFaceView: UIView {
    class ClockFaceLayer: CAShapeLayer {
        private var hourHand:CAShapeLayer = CAShapeLayer();
        private var minuteHand:CAShapeLayer = CAShapeLayer();
        
        init(size:CGSize) {
            super.init();
            self.frame = CGRectZero;
            self.frame.size = size;
            self.setup();
        }

        required init(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder);
            setup();
        }
        
        func setup() {
            frame = CGRectMake(0, 0, 200, 200);
            path = UIBezierPath(ovalInRect: CGRectInset(frame, 5, 5)).CGPath;
            fillColor = UIColor.whiteColor().CGColor;
            strokeColor = UIColor.blackColor().CGColor;
            lineWidth = 4;
            
            hourHand.path = UIBezierPath(rect: CGRect(x: -2, y:-70, width:4, height:70)).CGPath;
            hourHand.fillColor = UIColor.blackColor().CGColor;
            hourHand.position = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
            addSublayer(hourHand);
            
            minuteHand.path = UIBezierPath(rect: CGRect(x: -1, y:-90, width:2, height:90)).CGPath;
            minuteHand.fillColor = UIColor.blackColor().CGColor;
            minuteHand.position = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
            addSublayer(minuteHand);
        }
        
        func refreshColor(color: UIColor) {
            hourHand.fillColor = color.CGColor
            minuteHand.fillColor = color.CGColor
            strokeColor = color.CGColor
        }

        func refreshHour(hour:Int, minute:Int) {
            hourHand.setAffineTransform(CGAffineTransformMakeRotation(CGFloat(Double(hour) / 12.0 * 2.0 * M_PI)));
            minuteHand.setAffineTransform(CGAffineTransformMakeRotation(CGFloat(Double(minute) / 60.0 * 2.0 * M_PI)));
        }
    }
    
    private var clockFaceLayer: ClockFaceLayer?;
    
    
    @IBInspectable
    var color: UIColor? {
        didSet {
            refreshColor()
        }
    }
    
    
    var time:NSDate? {
        didSet {
            refreshTime();
        }
    }
    
    private func refreshTime() {
        if let realTime = time {
            if let calendar = NSCalendar(calendarIdentifier: NSGregorianCalendar) {
                let components = calendar.components(NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitMinute, fromDate: realTime);
                clockFaceLayer!.refreshHour(components.hour, minute: components.minute);
            }
        }
    }
    
    private func refreshColor() {
        if let realColor = color {
            clockFaceLayer!.refreshColor(realColor);
        }
    }
    
    override func prepareForInterfaceBuilder() {
        time = NSDate();
        color = UIColor.redColor();
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        clockFaceLayer = ClockFaceLayer(size: frame.size);
        layer.addSublayer(clockFaceLayer);
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        clockFaceLayer = ClockFaceLayer(size: frame.size);
        layer.addSublayer(clockFaceLayer);
    }

}
