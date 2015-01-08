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
        var checkBox:MeterialCheckBox = MeterialCheckBox(frame: CGRectMake(20, 150, CheckboxDefaultRadius*2, CheckboxDefaultRadius*2));
        checkBox.tag = 1001;
        checkBox.delegate = self;
        //checkBox.backgroundColor = UIColor.greenColor();
        view.addSubview(checkBox);
        
        //checkBox2.backgroundColor = UIColor.redColor();
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

