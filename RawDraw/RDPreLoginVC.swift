//
//  RDLoginVC.swift
//  RawDraw
//
//  Created by sheetal pahadi on 09/04/24.
//

import UIKit

class RDPreLoginVC: UIViewController {

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    func setupUI(){
        view.backgroundColor = UIColor.white
        loginButton.layer.cornerRadius = 10
        loginButton.backgroundColor = UIColor(named: Constants.Colors.appBlue)
        loginButton.tintColor = UIColor.white
        signupButton.layer.cornerRadius = 10
        signupButton.backgroundColor = UIColor(named: Constants.Colors.appBlue)
        signupButton.tintColor = UIColor.white
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        let vc = RDLoginVC(nibName: "RDLoginVC", bundle: Bundle.main)
        vc.modalPresentationStyle = .fullScreen
        if let navigationController = view.window?.rootViewController as? UINavigationController{
            navigationController.isNavigationBarHidden = false
            navigationController.pushViewController(vc, animated: true)
        }
        /*view.window?.rootViewController = vc
        view.window?.makeKeyAndVisible()*/
    }
    
    @IBAction func signupTapped(_ sender: Any) {
        let vc = RDSignupVC(nibName: "RDSignupVC", bundle: Bundle.main)
        vc.modalPresentationStyle = .fullScreen
        if let navigationController = view.window?.rootViewController as? UINavigationController{
            navigationController.isNavigationBarHidden = false
            navigationController.pushViewController(vc, animated: true)
        }
        /*view.window?.rootViewController = vc
        view.window?.makeKeyAndVisible()*/
    }
}
