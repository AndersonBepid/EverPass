//
//  EverPassUITests.swift
//  EverPassUITests
//
//  Created by Anderson Oliveira on 08/07/2018.
//  Copyright © 2018 Anderson Oliveira. All rights reserved.
//

import XCTest

class EverPassUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        
        let app = XCUIApplication()
        
        app.textFields["E-mail"].tap()
        let email = "anderson@email.com"
        email.forEach { (c) in
            let letra = String(c)
            app.keys[letra].tap()
        }
        
        app.secureTextFields["Senha"].tap()
        app/*@START_MENU_TOKEN@*/.buttons["shift"]/*[[".keyboards.buttons[\"shift\"]",".buttons[\"shift\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.keys["S"].tap()
        let senha = "enha"
        senha.forEach { (c) in
            let letra = String(c)
            app.keys[letra].tap()
        }
        
        app.keys["more"].tap()
        let senha2 = "@12346"
        senha2.forEach { (c) in
            let letra = String(c)
            app.keys[letra].tap()
        }
        
        app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 1).children(matching: .other).element(boundBy: 0).children(matching: .other).element(boundBy: 3).buttons["Entrar"].tap()
        
        let sitesNavigationBar = app.navigationBars["Sites"]
        let itemButton = sitesNavigationBar.children(matching: .button).matching(identifier: "Item").element(boundBy: 2)
        itemButton.tap()
        
        app.textFields["URL"].tap()
        let url = "www.cedrotech.com"
        url.forEach { (c) in
            let letra = String(c)
            app.keys[letra].tap()
        }
        
        app.textFields["Usuário/E-mail"].tap()
        let user = "andersoncedrense"
        user.forEach { (c) in
            let letra = String(c)
            app.keys[letra].tap()
        }
        
        app.secureTextFields["Senha"].tap()
        let senha3 = "qwerty"
        senha3.forEach { (c) in
            let letra = String(c)
            app.keys[letra].tap()
        }
        
        
        let itemButton2 = app.navigationBars["Adicionar site"].children(matching: .button).matching(identifier: "Item").element(boundBy: 1)
        itemButton2.tap()
        app.alerts["www.cedrotech.com"].buttons["Ok"].tap()
        
    }
    
}
