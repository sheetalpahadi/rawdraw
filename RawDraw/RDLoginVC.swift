//
//  RDLoginVC.swift
//  RawDraw
//
//  Created by sheetal pahadi on 10/04/24.
//

import UIKit
import Firebase

class RDLoginVC: UIViewController {

    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var signinButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI(){
        //view.backgroundColor = UIColor(named: Constants.Colors.appBlue)
        signinButton.layer.cornerRadius = 10
        signinButton.backgroundColor = UIColor(named: Constants.Colors.appBlue)
        signinButton.tintColor = UIColor.white
        errorLabel.alpha = 0
        passwordTextField.isSecureTextEntry = true
        let navbar = self.navigationController?.navigationBar
        navbar?.tintColor = UIColor(named: Constants.Colors.appDarkBlue)
        navbar?.topItem?.backButtonTitle = ""
    }
    
    func isEmailValid() -> Bool{
        return true
    }
    
    func isPasswordValid() -> Bool{
        return true
    }
    
    func navigateToUserDashboard(){
        let vc = RDUserDashboardVC(nibName: "RDUserDashboardVC", bundle: Bundle.main)
        vc.modalPresentationStyle = .fullScreen
        if let navcontroller = view.window?.rootViewController as? UINavigationController{
            navcontroller.pushViewController(vc, animated: true)
        }
        /*view.window?.rootViewController = vc
        view.window?.makeKeyAndVisible()*/
    }

    @IBAction func signinTapped(_ sender: Any) {
        //validate entries
        if isEmailValid() && isPasswordValid(){
            //communicate with Firebase to login
            let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            if email == nil{
                return
            }
            if password == nil{
                return
            }
            Auth.auth().signIn(withEmail: email!, password: password!) { result, err in
                if let err = err{
                    //show error screen
                    self.errorLabel.text = "Error signing in"
                    self.errorLabel.alpha = 1
                }else{
                    self.errorLabel.alpha = 1
                    self.errorLabel.text = "Successfully signed in"
                    AppCurrentDetails.shared.userID = result!.user.uid
                    self.navigateToUserDashboard()
                }
            }
        }else{
            //error label update
            errorLabel.text = "Please enter valid email and password!"
            errorLabel.textColor = UIColor.red
            errorLabel.alpha = 1
        }
        
    }
}
