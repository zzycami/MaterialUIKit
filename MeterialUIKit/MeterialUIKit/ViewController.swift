//
//  ViewController.swift
//  MeterialUIKit
//
//  Created by damingdan on 14/12/30.
//  Copyright (c) 2014年 com.metalmind. All rights reserved.
//

import UIKit

class ViewController: UIViewController, MeterialCheckboxDelegate {

    @IBOutlet weak var checkBox2: MeterialCheckBox!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        var checkBox:MeterialCheckBox = MeterialCheckBox(frame: CGRectMake(20, 150, CheckboxDefaultRadius*2, CheckboxDefaultRadius*2));
//        checkBox.tag = 1001;
//        checkBox.delegate = self;
//        //checkBox.backgroundColor = UIColor.greenColor();
//        view.addSubview(checkBox);
        
        
        var flatSmart = MetierialButton(frame: CGRectMake(20, 20, 280, 43), raised: false);
        flatSmart.setTitle("BFPaperButton Flat: Smart Color", forState: UIControlState.Normal);
        flatSmart.titleFont = UIFont(name: "HelveticaNeue-Light", size: 15.0);
        flatSmart.backgroundColor = UIColor.colorWith(0x757575);
        flatSmart.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal);
        flatSmart.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted);
        self.view.addSubview(flatSmart);
        

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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

