//
//  SettingsViewController.swift
//  Harmony
//
//  Created by Dharay Mistry on 19/07/18.
//  Copyright © 2018 Forever Knights. All rights reserved.
//

import UIKit
import UserNotifications
class SettingsViewController: UIViewController, UIPickerViewDelegate,UIPickerViewDataSource {

    
    var sleepTimes = ["5 minutes","10 minutes","30 minutes", "1 hour"]
    var multiplier = [5,8,300,600]//,1800,3600]
    @IBOutlet weak var picker: UIPickerView!
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        picker.dataSource = self
        picker.selectRow(themeArray.index(where: {$0.id == currentTheme.id}) ?? 0, inComponent: 0, animated: true)
        // Do any additional setup after loading the view.
    }

   

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return themeArray.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return themeArray[row].id
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        ThemeManager.setTheme(themeID: themeArray[row].id)
    }
}
