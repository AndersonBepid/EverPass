//
//  LoginViewController.swift
//  EverPass
//
//  Created by Anderson Oliveira on 08/07/2018.
//  Copyright © 2018 Anderson Oliveira. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var lblBemVindo: UILabel!
    @IBOutlet weak var lblSubTitulo: UILabel!
    
    @IBOutlet weak var viewSegmented: UIView!
    @IBOutlet weak var btEntrar: UIButton!
    @IBOutlet weak var btCadastrar: UIButton!
    
    @IBOutlet weak var viewNome: UIView!
    @IBOutlet weak var viewSignUp: UIView!
    @IBOutlet weak var viewNomeSignUp: UIView!
    @IBOutlet weak var tfNomeSignUp: UITextField!
    @IBOutlet weak var viewEmailSignUp: UIView!
    @IBOutlet weak var tfEmailSignUp: UITextField!
    @IBOutlet weak var lblInfoEmailSignUp: UILabel!
    @IBOutlet weak var viewSenhaSignUp: UIView!
    @IBOutlet weak var imgSenhaSignUp: UIImageView!
    @IBOutlet weak var tfSenhaSignUp: UITextField!
    @IBOutlet weak var lblInfoSenhaSignUp: UILabel!
    @IBOutlet weak var lcLogin: NSLayoutConstraint!
    
    @IBOutlet weak var btEntrarCadastrar: UIButton!
    @IBOutlet weak var aiLogin: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Ajustes de auto layout
        self.settingsUI()
        
        //delegate textFields
        self.tfNomeSignUp.delegate = self
        self.tfEmailSignUp.delegate = self
        self.tfSenhaSignUp.delegate = self
    }
    
    @IBAction func mudarVisibilidade(_ sender: UIButton) {
        let status = visibilidadeStatus(rawValue: sender.tag)!
        
        self.imgSenhaSignUp.image = status == .visivel ? #imageLiteral(resourceName: "lock") : #imageLiteral(resourceName: "unlock")
        self.tfSenhaSignUp.isSecureTextEntry = !self.tfSenhaSignUp.isSecureTextEntry
        sender.tag = status.value()
        self.tfSenhaSignUp.reloadInputViews()
    }
    
    @IBAction func sign(_ sender: UIButton) {
        let status = LoginStatus(rawValue: sender.tag)!
        
        if status == .entrar {
            self.signIn()
        } else {
            self.signUp()
        }
    }
    
    //baixar teclado tocando na view base e dando um swipe pra baixo
    @IBAction func dismissKeyboard(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    //Escolhendo a opcao cadastrar
    @IBAction func scCadastrar(_ sender: UIButton) {
        self.btEntrarCadastrar.tag = sender.tag
        self.cleanAnimationTF()
        sender.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.5, animations: {
            self.viewSegmented.center = sender.center
            self.viewNome.isHidden = false
        }) { (_) in
            self.btEntrarCadastrar.setTitle("Cadastrar", for: .normal)
            self.btEntrar.isUserInteractionEnabled = true
        }
    }
    
    //Escolhendo a opcao entrar
    @IBAction func scEntrar(_ sender: UIButton) {
        self.btEntrarCadastrar.tag = sender.tag
        self.cleanAnimationTF()
        sender.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.5, animations: {
            self.viewSegmented.center = sender.center
            self.viewNome.isHidden = true
        }) { (_) in
            self.btEntrarCadastrar.setTitle("Entrar", for: .normal)
            self.btCadastrar.isUserInteractionEnabled = true
        }
    }
    
    //Ajustes de auto layout
    func settingsUI() {
        //Escondendo o campo nome, pois inicialmente ele tem a opcao de fazer login
        self.viewNome.isHidden = true
        
        //Bloqueando a possibilidade de clicar em mais de um botao ao msm tempo
        self.btEntrar.isExclusiveTouch = true
        self.btCadastrar.isExclusiveTouch = true
        self.btEntrarCadastrar.isExclusiveTouch = true
        
        let height = self.view.frame.height
        self.lcLogin.constant = height * 0.068
        self.lblBemVindo.font = self.lblBemVindo.font.withSize(height * 0.045)
        self.lblSubTitulo.font = self.lblSubTitulo.font.withSize(height * 0.03)
        print(height, self.lblBemVindo.font.pointSize, self.lblSubTitulo.font.pointSize)
    }
    
    //Reset UI do animation TF
    func cleanAnimationTF() {
        self.viewNomeSignUp.backgroundColor = #colorLiteral(red: 0.6303958297, green: 0.7025621533, blue: 0.7372831702, alpha: 1)
        self.viewEmailSignUp.backgroundColor = self.viewNomeSignUp.backgroundColor
        self.viewSenhaSignUp.backgroundColor = self.viewNomeSignUp.backgroundColor
        
        self.lblInfoEmailSignUp.isHidden = true
        self.lblInfoSenhaSignUp.isHidden = true
    }
    
    func signIn() {
        //
        self.view.endEditing(true)
        
        //Garantindo que nenhum tf vai ser nulo
        if let email = self.tfEmailSignUp.text, let senha = tfSenhaSignUp.text {
            
            //Verificando se os tfs estão vazios, e aplicando uma animação caso esteja
            if self.isVoid(withIntups: [email, senha], viewsForAnimation: [self.viewEmailSignUp, self.viewSenhaSignUp]) { return }
            
            //Verificando se o email e valido
            if !isValidEmail(testStr: email) {
                self.lblInfoEmailSignUp.isHidden = false
                return
            }
            
            //Verificando se a senha e valido
            if !isValidPassword(testStr: senha) {
                self.lblInfoSenhaSignUp.isHidden = false
                return
            }
            
            self.isWaitingSign(true)
            let user = User(email: email, senha: senha)
            UserStore.singleton.login(withUser: user) { (err, user) in
                DispatchQueue.main.async {
                    self.isWaitingSign(false)
                    if err != nil {
                        let p = popup(withTitle: "Ops!", andBory: "Ocorreu um problema ao logar, por favor verifique as informações prestadas e tente novamente.")
                        self.present(p, animated: true, completion: nil)
                        return
                    }
                    
                    if let user = user {
                        print(user)
                    }
                }
            }
        }
    }
    
    func signUp() {
        //
        self.view.endEditing(true)
        
        
        //Garantindo que nenhum tf vai ser nulo
        if let nome = self.tfNomeSignUp.text, let email = self.tfEmailSignUp.text, let senha = tfSenhaSignUp.text {
            
            //Verificando se os tfs estão vazios, e aplicando uma animação caso esteja
            if self.isVoid(withIntups: [nome, email, senha], viewsForAnimation: [self.viewNomeSignUp, self.viewEmailSignUp, self.viewSenhaSignUp]) { return }
            
            //Verificando se o email e valido
            if !isValidEmail(testStr: email) {
                self.lblInfoEmailSignUp.isHidden = false
                return
            }
            
            //Verificando se a senha e valido
            if !isValidPassword(testStr: senha) {
                self.lblInfoSenhaSignUp.isHidden = false
                return
            }
            
            self.isWaitingSign(true)
            let user = User(nome: nome, email: email, senha: senha)
            UserStore.singleton.register(withUser: user) { (err, user) in
                DispatchQueue.main.async {
                    self.isWaitingSign(false)
                    if err != nil {
                        let p = popup(withTitle: "Ops!", andBory: "Ocorreu um problema ao cadastrar-se, por favor verifique as informações prestadas e tente novamente.")
                        self.present(p, animated: true, completion: nil)
                        return
                    }
                    
                    if let user = user {
                        print(user)
                    }
                }
            }
        }
    }
    
    func isWaitingSign(_ w: Bool) {
        
        if w {
            self.aiLogin.startAnimating()
        }else {
            self.aiLogin.stopAnimating()
        }
        self.btEntrarCadastrar.isEnabled = !w
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

extension LoginViewController: UITextFieldDelegate {
    
    //Reset UI do animation TF
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.cleanAnimationTF()
    }
    
    //Ajustes do botão return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == self.tfNomeSignUp {
            self.tfEmailSignUp.becomeFirstResponder()
        }else if textField == self.tfEmailSignUp {
            self.tfSenhaSignUp.becomeFirstResponder()
        }else {
            self.signUp()
        }
        
        return true
    }
}
