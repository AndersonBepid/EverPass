//
//  EverPassTests.swift
//  EverPassTests
//
//  Created by Anderson Oliveira on 08/07/2018.
//  Copyright © 2018 Anderson Oliveira. All rights reserved.
//

import XCTest
@testable import EverPass

class EverPassTests: XCTestCase {
    
    func testSignUp() {
        let user = User(nome: "Anderson Oliveira", email: "anderson@email.com", senha: "Senha@12346")
        
        valid(withEmail: user.email)
        valid(withPassword: user.senha)
        
        UserStore.singleton.register(withUser: user) { (err, user) in
            XCTAssertNotNil(err, (user?.email)!)
            XCTAssertNotNil(user, (user?.email)!)
        }
    }
    
    func testSignIn() {
        let user = User(nome: "Anderson Oliveira", email: "anderson@email.com", senha: "Senha@12346")
        
        //verificando se email e senha estao corretos
        valid(withEmail: user.email)
        valid(withPassword: user.senha)
        
        var u: User?
        let expectation = self.expectation(description: "Logando")
        
        //logando
        UserStore.singleton.login(withUser: user) { (err, user) in
            u = user
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
        
        //verificando se conseguiu se autenticar
        XCTAssertNotNil(u?.token, user.email)
        
        //pegando os sites do Keychain
        self.getSites(byUser: u!)
        
        //salvando um site novo
//        let key = Key(url: "www.netflix.com", email: "anderson.moliveira23@gmail.com", senha: "123456")
//        self.addSite(withKey: key, byUser: u!)
        
        //atualizando um site
//        let key1 = Key(url: "www.netflix.com", email: "anderson.moliveira23@gmail.com", senha: "123456")
//        
//        let key2 = Key(url: "www.twitch.tv", email: "anderson.moliveira23@gmail.com", senha: "123456")
//        self.updateSite(byKey: key1, fromKey: key2, byUser: u!)
        
        //deletando um site novo
//        let key3 = Key(url: "www.defio.com", email: "anderson.moliveira23@gmail.com", senha: "123456")
//        self.removeSite(withKey: key3, byUser: u!)
    }
    
    func testValidEmail() {
        let emails = ["anderson@email.com", "guadalupe@email.com", "teste@email.com"]
        emails.forEach { (e) in
            valid(withEmail: e)
        }
    }
    
    func valid(withEmail e: String) {
        let succes = isValidEmail(testStr: e)
        XCTAssert(succes, e)
    }
    
    func testValidPassword() {
        let passwords = ["Senha@12346", "',|90qw09E", "qwe123{}"]
        passwords.forEach { (p) in
            valid(withPassword: p)
        }
    }
    
    func valid(withPassword p: String) {
        let succes = isValidPassword(testStr: p)
        XCTAssert(succes, p)
    }
    
    func getSites(byUser u: User) {
        
        //pegando os sites no keychain
        KeyStore.singleton.load(byUser: u) { (keys) in
            XCTAssertNotNil(keys, u.email)
            keys.forEach({ (key) in
                //baixando as fotos da API
                self.getImg(byUser: u, andURL: key.url)
            })
        }
    }
    
    func addSite(withKey k: Key, byUser u: User) {
        
        KeyStore.singleton.save(Key: k, byUser: u) { (succes) in
            XCTAssertTrue(succes, u.email)
        }
    }
    
    func removeSite(withKey k: Key, byUser u: User) {
        
        KeyStore.singleton.remove(Key: k, byUser: u) { (succes) in
            XCTAssertTrue(succes, u.email)
        }
    }
    
    func updateSite(byKey k: Key, fromKey k2: Key, byUser u: User) {
        
        KeyStore.singleton.update(byKey: k, fromKey: k2, byUser: u) { (succes) in
            XCTAssertTrue(succes, u.email)
        }
    }
    
    func testGetSites() {
        let user = User(nome: "Anderson Oliveira", email: "anderson@email.com", senha: "Senha@12346")
        getSites(byUser: user)
    }
    
    func getImg(byUser u: User, andURL url: String) {
        
        var i: UIImage?
        let expectation = self.expectation(description: "BaixandoImagens")
        
        KeyStore.singleton.logo(withURL: url, andUser: u) { (err, img) in
            i = img
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertNotNil(i, url)
    }
    
    //Testando se vai conseguir abrir todos os sites de um usuario cadastrado, que possui sites cadastrados
    func testOpenURL() {
        
        let user = User(nome: "Anderson Oliveira", email: "anderson@email.com", senha: "Senha12346")
        KeyStore.singleton.load(byUser: user) { (keys) in
            keys.forEach({ (key) in
                open(byURL: key.url) { (succes) in
                    XCTAssertTrue(succes, key.url)
                }
            })
        }
    }
}
