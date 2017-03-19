//
//  User.swift
//  Roket
//
//  Created by Rui Ong on 17/03/2017.
//  Copyright © 2017 Rui Ong. All rights reserved.
//

import Foundation

class User {
    
    var username : String?
    var email : String?
    var uid : String = ""
    var ppUrl : URL?
    
    init(){}
    
    init(withDictionary dictionary: [String: Any]) {
        username = dictionary["username"] as? String
        email = dictionary["email"] as? String
        
        if let displayPicture = dictionary["profilePicURL"] as? String{
            
            ppUrl = URL(string: displayPicture)
        }
    }

}
