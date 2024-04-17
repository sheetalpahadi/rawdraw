//
//  RDSignupVC.swift
//  RawDraw
//
//  Created by sheetal pahadi on 10/04/24.
//

import UIKit
import Firebase
import FirebaseAuth

class RDSignupVC: UIViewController {
    
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    
    @IBOutlet weak var firstnameTextField: UITextField!
    @IBOutlet weak var lastnameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var messageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUIElements()
    }

    func setupUIElements(){
        signupButton.layer.cornerRadius = 10
        signupButton.backgroundColor = UIColor(named: Constants.Colors.appBlue)
        signupButton.tintColor = UIColor.white
        resetButton.tintColor = UIColor(named: Constants.Colors.appBlue)
        messageLabel.alpha = 0
        passwordTextField.isSecureTextEntry = true
        self.navigationController?.navigationBar.topItem?.backButtonTitle = ""
    }
    
    func navigateToDrawingBoard(){
        let vc = RDUserDashboardVC(nibName: "RDUserDashboardVC", bundle: Bundle.main)
        vc.modalPresentationStyle = .fullScreen
        if let navcontroller = view.window?.rootViewController as? UINavigationController{
            navcontroller.pushViewController(vc, animated: true)
        }
        /*view.window?.rootViewController = vc
        view.window?.makeKeyAndVisible()*/
    }
    
    @IBAction func signupTapped(_ sender: Any) {
        let firstname = firstnameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let lastname = lastnameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if (firstname != nil) && (lastname != nil) && (email != nil) && (password != nil){
            Auth.auth().createUser(withEmail: email!, password: password!) { result, err in
                if let err = err{
                    //
                    self.messageLabel.alpha = 1
                    self.messageLabel.text = "\(err.localizedDescription)"
                    print("authentication error : \(err)")
                    return
                }
                let userID = result!.user.uid
                let db = Firestore.firestore()
                
                db.collection("users").addDocument(data: [
                    "firstname" : firstname, "lastname" : lastname, "uid" : userID
                ]) { err in
                    if let err = err{
                        //
                        self.messageLabel.alpha = 1
                        self.messageLabel.text = "Authentication error"
                        return
                    }
                    //print message
                    self.messageLabel.alpha = 1
                    self.messageLabel.text = "Successfully signed up! Opening your canvas..."
                    //wait for 3 secs
                    DispatchQueue.main.asyncAfter(deadline: .now () + 3){
                        //proceed to next vc
                        AppCurrentDetails.shared.userID = result!.user.uid
                        self.navigateToDrawingBoard()
                    }
                   
                }
            }
        }else{
            messageLabel.alpha = 1
            messageLabel.text = "Please enter valid details"
        }
    }
    @IBAction func resetButtonTapped(_ sender: Any) {
        firstnameTextField.text = nil
        lastnameTextField.text = nil
        emailTextField.text = nil
        passwordTextField.text = nil
    }
}
