//
//  ViewController.swift
//  SecretSwift
//
//  Created by Ahmed Juvale on 8/25/25.
//

import UIKit
import LocalAuthentication

class ViewController: UIViewController {
    @IBOutlet var secret: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Nothing to see here"

        let notificationCenter = NotificationCenter.default
        notificationCenter
            .addObserver(
                self,
                selector: #selector(adjustForKeyboard),
                name: UIResponder.keyboardWillChangeFrameNotification,
                object: nil
            )
        notificationCenter
            .addObserver(
                self,
                selector: #selector(adjustForKeyboard),
                name: UIResponder.keyboardWillChangeFrameNotification,
                object: nil
            )
        notificationCenter
            .addObserver(
                self,
                selector: #selector(saveSecretMessage),
                name: UIApplication.willResignActiveNotification,
                object: self
            )
    }


    @IBAction func authenticateTapped(_ sender: Any) {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Identify yourself!"

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
 sucess,
 authenticationError in
                DispatchQueue.main.async {
                    if sucess {
                        self.unlockSecretMessage()
                    } else {
                        let ac = UIAlertController(
                            title: "Authentication failed",
                            message: "You could not verified; please try again.",
                            preferredStyle: .alert
                        )
                        ac.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(ac, animated: true)
                    }
                }
            }
        } else {
            let ac = UIAlertController(
                title: "Biometrics unavailable",
                message: "Your device is not configured for biometric authentication.",
                preferredStyle: .alert
            )
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }

    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as?
                NSValue else { return }

        let keyboardScreenEnd = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEnd, from: view.window)


        if notification.name == UIResponder.keyboardWillHideNotification {
            secret.contentInset = .zero
        } else {
            secret.contentInset = UIEdgeInsets(
                top: 0,
                left: 0,
                bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom,
                right: 0
            )
        }

        secret.scrollIndicatorInsets = secret.contentInset

        let selectedRange = secret.selectedRange
        secret.scrollRangeToVisible(selectedRange)
    }

    func unlockSecretMessage() {
        secret.isHidden = false
        title = "Secret Stuff!"

        secret.text = KeychainWrapper.standard.string(forKey: "SecretMessage") ?? ""
    }

    @objc func saveSecretMessage() {
        guard secret.isHidden == false else { return }

        KeychainWrapper.standard.set(secret.text, forKey: "SecretMessage")
        secret.resignFirstResponder()
        secret.isHidden = false
        title = "Nothing to see here"
    }
}

