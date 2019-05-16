//
//  ViewController.swift
//  PopularTv
//
//  Created by Ter, Paul D on 5/6/19.
//  Copyright © 2019 Ter, Paul D. All rights reserved.
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseDatabase

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource {
    
    var trendingMovies = [Movie]()
    var trendingMovieImageCache = NSCache<AnyObject, AnyObject>()
    
    var myMovies = [Movie]()
    var myMoviesImageCache = NSCache<AnyObject, AnyObject>()
    var friends = [String]()
    var friendMovieIDs  = [String]()
    var watchedBy = [String:Any]()
    @IBOutlet weak var myCollectionView: UICollectionView!
    @IBOutlet weak var myTableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        getTrending()
        getFriends()
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.friendMovieIDs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! HomeTableViewCell
        let id = self.friendMovieIDs[indexPath.row]
        
        Database.database().reference().child("Trending").child(id).observeSingleEvent(of: .value, with: { (snapshot2) in
            if let dict2 = snapshot2.value as? [String:Any]{
                let movieDictionary = dict2 
                let title = movieDictionary["Title"] as! String
                let caption = movieDictionary["Caption"] as! String
                let rank = movieDictionary["Rank"] as! Int
                let id = movieDictionary["ID"] as! String
                let image = movieDictionary["Image"] as! String
                var movie = Movie(Title: title, Caption: caption, Image: image, Rank: rank, ID: id)
                self.myMovies.append(movie)
                cell.caption.text = "Watched by: \(self.watchedBy[id]!) \n \n \(caption)"
                
                    
                
                cell.title.text = title
                if let cachedImage = self.myMoviesImageCache.object(forKey: image as AnyObject)  {
                    cell.movieImage.image =  cachedImage as? UIImage
                    
                }else{
                
                URLSession.shared.dataTask(with: URL(string: image)!, completionHandler: { (data, response, error) in
                    
                    if error != nil {
                        print(error!)
                        return
                    }
                    
                    DispatchQueue.main.async {
                        
                        if let downloadedImage = UIImage(data: data!){
                            self.myMoviesImageCache.setObject(downloadedImage, forKey: image as AnyObject)
                            cell.movieImage.image = downloadedImage
                        }
                    }
                }).resume()
                }
                
                
            }
            
        })
        
       return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.trendingMovies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! HomeCollectionViewCell
        
        
        let movie = self.trendingMovies[indexPath.row]
        cell.title.text = movie.getTitle()
        let imageUrl = movie.getImage()
        
        
        if let cachedImage = self.trendingMovieImageCache.object(forKey: imageUrl as AnyObject)  {
            cell.image.image =  cachedImage as? UIImage
            return cell
        }else{
            URLSession.shared.dataTask(with: URL(string: imageUrl)!, completionHandler: { (data, response, error) in
                
                if error != nil {
                    print(error!)
                    return
                }
                
                DispatchQueue.main.async {
                    
                    if let downloadedImage = UIImage(data: data!){
                        self.trendingMovieImageCache.setObject(downloadedImage, forKey: imageUrl as AnyObject)
                        cell.image.image = downloadedImage
                    }
                }
            }).resume()
            
            return cell

        }
   }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let movie = self.myMovies[indexPath.row]
        
        let detailController = storyboard?.instantiateViewController(withIdentifier: "DetailController") as! DetailController
        
        self.present(detailController, animated: true) {
            detailController.movie = movie
            detailController.caption.text = movie.getCaption()
            
            if let image = self.myMoviesImageCache.object(forKey: movie.getImage() as AnyObject) as? UIImage{
                detailController.image.image = image
            }else{
                detailController.image.image = UIImage()
            }
        }
        
       
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movie = self.trendingMovies[indexPath.row]
        let detailController = storyboard?.instantiateViewController(withIdentifier: "DetailController") as! DetailController
        
        
        
        print(movie.getCaption())
        
        present(detailController, animated: true) {
            detailController.caption.text = movie.getCaption()
            detailController.movieTitle = movie.getTitle()
            detailController.image.image = self.trendingMovieImageCache.object(forKey: movie.getImage() as AnyObject) as! UIImage
            detailController.movie = movie

        }
        
    }
    

    
    
    func checkIfSignedIn(){
        if( Auth.auth().currentUser == nil){
            let signIn = self.storyboard?.instantiateViewController(withIdentifier: "SignIn") as! SignInViewController
            self.present(signIn, animated: true, completion: nil)
        }
    }
    
    @IBAction func menuPressed(_ sender: Any) {
        
        let alert = UIAlertController(title: "What do you want to do?", message: "", preferredStyle: .actionSheet)
        
        let logout = UIAlertAction(title: "Logout", style: .default) { (action) in
            
            do{
                try Auth.auth().signOut()
                let signIn = self.storyboard?.instantiateViewController(withIdentifier: "SignIn") as! SignInViewController
                self.present(signIn, animated: true, completion: nil)
            }
            catch{
                print(error)
            }
        }
        
        let viewmovies = UIAlertAction(title: "View My Shows", style: .default) { (action) in
            let myMovies = self.storyboard?.instantiateViewController(withIdentifier: "MyMovies") as! MyMoviesViewController
            
            self.present(myMovies, animated: false, completion: nil)
            
        }
        
        
       
        alert.addAction(viewmovies)
        alert.addAction(logout)
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        
        
        self.present(alert, animated: false, completion: nil)
        
        
    }
    func getTrending(){
         let ref = Database.database().reference().child("Trending")
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if  let dict = snapshot.value as? [String:Any]{
                for d in dict.values{
                    let movieDictionary = d as! [String:Any]
                    let title = movieDictionary["Title"] as! String
                    let caption = movieDictionary["Caption"] as! String
                    let rank = movieDictionary["Rank"] as! Int
                    let id = movieDictionary["ID"] as! String
                    let image = movieDictionary["Image"] as! String
                    var movie = Movie(Title: title, Caption: caption, Image: image, Rank: rank, ID: id)
                    
                    self.trendingMovies.append(movie)
                    DispatchQueue.main.async {
                        self.myCollectionView.reloadData()

                        
                    }
                    
                }//close for loop
            }//close if let
        }//close observe
        
        
        
    }//close function
    
    func getFriends(){
        Database.database().reference().child("Users").child(Auth.auth().currentUser?.uid ?? "").observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? [String:Any]{
                let userDictionary = dict 
                
                if let friends = userDictionary["friends"] as? [String]{
                self.friends = friends
                self.getFriendsShows()
                }else{
                    
                }
                
            }
        }
        
    }
    func getFriendsShows(){
        for friend in self.friends{
            Database.database().reference().child("Users").queryOrdered(byChild: "email").queryEqual(toValue: friend).observeSingleEvent(of: .value, with: { (snapshot) in
                if let dict = snapshot.value as? [String:Any]{
                    for d in dict.values{
                        let userDictionary = d as! [String:Any]
                        let movies = userDictionary["mymovies"] as! [String]
                        
                        for m in movies{
                            if(!self.friendMovieIDs.contains(m)){
                                self.friendMovieIDs.append(m)
                                

                            }
                            if(self.watchedBy[m] != nil){
                                var users = self.watchedBy[m] as! [String]
                                users.append(userDictionary["username"] as! String)
                                self.watchedBy[m] = users
                            }else{
                                let un = userDictionary["username"] as! String
                                self.watchedBy[m] = [un]
                            }
                            
                            DispatchQueue.main.async {
                                self.myTableView.reloadData()
                                
                                
                            }
                            
                        }
                        
                      
                        

                    }
                }
            }, withCancel: nil)
        }
        
        
    }
    
    
    func getMyMovies(){
        let ref =  Database.database().reference().child("Users").child(Auth.auth().currentUser?.uid ?? "")
        
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? [String:Any]{
                    let userDictionary = dict 
                    let movies = userDictionary["mymovies"] as! [String]
                
                for id in movies{
                    Database.database().reference().child("Trending").child(id).observeSingleEvent(of: .value, with: { (snapshot2) in
                        if let dict2 = snapshot2.value as? [String:Any]{
                            let movieDictionary = dict2 
                            let title = movieDictionary["Title"] as! String
                            let caption = movieDictionary["Caption"] as! String
                            let rank = movieDictionary["Rank"] as! Int
                            let id = movieDictionary["ID"] as! String
                            let image = movieDictionary["Image"] as! String
                            var movie = Movie(Title: title, Caption: caption, Image: image, Rank: rank, ID: id)
                            
                            
                            self.myMovies.append(movie)
                            DispatchQueue.main.async {
                                self.myTableView.reloadData()
                                
                                
                            }
                        }
                        
                    })
                }
                
            }
        }
        
    }


}

