//
//  FuncoesPublicas.swift
//  Defio
//
//  Created by Anderson Oliveira on 24/04/17.
//  Copyright © 2017 David Camurça. All rights reserved.
//

import Foundation
import UIKit

public func shadow(to layer: CALayer, color: UIColor) {
    
    layer.shadowOpacity = 3.0
    layer.shadowOffset = CGSize(width: 3, height: 3)
    layer.shadowRadius = 5.0
    layer.shadowColor = color.cgColor
}

public func popup(withViewController vc: UIViewController, andTitle t: String?, andBory b: String?, andAction a: ((UIAlertAction) -> Void)?) {
    let alert = UIAlertController(title: t, message: b, preferredStyle: .alert)
    let okAction = UIAlertAction(title: "Ok", style: .default, handler: a)
    
    alert.addAction(okAction)
    
    vc.present(alert, animated: true, completion: nil)
}

public func popupSeletivo(withViewController vc: UIViewController, title t: String?, andBory b: String?, completion: @escaping (_ result: Bool) -> Void) {
    let alert = UIAlertController(title: t, message: b, preferredStyle: .alert)
    let sim = UIAlertAction(title: "Sim", style: .default) { (_) in
        completion(true)
    }
    let nao = UIAlertAction(title: "Não", style: .cancel) { (_) in
        completion(false)
    }
    
    alert.addAction(sim)
    alert.addAction(nao)
    
    vc.present(alert, animated: true, completion: nil)
}

public func getPostString(params: [String:Any]) -> String {
    var data = [String]()
    for(key, value) in params
    {
        data.append(key + "=\(value)")
    }
    return data.map { String($0) }.joined(separator: "&")
}

public func open(byURL url: String, completion: @escaping (Bool) -> Void) {
    
    var urlFormatted = url

    if !url.contains("https://") {
        urlFormatted = "https://" + url
    }
    
    guard let url = URL(string: urlFormatted) else {
        print("problema em salvar url")
        return
    }
    
    if #available(iOS 10.0, *) {
        UIApplication.shared.open(url, options: [:]) { (result) in
            completion(result)
        }
    } else {
        if UIApplication.shared.openURL(url) {
            completion(true)
        }else {
            completion(false)
        }
    }
}

public func animationTF( _ view: UIView) {
    
    UIView.animate(withDuration: 0.3) {
        view.backgroundColor = #colorLiteral(red: 1, green: 0.3215686275, blue: 0.3215686275, alpha: 1)
    }
}

public func isValidEmail(testStr:String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailTest.evaluate(with: testStr)
}

public func isValidPassword(testStr:String) -> Bool {
    let emailRegEx = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*\\W)[A-Za-z\\d\\W]{8,}$"
    
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailTest.evaluate(with: testStr)
}

//Função randomica gerar nomes para as imagens inseridas no Firebase
public func randomStringName(_ length: Int) -> String {
    let letrasMi = "abcdefghijklmnopqrstuvwxyz"
    let letrasMa = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    let numeros = "0123456789"
    
    let alfa: NSString = letrasMi + letrasMa + numeros as NSString
    
    let len = UInt32(alfa.length)
    var stringRandom = ""
    
    for _ in 0 ..< length {
        let rand = arc4random_uniform(len)
        var nextChar = alfa.character(at: Int(rand))
        stringRandom += NSString(characters: &nextChar, length: 1) as String
    }
    
    return stringRandom
    
}
