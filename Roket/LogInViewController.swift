//
//  LogInViewController.swift
//  Roket
//
//  Created by Rui Ong on 17/03/2017.
//  Copyright © 2017 Rui Ong. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class LogInViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        emailTF.text = "rui@mail.com"
        passwordTF.text = "123456"
        
        
    }
    
    //------------------------------Log In----------------------------//
    func login () {
        FIRAuth.auth()?.signIn(withEmail: emailTF.text!, password: passwordTF.text!, completion: {(user,error) in
            
            if error != nil {
                
                print(error! as NSError)
                self.showErrorAlert(errorMessage: "Email/Password Incorrect")
                return
                
            }
            
            //PatientDetail.current.uid = (user?.uid)!
            //PatientDetail.current.fetchUserInformationViaID()
            
            guard let controller = self.storyboard?.instantiateViewController(withIdentifier: "HomeNavigationController") as?  UINavigationController else { return }
            self.present(controller, animated: true, completion: nil)
            print ("Log in succesfull")
            
            
        })
    }
    
    //------------------------------Error Handling, Segue----------------------------//
    func showErrorAlert(errorMessage: String){
        let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle:  .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        
        present(alert, animated:true, completion: nil)
    }
    
    func openSignUpPage(){
        guard let controller = self.storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") as?  SignUpViewController else { return }
        self.present(controller, animated: true, completion: nil)
    }
    
    //----------------IBOutlets-----------------------//
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    //---------------Buttons------------------//
    @IBOutlet weak var logInBtn: UIButton!{
        didSet{
            
            logInBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
            logInBtn.layer.cornerRadius = 10
            logInBtn.layer.borderWidth = 2
            logInBtn.layer.borderColor = UIColor.black.cgColor

            logInBtn.addTarget(self, action: #selector(login), for: .touchUpInside)
        }
    }
    @IBOutlet weak var signUpBtn: UIButton!{
        didSet{
            
            signUpBtn.addTarget(self, action: #selector(openSignUpPage), for: .touchUpInside)
        }
    }
    
    
}
