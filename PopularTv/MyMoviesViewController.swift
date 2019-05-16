//
//  MyMoviesViewController.swift
//  PopularTv
//
//  Created by Ter, Paul D on 5/8/19.
//  Copyright © 2019 Ter, Paul D. All rights reserved.
//

import UIKit
import Firebase

class MyMoviesViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var myMovies = [Movie]()
    @IBOutlet weak var myTableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        self.getMyMovies()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.myMovies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let movie = self.myMovies[indexPath.row]
        cell.textLabel?.text = movie.getTitle()
        
        
        return cell
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
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
