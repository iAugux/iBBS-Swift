//
//  IBBSColorPickerViewController.swift
//  iBBS
//
//  Created by Augus on 5/4/16.
//  Copyright © 2016 iAugus. All rights reserved.
//

import UIKit
import SwiftColorPicker


protocol ColorPickerViewControllerDelegate {
    func colorDidChange(color: UIColor)
}

class IBBSColorPickerViewController: UIViewController {
    
    var delegate: ColorPickerViewControllerDelegate!

    var pickerController: ColorPickerController?
    
    @IBOutlet private weak var colorPicker: ColorPicker! {
        didSet {
            colorPicker.backgroundColor = UIColor.clearColor()
            colorPicker.layer.cornerRadius = 8
        }
    }
    
    @IBOutlet private weak var huePicker: HuePicker! {
        didSet{
            huePicker.backgroundColor = UIColor.clearColor()
            huePicker.layer.cornerRadius = 8
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clearColor()
        
        pickerController = ColorPickerController(svPickerView: colorPicker, huePickerView: huePicker, colorWell: ColorWell())
        
        pickerController?.color = UIColor.redColor()
        
        pickerController?.onColorChange = { (color, _) in
            self.delegate?.colorDidChange(color)
        }
    }


}
