//
//  AttributeUpdationViewController.swift
//  HealthApp
//
//  Created by Ratul Chhibber on 12/04/20.
//  Copyright © 2020 Ratul Chhibber. All rights reserved.
//

import UIKit

class AttributeUpdationViewController: UIViewController {
    
    @IBOutlet var height: UILabel!
    @IBOutlet var weight: UILabel!
    @IBOutlet var updateHeight: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateHeight.delegate = self
        
        HealthKitAssistant.shared.read(for: .height) { height in
            DispatchQueue.main.async {
                if let value = height {
                    self.height.text = "\(value) inches"
                }
            }
        }
        HealthKitAssistant.shared.read(for: .weight) { weight in
            DispatchQueue.main.async {
                if let value = weight {
                    self.weight.text = "\(value) kgs"
                }
            }
        }
    }
    
    private func showSuccessAlert() {
        let alert = UIAlertController(title: "Height Updated",
                                      message: nil,
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func successfullyUpdateHeight() {
        HealthKitAssistant.shared.read(for: .height) { height in
            DispatchQueue.main.async {
                self.height.text = height
                self.showSuccessAlert()
            }
        }
    }
}

extension AttributeUpdationViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let writtenText = textField.text
        HealthKitAssistant.shared.saveHeight(for: writtenText!) { isSuccess in
            if isSuccess {
                self.successfullyUpdateHeight()
            }
        }
    }
}

extension UITextField {
    @IBInspectable var doneAccessory: Bool{
        get{
            return self.doneAccessory
        }
        set (hasDone) {
            if hasDone{
                addDoneButtonOnKeyboard()
            }
        }
    }

    func addDoneButtonOnKeyboard()
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))

        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()

        self.inputAccessoryView = doneToolbar
    }

    @objc func doneButtonAction()
    {
        self.resignFirstResponder()
    }
}
