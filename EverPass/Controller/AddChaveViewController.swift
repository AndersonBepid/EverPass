//
//  AddChaveViewController.swift
//  EverPass
//
//  Created by Anderson Oliveira on 11/07/2018.
//  Copyright © 2018 Anderson Oliveira. All rights reserved.
//

import UIKit

class AddChaveViewController: UIViewController {
    
    @IBOutlet weak var imgUrl: UIImageView!
    @IBOutlet weak var viewUrl: UIView!
    @IBOutlet weak var tfUrl: UITextField!
    @IBOutlet weak var viewEmail: UIView!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var viewSenha: UIView!
    @IBOutlet weak var imgSenha: UIImageView!
    @IBOutlet weak var tfSenha: UITextField!
    @IBOutlet weak var lcLogin: NSLayoutConstraint!
    
    @IBOutlet weak var btMudarVisualizacao: UIButton!
    
    let user = AppDelegate.user
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Ajustes de auto layout
        self.settingsUI()
        
        //delegate textFields
        self.tfUrl.delegate = self
        self.tfEmail.delegate = self
        self.tfSenha.delegate = self
    }
    
    //baixar teclado tocando na view base e dando um swipe pra baixo
    @IBAction func dismissKeyboard(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    @IBAction func mudarVisibilidade(_ sender: UIButton) {
        let status = visibilidadeStatus(rawValue: sender.tag)!
        
        self.imgSenha.image = status == .visivel ? #imageLiteral(resourceName: "lockIn") : #imageLiteral(resourceName: "unlockIn")
        self.tfSenha.isSecureTextEntry = !self.tfSenha.isSecureTextEntry
        sender.tag = status.value()
        self.tfSenha.reloadInputViews()
    }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        //baixar teclado
        self.view.endEditing(true)
        
        //Garantindo que nenhum tf vai ser nulo
        if let url = self.tfUrl.text, let email = self.tfEmail.text, let senha = tfSenha.text {
            
            //Verificando se os tfs estão vazios, e aplicando uma animação caso esteja
            if self.isVoid(withIntups: [url, email, senha], viewsForAnimation: [self.viewUrl, self.viewEmail, self.viewSenha]) { return }
            
            let chave = Key(url: url, email: email, senha: senha)
            guard let user = self.user else {
                return
            }
            let account = chave.url + "/" + chave.email
            KeyStore.singleton.save(byService: user.email, andAccount: account, andKey: chave)
            popup(withViewController: self, andTitle: chave.url, andBory: "Salvo com sucesso!") { (_) in
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    //Ajustes de auto layout
    func settingsUI() {
        //Bloqueando a possibilidade de clicar em mais de um botao ao msm tempo
        self.btMudarVisualizacao.isExclusiveTouch = true
        
        let height = self.view.frame.height
        self.lcLogin.constant = height * 0.068
    }
    
    //Reset UI do animation TF
    func cleanAnimationTF() {
        self.viewUrl.backgroundColor = #colorLiteral(red: 0.6303958297, green: 0.7025621533, blue: 0.7372831702, alpha: 1)
        self.viewEmail.backgroundColor = self.viewUrl.backgroundColor
        self.viewSenha.backgroundColor = self.viewUrl.backgroundColor
    }
    
    //Verificando se os tfs estão vazios, e aplicando uma animação caso esteja
    func isVoid(withIntups inputs: [String], viewsForAnimation views: [UIView]) -> Bool {
        
        var out = false
        var index = 0
        
        inputs.forEach { (value) in
            if value.isEmpty {
                let view = views[index]
                animationTF(view)
                out = true
            }
            index += 1
        }
        return out
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension AddChaveViewController: UITextFieldDelegate {
    
    //Reset UI do animation TF
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.cleanAnimationTF()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.tfUrl {
            if let url = textField.text, let user = self.user {
                KeyStore.singleton.logo(withURL: url, andUser: user) { (_, img) in
                    
                    //Movendo esse trecho para uma thread secundaria, para nao comprometer o fluxo do app
                    DispatchQueue.main.async {
                        if let img = img {
                            //Recebendo a imagem e removendo a view de animação
                            self.imgUrl.image = img
                        }else {
                            self.imgUrl.image = #imageLiteral(resourceName: "urlIn")
                        }
                    }
                }
            }
        }
    }
    
    //Ajustes do botão return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == self.tfUrl {
            self.tfEmail.becomeFirstResponder()
        }else if textField == self.tfEmail {
            self.tfSenha.becomeFirstResponder()
        }else {
            self.view.endEditing(true)
        }
        
        return true
    }
}
