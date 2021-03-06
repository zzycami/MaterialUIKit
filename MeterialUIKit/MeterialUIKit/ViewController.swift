//
//  ViewController.swift
//  MeterialUIKit
//
//  Created by damingdan on 14/12/30.
//  Copyright (c) 2014年 com.metalmind. All rights reserved.
//

import UIKit

class ViewController: UIViewController, MeterialCheckboxDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var flatSmart = MetierialButton(frame: CGRectMake(20, 20, 280, 43), raised: false);
        flatSmart.setTitle("PaperButton Flat: Smart Color", forState: UIControlState.Normal);
        flatSmart.titleFont = UIFont(name: "HelveticaNeue-Light", size: 15.0);
        flatSmart.backgroundColor = UIColor.colorWith(0x757575);
        flatSmart.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal);
        flatSmart.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted);
        self.view.addSubview(flatSmart);
        
        var flatDumb = MetierialButton(frame: CGRectMake(20, 71, 280, 43), raised: false);
        flatDumb.setTitle("PaperButton Flat: !Smart Color", forState: UIControlState.Normal);
        flatDumb.usesSmartColor = false;
        flatDumb.titleFont = UIFont(name: "HelveticaNeue-Light", size: 15.0);
        flatDumb.backgroundColor = UIColor.colorWith(0x757575);
        flatDumb.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal);
        flatDumb.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted);
        self.view.addSubview(flatDumb);
        
        var flatClearSmart = MetierialButton(frame: CGRectMake(20, 122, 280, 43), raised: false);
        flatClearSmart.setTitle("BFPaperButton Flat: Clear, Smart Color", forState: UIControlState.Normal);
        flatClearSmart.titleFont = UIFont(name: "HelveticaNeue-Light", size: 15.0);
        flatClearSmart.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal);
        flatClearSmart.setTitleColor(UIColor.blueColor(), forState: UIControlState.Highlighted);
        self.view.addSubview(flatClearSmart);
        
        var flatClearDump = MetierialButton(frame: CGRectMake(20, 173, 280, 43), raised: false);
        flatClearDump.usesSmartColor = false;
        flatClearDump.setTitle("BFPaperButton Flat: Clear, !Smart Color", forState: UIControlState.Normal);
        flatClearDump.titleFont = UIFont(name: "HelveticaNeue-Light", size: 15.0);
        flatClearDump.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal);
        flatClearDump.setTitleColor(UIColor.blueColor(), forState: UIControlState.Highlighted);
        self.view.addSubview(flatClearDump);
        
        
        var raisedSmart = MetierialButton(frame: CGRectMake(20, 239, 280, 43), raised: true);
        raisedSmart.backgroundColor = UIColor.blueColor();
        raisedSmart.setTitle("BFPaperButton Raised: Smart Color", forState: UIControlState.Normal);
        raisedSmart.titleFont = UIFont(name: "HelveticaNeue-Light", size: 15.0);
        self.view.addSubview(raisedSmart);
        
        var dumpedSmart = MetierialButton(frame: CGRectMake(20, 307, 280, 43), raised: true);
        dumpedSmart.usesSmartColor = false;
        dumpedSmart.backgroundColor = UIColor.blueColor();
        dumpedSmart.setTitle("BFPaperButton Raised: Smart Color", forState: UIControlState.Normal);
        dumpedSmart.titleFont = UIFont(name: "HelveticaNeue-Light", size: 15.0);
        self.view.addSubview(dumpedSmart);
        
        var circle1 = MetierialButton(frame: CGRectMake(20, 468, 86, 86), raised: true);
        circle1.setTitle("Center", forState: UIControlState.Normal);
        circle1.titleFont =  UIFont(name: "HelveticaNeue-Light", size: 15.0);
        circle1.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal);
        circle1.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted);
        circle1.backgroundColor = UIColor.greenColor();
        circle1.tapCircleColor = UIColor(red: 1, green: 0, blue: 1, alpha: 0.6);
        circle1.cornerRadius = circle1.frame.width/2;
        circle1.rippleFromTapLocation = false;
        self.view.addSubview(circle1);

        var circle2 = MetierialButton(frame: CGRectMake(116, 468, 86, 86), raised: true);
        circle2.setTitle("Custom", forState: UIControlState.Normal);
        circle2.titleFont =  UIFont(name: "HelveticaNeue-Light", size: 15.0);
        circle2.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal);
        circle2.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted);
        circle2.backgroundColor = UIColor(red: 0.3, green: 0, blue: 1, alpha: 1);
        circle2.tapCircleColor = UIColor(red: 1, green: 0, blue: 1, alpha: 0.6);
        circle2.cornerRadius = circle2.frame.width/2;
        circle2.rippleFromTapLocation = false;
        circle2.rippleBeyondBounds = true;
        circle2.tapCircleDiameter = max(circle2.frame.width, circle2.frame.height)*1.3;
        self.view.addSubview(circle2);
        
        var circle3 = MetierialButton(frame: CGRectMake(212, 468, 86, 86), raised: false);
        circle3.setTitle("Custom", forState: UIControlState.Normal);
        circle3.titleFont =  UIFont(name: "HelveticaNeue-Light", size: 15.0);
        circle3.setTitleColor(UIColor.colorWith(0x212121), forState: UIControlState.Normal);
        circle3.setTitleColor(UIColor.colorWith(0x212121), forState: UIControlState.Highlighted);
        circle3.tapCircleColor = UIColor(red: 1, green: 0, blue: 1, alpha: 0.6);
        circle3.backgroundFadeColor = UIColor(red: 0, green: 0, blue: 1, alpha: 1);
        circle3.cornerRadius = circle3.frame.width/2;
        circle3.tapCircleDiameter = 53;
        self.view.addSubview(circle3);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

