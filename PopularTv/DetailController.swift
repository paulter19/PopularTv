//
//  DetailController.swift
//  PopularTv
//
//  Created by Ter, Paul D on 5/6/19.
//  Copyright © 2019 Ter, Paul D. All rights reserved.
//

import UIKit
import Firebase
import GoogleMobileAds

class DetailController: UIViewController,GADBannerViewDelegate {

    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var caption: UITextView!
    @IBOutlet weak var image: UIImageView!
    var movieTitle = ""
    var movie:Movie?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
        
    }
    
    @IBAction func pressAddToMyShows(_ sender: Any) {
        let ref =  Database.database().reference().child("Users").child(Auth.auth().currentUser?.uid ?? "")
        
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? [String:Any]{
                let userDictionary = dict 
                var movies = userDictionary["mymovies"] as! [String]
                if(!movies.contains(self.movie?.getId() ?? "")){
                    movies.append(self.movie?.getId() ?? "")
                }
                Database.database().reference().child("Users").child((Auth.auth().currentUser?.uid)!).updateChildValues(["mymovies":movies])
                
                let alertController = UIAlertController(title: "Added", message: "", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: .destructive, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                
                let myMovies = self.storyboard?.instantiateViewController(withIdentifier: "MyMovies") as! MyMoviesViewController
                
                self.present(myMovies, animated: false, completion: nil)
                
            }
        }
        
    }
    
    func loadImage(imageUrl: String){
        URLSession.shared.dataTask(with: URL(string: imageUrl)!, completionHandler: { (data, response, error) in
            
            if error != nil {
                print(error!)
                return
            }
            
            DispatchQueue.main.async {
                
                if let downloadedImage = UIImage(data: data!){
                    self.image.image = downloadedImage
                }
            }
        }).resume()
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("adViewDidReceiveAd")
    }
    
    /// Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView,
                didFailToReceiveAdWithError error: GADRequestError) {
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    /// Tells the delegate that a full-screen view will be presented in response
    /// to the user clicking on an ad.
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("adViewWillPresentScreen")
    }
    
    /// Tells the delegate that the full-screen view will be dismissed.
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("adViewWillDismissScreen")
    }
    
    /// Tells the delegate that the full-screen view has been dismissed.
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("adViewDidDismissScreen")
    }
    
    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        print("adViewWillLeaveApplication")
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
