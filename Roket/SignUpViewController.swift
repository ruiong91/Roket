//
//  SignUpViewController.swift
//  Roket
//
//  Created by Rui Ong on 17/03/2017.
//  Copyright © 2017 Rui Ong. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class SignUpViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var dbRef : FIRDatabaseReference?
    var ppStorageRef: FIRStorageReference?
    
    let currentUser = FIRAuth.auth()?.currentUser
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dbRef = FIRDatabase.database().reference()
        
        ppStorageRef = FIRStorage.storage().reference().child("Profile Pics")
        
        //usernameTF.text = currentUser?.displayName ?? ""
    }
    
    //------------------------------Sign Up------------------------------------//
    func signUp(){
        
        guard let validUsername = usernameTF.text,
            let validEmail = emailTF.text,
            let validPassword = passwordTF.text,
            let confirmedPassword = confirmPasswordTF.text else {
                return
                //HANDLING: pop up alert to fill up all required
        }
        
        if signUpBtn.titleLabel?.text == "Save"{
            
            let value = ["username": validUsername] as [String : String]
            let uid = FIRAuth.auth()?.currentUser?.uid
            self.dbRef?.child("users").child(uid!).updateChildValues(value, withCompletionBlock: { (err, ref) in
                
                if err != nil {
                    print("error saving user data in firebase")
                    return
                }
                
                guard let validProfilePic = self.ppImageView.image else {return}
                self.uploadImage(image: validProfilePic)
                
                let alertMessage = UIAlertController (title: "Message", message: "Saved!", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    self.returnToHomePage()
                })
                alertMessage.addAction(okAction)
                
                self.present(alertMessage, animated: true, completion: nil)
            })
            
        } else {
            
            //create user
            if validPassword == confirmedPassword{
                FIRAuth.auth()?.createUser(withEmail: validEmail, password: validPassword, completion: { (user,error) in
                    
                    if error != nil{
                        
                        self.showErrorAlert(errorMessage: "Email/Password Format Invalid")
                        print (error! as NSError)
                        return
                        
                    } else {
                        let alertMessage = UIAlertController (title: "Message", message: "Successfully Registered", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                            self.returnToLoginPage()
                        })
                        alertMessage.addAction(okAction)
                        
                        self.present(alertMessage, animated: true, completion: nil)
                        
                        //save user to database
                        let value = ["username": validUsername, "email": validEmail] as [String : String]
                        let uid = FIRAuth.auth()?.currentUser?.uid
                        self.dbRef?.child("users").child(uid!).updateChildValues(value, withCompletionBlock: { (err, ref) in
                            
                            if err != nil {
                                print("error saving user data in firebase")
                                return
                            }
                            
                            guard let validProfilePic = self.ppImageView.image else {return}
                            self.uploadImage(image: validProfilePic)
                        })
                    }
                })
            } else {
                self.showErrorAlert(errorMessage: "Passwords are not identical.")
                passwordTF.text = ""
                confirmPasswordTF.text = ""
                return
            }
        }
        
    }
    
    //------------------------------Profile Image------------------------------------//
    
    func displayImagePicker(){
        
        let pickerViewController = UIImagePickerController ()
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            pickerViewController.sourceType = .photoLibrary
            
        }
        
        pickerViewController.delegate = self
        
        present(pickerViewController, animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            setProfileImage(image : image)
            
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func setProfileImage(image : UIImage) {
        ppImageView.image = image
    }
    
    func uploadImage(image: UIImage){
        
        // create the Data from UIImage
        guard let imageData = UIImageJPEGRepresentation(image, 0.0) else { return }
        
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/jpeg"
        let uid = FIRAuth.auth()?.currentUser?.uid
        ppStorageRef?.child("\(uid!)pp.jpeg").put(imageData, metadata: metadata) { (meta, error) in
            
            if let error = error {
                print(error.localizedDescription)
                return
            }else{
                
                if let downloadURL = meta?.downloadURL() {
                    
                    self.dbRef?.child("users").child(uid!).child("profilePicURL").setValue(downloadURL.absoluteString)
                }
            }
        }
    }
    
    
    //------------------------------Error Handling, Segue----------------------------//
    func showErrorAlert(errorMessage: String){
        let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle:  .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        
        present(alert, animated:true, completion: nil)
    }
    
    func returnToLoginPage(){
        guard let controller = storyboard?.instantiateViewController(withIdentifier: "LogInViewController") as?  LogInViewController
            else { return }
        self.present(controller, animated: true, completion: nil)
    }
    
    func returnToHomePage(){
        guard let controller = storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as?  HomeViewController
            else { return }
        self.present(controller, animated: true, completion: nil)
    }
    
    
    //----------------IBOutlets-----------------------//
    @IBOutlet weak var ppImageView: UIImageView!{
        didSet{
            ppImageView.layer.cornerRadius = ppImageView.frame.size.height/2
            ppImageView.clipsToBounds = true
        }
    }
    
    //----------------TF-----------------------//
    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var confirmPasswordTF: UITextField!
    
    //---------------Buttons------------------//
    @IBOutlet weak var addPPBtn: UIButton! {
        didSet{
            addPPBtn.addTarget(self, action: #selector(displayImagePicker), for: .touchUpInside)
        }
    }
    @IBOutlet weak var signUpBtn: UIButton! {
        didSet{
            
            signUpBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
            signUpBtn.layer.cornerRadius = 15
            signUpBtn.layer.borderWidth = 2
            signUpBtn.layer.borderColor = UIColor.black.cgColor
            
            signUpBtn.addTarget(self, action: #selector(signUp), for: .touchUpInside)
        }
    }
    @IBOutlet weak var cancelBtn: UIButton! {
        didSet{
            
            cancelBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
            cancelBtn.layer.cornerRadius = 15
            cancelBtn.layer.borderWidth = 2
            cancelBtn.layer.borderColor = UIColor.black.cgColor
            
            cancelBtn.addTarget(self, action: #selector(returnToLoginPage), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var logOutBtn: UIButton!{
        didSet{
            logOutBtn.addTarget(self, action: #selector(returnToLoginPage), for: .touchUpInside)
        }
    }
    
    
}
