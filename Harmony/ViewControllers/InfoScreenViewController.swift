//
//  InfoScreenViewController.swift
//  Harmony
//
//  Created by Dharay Mistry on 19/07/18.
//  Copyright © 2018 Forever Knights. All rights reserved.
//

import UIKit

class InfoScreenViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func mailToTextFieldTapped(_ sender: UITapGestureRecognizer) {
        let url = URL(string: "mailto:dharay.m@gmail.com")
        UIApplication.shared.open(url!, options: [:], completionHandler: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doneButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
