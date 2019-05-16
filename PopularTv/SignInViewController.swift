//
//  SignInViewController.swift
//  PopularTv
//
//  Created by Ter, Paul D on 5/6/19.
//  Copyright © 2019 Ter, Paul D. All rights reserved.
//

import UIKit
import FirebaseAuth
import GoogleMobileAds

class SignInViewController: UIViewController {
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    @IBOutlet weak var bannerView: GADBannerView!
    
    override func viewDidAppear(_ animated: Bool) {
        print("view did appear")
        self.hideKeyboardWhenTappedAround()
        checkIfSignedIn()
        

    }
    override func viewWillAppear(_ animated: Bool) {
        print("view will appear")
        bannerView.adUnitID = "ca-app-pub-1666211014421581/6952262564"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
    }
    override func viewDidLoad() {
        print("view did load")
    }
    
    @IBAction func signInClicked(_ sender: Any) {
        Auth.auth().signIn(withEmail: emailTextfield.text ?? "", password: passwordTextfield.text ?? "") { (result, error) in
            if(error == nil){
                let home = self.storyboard?.instantiateViewController(withIdentifier: "Home") as! ViewController
                self.present(home, animated: true, completion: nil)
            }else{
                let alertController = UIAlertController(title: "Invalid Login", message: "", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: .destructive, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            }
        }
        
    }
    
    func checkIfSignedIn(){
        if( Auth.auth().currentUser != nil){
            print("already signed in")
            let home = self.storyboard?.instantiateViewController(withIdentifier: "Home") as! ViewController
            self.present(home, animated: true, completion: nil)
        }else{
            print("not signed in ")
        }
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SignInViewController.dismissKeyboard))
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
