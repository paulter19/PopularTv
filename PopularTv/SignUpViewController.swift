//
//  SignUpViewController.swift
//  PopularTv
//
//  Created by Ter, Paul D on 5/6/19.
//  Copyright © 2019 Ter, Paul D. All rights reserved.
//

import UIKit
import Firebase
import GoogleMobileAds

class SignUpViewController: UIViewController {

    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var usernameTextfields: UITextField!
    @IBOutlet weak var emailTextfield: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        bannerView.adUnitID = "ca-app-pub-1666211014421581/6952262564"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        self.hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view.
    }
    @IBAction func signUpPressed(_ sender: Any) {
        
        if(self.emailTextfield.text?.count ?? 0 <= 4 || self.usernameTextfields.text?.count ?? 0 <= 4 || self.passwordTextfield.text?.count ?? 0 <= 4){
            
            let alertController = UIAlertController(title: "Invalid Signup", message: "All fields should be 4 characters or more", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .destructive, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            
            
            return
            
        }
        
        
        Auth.auth().createUser(withEmail: emailTextfield.text!, password: passwordTextfield.text!) { (user, error) in
            if(error == nil){
                
                let username = self.usernameTextfields.text
                let email = self.emailTextfield.text?.uppercased()
                
                Database.database().reference().child("Users").child((user?.user.uid)!).setValue(["username":username,"email":email,"userID":user?.user.uid.uppercased(),"friends":["PAULTER17@GMAIL.COM"],"mymovies":["01"]])
                
                
                let home = self.storyboard?.instantiateViewController(withIdentifier: "Home") as! ViewController
                self.present(home, animated: true, completion: nil)
            }else{
                let alertController = UIAlertController(title: "Invalid Signup", message: "", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: .destructive, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            }
        }
        
        
        
    }
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SignUpViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        print("dismiss keyboard")
        view.endEditing(true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
