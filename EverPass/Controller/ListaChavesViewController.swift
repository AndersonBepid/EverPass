//
//  ViewController.swift
//  EverPass
//
//  Created by Anderson Oliveira on 08/07/2018.
//  Copyright © 2018 Anderson Oliveira. All rights reserved.
//

import UIKit

class ListaChavesViewController: UIViewController {
    
    @IBOutlet weak var btTouchID: UIBarButtonItem!
    @IBOutlet weak var cvChaves: UICollectionView!
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.cvChaves.backgroundColor = .clear
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.user = AppDelegate.user
        self.setupTouchID()
        self.userLogged()
    }
    
    @IBAction func logout(_ sender: UIBarButtonItem) {
        self.showLogin()
    }
    
    @IBAction func touchID(_ sender: UIBarButtonItem) {
        popupSeletivo(withViewController: self, title: "Touch ID", andBory: "Você gostaria de usar o Tocuh ID para entrar no \"EverPass\"?", completion: { (result) in
            AppDelegate.udUser.set(result, forKey: "touchID")
            self.setupTouchID()
        })
    }
    
    func userLogged() {
        
        if let user = self.user {
            print(user.token)
        } else {
            self.showLogin()
        }
    }
    
    func setupTouchID() {
        if AppDelegate.udUser.bool(forKey: "touchID") {
            self.btTouchID.isEnabled = false
            self.btTouchID.tintColor = .clear
        } else {
            self.btTouchID.isEnabled = true
            self.btTouchID.tintColor = .black
        }
    }
    
    func showLogin() {
        DispatchQueue.main.async {
            let vcProfissional: UIViewController
            
            vcProfissional = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "login") as! LoginViewController
            self.present(vcProfissional, animated: true, completion: nil)
        }
    }
}

