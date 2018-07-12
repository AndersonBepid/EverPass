//
//  DetalhesViewController.swift
//  EverPass
//
//  Created by Anderson Oliveira on 12/07/2018.
//  Copyright © 2018 Anderson Oliveira. All rights reserved.
//

import UIKit

class DetalhesViewController: UIViewController {
    
    @IBOutlet weak var btCopy: UIBarButtonItem!
    
    @IBOutlet weak var imgUrl: UIImageView!
    @IBOutlet weak var viewUrl: UIView!
    @IBOutlet weak var tfUrl: UITextField!
    @IBOutlet weak var viewEmail: UIView!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var viewSenha: UIView!
    @IBOutlet weak var imgSenha: UIImageView!
    @IBOutlet weak var tfSenha: UITextField!
    @IBOutlet weak var lblInfoSenhaCopiada: UILabel!
    @IBOutlet weak var lcLogin: NSLayoutConstraint!
    
    @IBOutlet weak var btMudarVisualizacao: UIButton!
    
    let user = AppDelegate.user
    var chave: Key!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Passando os valores da chave para os textFields
        self.tfUrl.text = self.chave.url
        self.tfEmail.text = self.chave.email
        self.tfSenha.text = self.chave.senha
        
        if let url = self.tfUrl.text, !url.isEmpty, let user = self.user {
            self.getImgUrl(byUrl: url, user: user)
        }
        
        //Ajustes de auto layout
        self.settingsUI()
        
        //delegate textFields
        self.tfUrl.delegate = self
        self.tfEmail.delegate = self
        self.tfSenha.delegate = self
    }
    
    @IBAction func dismissKeyboard(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    @IBAction func copiarSenha(_ sender: UIBarButtonItem) {
        guard let senha = self.tfSenha.text else {
            popup(withViewController: self, andTitle: "Copiar", andBory: "Não foi possível copiar a senha para a área de transferência.", andAction: nil)
            return
        }
        
        if senha.isEmpty {
            popup(withViewController: self, andTitle: "Copiar", andBory: "Não foi possível copiar a senha para a área de transferência.", andAction: nil)
        }else {
            UIPasteboard.general.string = senha
            self.lblInfoSenhaCopiada.isHidden = false
            
            //Dispara um trecho de codigo apos X sec
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.lblInfoSenhaCopiada.isHidden = true
            }
        }
    }
    
    
    @IBAction func mudarVisibilidade(_ sender: UIButton) {
        let status = visibilidadeStatus(rawValue: sender.tag)!
        
        self.imgSenha.image = status == .visivel ? #imageLiteral(resourceName: "lockIn") : #imageLiteral(resourceName: "unlockIn")
        self.tfSenha.isSecureTextEntry = !self.tfSenha.isSecureTextEntry
        sender.tag = status.value()
        self.tfSenha.reloadInputViews()
    }
    
    @IBAction func editandoSenha(_ sender: UITextField) {
        guard let senha = sender.text else { return }
        
        self.btCopy.isEnabled = senha.isEmpty ? false : true
    }
    
    @IBAction func update(_ sender: UIBarButtonItem) {
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
            let account = self.chave.url + "/" + self.chave.email
            let cAccount = chave.url + "/" + chave.email
            KeyStore.singleton.update(byService: user.email, andOldAccount: account, andCurrentAccount: cAccount, andKey: chave, completion: { (result) in
                if result {
                    popup(withViewController: self, andTitle: chave.url, andBory: "Atualizado com sucesso!") { (_) in
                        self.navigationController?.popViewController(animated: true)
                    }
                }else {
                    popup(withViewController: self, andTitle: chave.url, andBory: "Houve um problema em salvar esse site, verifique se as informações prestadas já estão salvas, ou tente novamente mais tarde.", andAction: nil)
                }
            })
        }
    }
    
    @IBAction func remove(_ sender: UIBarButtonItem) {
        popupSeletivo(withViewController: self, title: "Excluir", andBory: "Você tem certeza que deseja excluir?") { (result) in
            if result {
                guard let user = self.user else {
                    return
                }
                let account = self.chave.url + "/" + self.chave.email
                KeyStore.singleton.remove(byAccount: account, andService: user.email, andKey: self.chave, completion: { (result) in
                    if result {
                        popup(withViewController: self, andTitle: "Site", andBory: "Excluído com sucesso!") { (_) in
                            self.navigationController?.popViewController(animated: true)
                        }
                    }else {
                        popup(withViewController: self, andTitle: "Ops!", andBory: "Houve um erro inesperado, por favor, tente novamente mais tarde.", andAction: nil)
                    }
                })
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
    
    func getImgUrl(byUrl url: String, user: User) {
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

extension DetalhesViewController: UITextFieldDelegate {
    
    //Reset UI do animation TF
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.cleanAnimationTF()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.tfUrl {
            if let url = textField.text, let user = self.user {
                self.getImgUrl(byUrl: url, user: user)
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
