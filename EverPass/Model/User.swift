//
//  User.swift
//  EverPass
//
//  Created by Anderson Oliveira on 09/07/2018.
//  Copyright © 2018 Anderson Oliveira. All rights reserved.
//

import UIKit

class User: NSObject {
    
    var nome: String!
    var email: String!
    var senha: String!
    var token: String?
    
    init(nome: String, email: String, senha: String) {
        self.nome = nome
        self.email = email
        self.senha = senha
    }
    
    override var description: String {
        return "Nome: " + self.nome!
    }
}
