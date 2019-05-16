//
//  SearchViewController.swift
//  PopularTv
//
//  Created by Ter, Paul D on 5/6/19.
//  Copyright © 2019 Ter, Paul D. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase

class SearchViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate {
    
    @IBOutlet weak var searchShowsButton: UIButton!
    @IBOutlet weak var searchFriendsButton: UIButton!
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var mySearchBar: UISearchBar!
    var trendingMovies = [Movie]()
    var trendingMovieImageCache = NSCache<AnyObject, AnyObject>()

    var users = [[String:Any]]()
    

    
    var searchFor = "shows"
    
    override func viewWillAppear(_ animated: Bool) {
        getTrending()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.resignFirstResponder()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if(self.searchFor == "shows"){
            self.trendingMovies = [Movie]()
            self.myTableView.reloadData()
            self.searchForShows(title: searchText)
        }else{
        self.trendingMovies = [Movie]()
        self.users = [[String:Any]]()
        searchForUser(username: searchText)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(searchFor == "friends"){
            return self.users.count
        }
        return self.trendingMovies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if(self.searchFor == "friends"){
            let user = self.users[indexPath.row]
            cell.textLabel?.text = user["username"] as! String
            cell.detailTextLabel?.text = user["email"] as! String
            return cell
        }
        
        let movie = self.trendingMovies[indexPath.row]
        cell.textLabel?.text = movie.getTitle()
        cell.detailTextLabel?.text = movie.getCaption()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(self.searchFor == "shows"){
            let show = self.trendingMovies[indexPath.row]
            print("Clicked show: \(show.getTitle())")
            print("image url is: \(show.getImage())")
            
            let detailController = storyboard?.instantiateViewController(withIdentifier: "DetailController") as! DetailController
            
            self.present(detailController, animated: true) {
                detailController.movie = show
                detailController.caption.text = show.getCaption()
                URLSession.shared.dataTask(with: URL(string: show.getImage())!, completionHandler: { (data, response, error) in
                    
                    if error != nil {
                        print(error!)
                        return
                    }
                    
                    DispatchQueue.main.async {
                        
                        if let downloadedImage = UIImage(data: data!){
                            detailController.image.image = downloadedImage
                        }
                    }
                }).resume()
                
                
            }

        }
        
        
        if(self.searchFor == "friends"){
            let email = self.users[indexPath.row]["email"] as! String
            print(email)
            
            
            let ref =  Database.database().reference().child("Users").child(Auth.auth().currentUser?.uid ?? "")
            
            ref.observeSingleEvent(of: .value) { (snapshot) in
                if let dict = snapshot.value as? [String:Any]{
                    let userDictionary = dict 
                    
                    if(userDictionary["friends"] == nil){
                        var friends = [email]
                        Database.database().reference().child("Users").child((Auth.auth().currentUser?.uid)!).updateChildValues(["friends":friends])
                        return
                    }
                    var friends = userDictionary["friends"] as! [String]
                    
                    
                    if(!friends.contains(email ?? "")){
                        friends.append(email ?? "")
                    }
                    Database.database().reference().child("Users").child((Auth.auth().currentUser?.uid)!).updateChildValues(["friends":friends])
                    
                    self.users = [[String:Any]]()
                    self.myTableView.reloadData()
                    let alertController = UIAlertController(title: "Added Friend", message: "", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Ok", style: .destructive, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                    
                    
                    
                }
            }
            
            
        }
        
        
        
        
        
        
        
        
    }


    
    
    func getTrending(){
        let ref = Database.database().reference().child("Trending").queryOrdered(byChild: "Title").queryStarting(atValue: "A").observeSingleEvent(of: .value) { (snapshot) in
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
                        
                        self.myTableView.reloadData()
                        
                        
                    }
                    
                }//close for loop
            }//close if let
        }//close observe
        
        
        
    }//close function

    func searchForUser(username: String){
        print("in search user")
        self.users = [[String:Any]]()
        let ref = Database.database().reference().child("Users")
        ref.queryOrdered(byChild: "username").queryEqual(toValue: username)
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? [String:Any]{
                for d in dict.values{
                    let userDictionary = d as! [String:Any]
                    if((userDictionary["username"] as! String).uppercased() == username.uppercased() || (userDictionary["email"] as! String).uppercased() == username.uppercased() ){
                        self.users.append(userDictionary)
                        DispatchQueue.main.async {
                            self.myTableView.reloadData()
                            
                            
                        }
                    }
                    
                    
                }
            }
        }
    }
    func searchForShows(title: String){
        print("in search shows")
        self.trendingMovies = [Movie]()
        let ref = Database.database().reference().child("Trending")
        ref.queryOrdered(byChild: "Title").queryEqual(toValue: title)
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? [String:Any]{
                for d in dict.values{
                    let movieDictionary = d as! [String:Any]
                    if((movieDictionary["Title"] as! String).uppercased() == title.uppercased()  ){
                        let title = movieDictionary["Title"] as! String
                        let caption = movieDictionary["Caption"] as! String
                        let rank = movieDictionary["Rank"] as! Int
                        let id = movieDictionary["ID"] as! String
                        let image = movieDictionary["Image"] as! String
                        var movie = Movie(Title: title, Caption: caption, Image: image, Rank: rank, ID: id)
                        
                        self.trendingMovies.append(movie)
                        DispatchQueue.main.async {
                            
                            self.myTableView.reloadData()
                            
                            
                        }
                    }
                    
                    
                }
            }
        }
    }
    
    
    
    @IBAction func pressSearchMovies(_ sender: Any) {
        self.mySearchBar.text = ""
        self.mySearchBar.placeholder = "Search Shows"
        self.trendingMovies = [Movie]()
        self.users = [[String:Any]]()
        self.searchFor = "shows"
        self.getTrending()
        self.searchShowsButton.backgroundColor = UIColor.black
        self.searchFriendsButton.backgroundColor = UIColor.clear
        self.myTableView.reloadData()

        

    }
    
    @IBAction func pressSearchForFriends(_ sender: Any) {
        self.mySearchBar.text = ""
        self.trendingMovies = [Movie]()
        self.users = [[String:Any]]()
        self.mySearchBar.placeholder = "Search by username or email"
        self.searchFor = "friends"
        self.searchFriendsButton.backgroundColor = UIColor.black
        self.searchShowsButton.backgroundColor = UIColor.clear
        self.myTableView.reloadData()
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
