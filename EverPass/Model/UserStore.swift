//
//  UserStore.swift
//  EverPass
//
//  Created by Anderson Oliveira on 09/07/2018.
//  Copyright © 2018 Anderson Oliveira. All rights reserved.
//

import UIKit

class UserStore {
    
    static let singleton = UserStore()
    
    func register(withUser user: User, completion: @escaping (_ err: Error?, _ user: User?) -> Void) {
        
        let url = URLComponents(string: AppDelegate.urlBase + "/mobile/api/v2/register")!
        
        if let nome = user.nome, let email = user.email, let senha = user.senha {
            let parameters = ["email": email, "name": nome, "password": senha]
            
            var request = URLRequest(url: url.url!)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
            } catch let error {
                completion(error, nil)
            }
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {                                                 // check for fundamental networking error
                    completion(error, nil)
                    return
                }
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 201, httpStatus.statusCode != 200 {           // check for http errors
                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    let error = NSError(domain:"", code:httpStatus.statusCode, userInfo:nil)
                    completion(error, nil)
                    return
                }
                
                do {
                    let jsonSerializer = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    user.token = jsonSerializer!["token"] as? String
                    completion(nil, user)
                } catch {
                    completion(error, nil)
                }
            }
            task.resume()
        }
    }
    
    func login(withUser user: User, completion: @escaping (_ err: Error?, _ user: User?) -> Void) {
        
        let url = URLComponents(string: AppDelegate.urlBase + "/mobile/api/v2/login")!
        
        if let email = user.email, let senha = user.senha {
            let parameters = ["email": email, "password": senha]
            
            var request = URLRequest(url: url.url!)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
            } catch let error {
                completion(error, nil)
            }
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {                                                 // check for fundamental networking error
                    completion(error, nil)
                    return
                }
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 201, httpStatus.statusCode != 200 {           // check for http errors
                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    let error = NSError(domain:"", code:httpStatus.statusCode, userInfo:nil)
                    completion(error, nil)
                    return
                }
                
                do {
                    let jsonSerializer = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    user.token = jsonSerializer!["token"] as? String
                    completion(nil, user)
                } catch {
                    completion(error, nil)
                }
            }
            task.resume()
        }
    }
}
