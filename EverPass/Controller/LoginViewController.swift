//
//  LoginViewController.swift
//  EverPass
//
//  Created by Anderson Oliveira on 08/07/2018.
//  Copyright © 2018 Anderson Oliveira. All rights reserved.
//

import UIKit
import LocalAuthentication

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
    
    @IBOutlet weak var svTouchID: UIStackView!
    @IBOutlet weak var btTouchID: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Ajustes de auto layout
        self.settingsUI()
        
        //delegate textFields
        self.tfNomeSignUp.delegate = self
        self.tfEmailSignUp.delegate = self
        self.tfSenhaSignUp.delegate = self
        
        self.setupTouchID()
    }
    
    func touchID() {
        //Teste
        let context = LAContext()
        var error: NSError?
        
        // 2
        // check if Touch ID is available
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            // 3
            let reason = "Authenticate with Touch ID"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { (succes, err) in
                if succes {
                    guard let email = AppDelegate.udUser.string(forKey: "email"), let senha = AppDelegate.udUser.string(forKey: "senha") else {
                        self.showAlertController("Problemas ao entrar com o Touch ID, tente usando o e-mail e senha.1")
                        return
                    }
                    let user = User(nome: "", email: email, senha: senha)
                    self.sign(byUser: user)
                }
                else {
                    self.showAlertController("Problemas ao entrar com o Touch ID, tente usando o e-mail e senha.")
                }
            }
        }
    }
    
    func showAlertController(_ message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
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
        
        //baixar teclado
        self.view.endEditing(true)
        
        //Garantindo que nenhum tf vai ser nulo
        if let nome = self.tfNomeSignUp.text, let email = self.tfEmailSignUp.text, let senha = tfSenhaSignUp.text {
            
            //Verificando se os tfs estão vazios, e aplicando uma animação caso esteja
            if status == .entrar {
                if self.isVoid(withIntups: [email, senha], viewsForAnimation: [self.viewEmailSignUp, self.viewSenhaSignUp]) { return }
            } else {
                if self.isVoid(withIntups: [nome, email, senha], viewsForAnimation: [self.viewNomeSignUp, self.viewEmailSignUp, self.viewSenhaSignUp]) { return }
            }
            
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
            
            //Analizando se vai ser Entrar ou Cadastrar
            var user: User!
            if status == .entrar {
                user = User(nome: "", email: email, senha: senha)
            }else {
                user = User(nome: nome, email: email, senha: senha)
            }
            self.sign(byUser: user)
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
            self.svTouchID.isHidden = true
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
            self.setupTouchID()
        }
    }
    
    //Entrar com o TouchID
    @IBAction func touchID(_ sender: UIButton) {
        //baixar teclado
        self.view.endEditing(true)
        
        self.touchID()
    }
    
    //Ajustes de auto layout
    func settingsUI() {
        //Escondendo o campo nome, pois inicialmente ele tem a opcao de fazer login
        self.viewNome.isHidden = true
        
        //Bloqueando a possibilidade de clicar em mais de um botao ao msm tempo
        self.btEntrar.isExclusiveTouch = true
        self.btTouchID.isExclusiveTouch = true
        self.btCadastrar.isExclusiveTouch = true
        self.btEntrarCadastrar.isExclusiveTouch = true
        
        let height = self.view.frame.height
        self.lcLogin.constant = height * 0.068
        self.lblBemVindo.font = self.lblBemVindo.font.withSize(height * 0.045)
        self.lblSubTitulo.font = self.lblSubTitulo.font.withSize(height * 0.03)
    }
    
    //Vereficando se esconde o botao de "Entrar com o Touch ID"
    func setupTouchID() {
        if let isTouchID = AppDelegate.udUser.object(forKey: "touchID") as? Bool, isTouchID {
            self.svTouchID.isHidden = false
        }
    }
    
    //Reset UI do animation TF
    func cleanAnimationTF() {
        self.viewNomeSignUp.backgroundColor = #colorLiteral(red: 0.6303958297, green: 0.7025621533, blue: 0.7372831702, alpha: 1)
        self.viewEmailSignUp.backgroundColor = self.viewNomeSignUp.backgroundColor
        self.viewSenhaSignUp.backgroundColor = self.viewNomeSignUp.backgroundColor
        
        self.lblInfoEmailSignUp.isHidden = true
        self.lblInfoSenhaSignUp.isHidden = true
    }
    
    func sign(byUser user: User) {
        DispatchQueue.main.async {
            self.isWaitingSign(true)
            if user.nome.isEmpty {
                UserStore.singleton.login(withUser: user) { (err, user) in
                    self.completedSign(err, user)
                }
            } else {
                UserStore.singleton.register(withUser: user) { (err, user) in
                    self.completedSign(err, user)
                }
            }
        }
    }
    
    func completedSign(_ err: Error?, _ user: User?) {
        DispatchQueue.main.async {
            self.isWaitingSign(false)
            if err != nil {
                let p = popup(withTitle: "Ops!", andBory: "Ocorreu um problema ao cadastrar-se, por favor verifique as informações prestadas e tente novamente.")
                self.present(p, animated: true, completion: nil)
                return
            }
            
            if let user = user {
                AppDelegate.user = user
                self.verifyNewUserForDevice(byUser: user)
                AppDelegate.udUser.set(user.email, forKey: "email")
                AppDelegate.udUser.set(user.senha, forKey: "senha")
                if AppDelegate.udUser.object(forKey: "touchID") == nil {
                    popupSeletivo(withViewController: self, title: "Touch ID", andBory: "Você gostaria de usar o Tocuh ID para entrar no \"EverPass\"?", completion: { (result) in
                        AppDelegate.udUser.set(result, forKey: "touchID")
                        self.dismiss(animated: true, completion: nil)
                    })
                }else {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    func verifyNewUserForDevice(byUser user: User) {
        var emails = AppDelegate.udUser.array(forKey: "emails") as? [String]
        if emails == nil {
            emails = [user.email]
            AppDelegate.udUser.set(emails, forKey: "emails")
        } else {
            var isExist = false
            emails!.forEach { (email) in
                if email == user.email {
                    isExist = true
                }
            }
            if !isExist {
                emails?.append(user.email)
                AppDelegate.udUser.set(emails, forKey: "emails")
                AppDelegate.udUser.set(nil, forKey: "touchID")
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
        self.btTouchID.isEnabled = !w
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
            self.view.endEditing(true)
        }
        
        return true
    }
}
