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
    @IBOutlet weak var aiChave: UIActivityIndicatorView!
    @IBOutlet weak var lblInfoSemResultado: UILabel!
    
    var user: User?
    var chaves: [Key] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.cvChaves.backgroundColor = .clear
        self.cvChaves.isExclusiveTouch = true
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
    
    //Verifica se tem algum usuario logado
    func userLogged() {
        if let user = self.user {
            self.getChaves(byUser: user)
        } else {
            self.showLogin()
        }
    }
    
    //
    func getChaves(byUser user: User) {
        self.aiChave.startAnimating()
        KeyStore.singleton.load(byUser: user, completion: { (chaves) in
            if chaves.isEmpty {
                self.chaves = []
                self.lblInfoSemResultado.isHidden = false
            }else {
                self.chaves = chaves
                self.lblInfoSemResultado.isHidden = true
            }
        })
        
        self.cvChaves.reloadData()
        self.aiChave.stopAnimating()
    }
    
    //Verificando se o Touch Id foi altorizado, caso tenha sido, esconde a opcao de configurar
    func setupTouchID() {
        if AppDelegate.udUser.bool(forKey: "touchID") {
            self.btTouchID.isEnabled = false
            self.btTouchID.tintColor = .clear
        } else {
            self.btTouchID.isEnabled = true
            self.btTouchID.tintColor = .black
        }
    }
    
    //Chama a Tela de login
    func showLogin() {
        DispatchQueue.main.async {
            let vcProfissional: UIViewController
            
            vcProfissional = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "login") as! LoginViewController
            self.present(vcProfissional, animated: true, completion: nil)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            let detailVC = segue.destination as! DetalhesViewController
            let chave = sender as! Key
            detailVC.chave = chave
        }
    }
}

extension ListaChavesViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.chaves.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ChaveCollectionViewCell
        let chave = self.chaves[indexPath.item]
        
        cell.chave = chave
        
        //View de animação de espera do download image
        let viewWaiting = UIView(frame: cell.imgUrl.frame)
        viewWaiting.backgroundColor = #colorLiteral(red: 0.1294117647, green: 0.1647058824, blue: 0.1921568627, alpha: 0.8)
        let aiImg = UIActivityIndicatorView(activityIndicatorStyle: .white)
        aiImg.startAnimating()
        aiImg.color = #colorLiteral(red: 0.9921568627, green: 0.7921568627, blue: 0.1843137255, alpha: 1)
        
        //Add o ActivityIndicator na View, e a View na Image
        aiImg.center = viewWaiting.center
        viewWaiting.addSubview(aiImg)
        cell.imgUrl.addSubview(viewWaiting)
        
        //Fazendo o download da imagem
        KeyStore.singleton.logo(withURL: chave.url, andUser: self.user!) { (err, img) in
            
            //Movendo esse trecho para uma thread secundaria, para nao comprometer o fluxo do app
            DispatchQueue.main.async {
                if err != nil {
                    print(err?.localizedDescription ?? "Erro não identificado")
                    cell.imgUrl.image = nil
                }
                
                if let img = img {
                    
                    //Recebendo a imagem e removendo a view de animação
                    cell.imgUrl.image = img
                    viewWaiting.removeFromSuperview()
                }
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let chave = self.chaves[indexPath.item]
        self.performSegue(withIdentifier: "showDetail", sender: chave)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //Mantendo as celulas da colection sempre com margem de 20pt da laterais
        let size = (self.view.frame.width - 40)
        return CGSize(width: size, height: 70)
    }
}
