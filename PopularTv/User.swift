//
//  Movie.swift
//  PopularTv
//
//  Created by Ter, Paul D on 5/6/19.
//  Copyright © 2019 Ter, Paul D. All rights reserved.
//

import Foundation
import UIKit


class User{
    private var username: String = ""
    private var email: String = ""
    private var friends = [String]()
    private var movies = [String]()
    private var userID: String = ""
    
    
    
    
    
    init(username: String, email: String, friends: [String], movies: [String], userID: String) {
        self.username = username
        self.email = email
        self.friends = friends
        self.movies = movies
        self.userID = userID
        
    }
    
    func setFriends(friendArray: [String]){
        self.friends = friendArray
    }
    func setMovies(movieArray: [String]){
        self.movies = movieArray
    }
    
    
    
    
    
    
    
    
    
    
}
