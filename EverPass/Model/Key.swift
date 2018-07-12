//
//  Chave.swift
//  EverPass
//
//  Created by Anderson Oliveira on 11/07/2018.
//  Copyright © 2018 Anderson Oliveira. All rights reserved.
//

import UIKit

class Key: NSObject, NSCoding {
    
    var url: String!
    var email: String!
    var senha: String!
    
    convenience init(url: String, email: String, senha: String) {
        self.init()
        self.url = url
        self.email = email
        self.senha = senha
    }
    
    required convenience init(coder decoder: NSCoder) {
        self.init()
        self.url = decoder.decodeObject(forKey: "url") as? String
        self.email = decoder.decodeObject(forKey: "email") as! String
        self.senha = decoder.decodeObject(forKey: "senha") as! String
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(url, forKey: "url")
        aCoder.encode(email, forKey: "email")
        aCoder.encode(senha, forKey: "senha")
    }
    
    override var description: String {
        return "E-mail: " + self.email + "Senha: " + self.senha
    }
}
