//
//  User.swift
//  EverPass
//
//  Created by Anderson Oliveira on 09/07/2018.
//  Copyright © 2018 Anderson Oliveira. All rights reserved.
//

import UIKit

class User: NSObject {
    
    var nome: String?
    var email: String!
    var senha: String!
    
    init(nome: String? = nil, email: String, senha: String) {
        self.nome = nome
        self.email = email
        self.senha = senha
    }
    
    init(withJson result: [String: String]) {
        self.nome = result["name"]
        self.email = result["email"]
    }
}
