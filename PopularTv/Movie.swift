//
//  Movie.swift
//  PopularTv
//
//  Created by Ter, Paul D on 5/6/19.
//  Copyright © 2019 Ter, Paul D. All rights reserved.
//

import Foundation
import UIKit


class Movie{
    private var title: String = ""
    private var caption: String = ""
    private var image: String = ""
    private var rank = 0
    private var id: String = ""

    

    init(){
        
    }
    
    
    init(Title: String, Caption: String, Image: String, Rank: Int, ID: String) {
        self.title = Title
        self.caption = Caption
        self.image = Image
        self.rank = Rank
        self.id = ID

    }
    
    func getTitle() -> String {
        
        return self.title
    }
    func getRank() -> Int {
        
        return self.rank
    }
    func getId() -> String {
        
        return self.id
    }
    func getCaption() -> String {
        
        return self.caption
    }
    func getImage() -> String {
        
        return self.image
    }
    
    func toString() -> String{
        return "Title: \(self.title)  \n Caption: \(self.caption) \n Image URL: \(self.image)"
    }
    
    
    
    
    
    
    
    
    
    
    
}
