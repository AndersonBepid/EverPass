//
//  KeyStore.swift
//  EverPass
//
//  Created by Anderson Oliveira on 12/07/2018.
//  Copyright © 2018 Anderson Oliveira. All rights reserved.
//

import UIKit

let kSecClassValue = NSString(format: kSecClass)
let kSecAttrAccountValue = NSString(format: kSecAttrAccount)
let kSecValueDataValue = NSString(format: kSecValueData)
let kSecClassGenericPasswordValue = NSString(format: kSecClassGenericPassword)
let kSecAttrServiceValue = NSString(format: kSecAttrService)
let kSecMatchLimitValue = NSString(format: kSecMatchLimit)
let kSecReturnDataValue = NSString(format: kSecReturnData)
let kSecMatchLimitOneValue = NSString(format: kSecMatchLimitOne)

class KeyStore {
    
    static let singleton = KeyStore()
    let imageCache = NSCache<NSString, UIImage>()

    
    func update(byKey key: Key, fromKey cKey: Key, byUser user: User, completion: (Bool) -> Void) {
        let service = user.email!
        let account = key.url + "/" + key.email
        let cAccount = cKey.url + "/" + cKey.email

        let keyData = NSKeyedArchiver.archivedData(withRootObject: cKey)
        
        let keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPasswordValue, service, account], forKeys: [kSecClassValue, kSecAttrServiceValue, kSecAttrAccountValue])
        
        let status = SecItemUpdate(keychainQuery as CFDictionary, [kSecValueDataValue: keyData, kSecAttrAccountValue: cAccount] as CFDictionary)
        
        if (status != errSecSuccess) {
            if let err = SecCopyErrorMessageString(status, nil) {
                print("Read failed: \(err)")
            }
            completion(false)
        }else {
            completion(true)
        }
    }
    
    
    func remove(Key key: Key, byUser user: User, completion: (Bool) -> Void) {
        let service = user.email!
        let account = key.url + "/" + key.email
        
        let keyData = NSKeyedArchiver.archivedData(withRootObject: key)
        
        let keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPasswordValue, service, account, keyData], forKeys: [kSecClassValue, kSecAttrServiceValue, kSecAttrAccountValue, kSecValueDataValue])
        
        let status = SecItemDelete(keychainQuery as CFDictionary)
        
        if (status != errSecSuccess) {
            if let err = SecCopyErrorMessageString(status, nil) {
                print("Write failed: \(err)")
            }
            completion(false)
        }else {
            completion(true)
        }
    }
    
    
    func save(Key key: Key, byUser user: User, completion: (Bool) -> Void) {
        let service = user.email!
        let account = key.url + "/" + key.email
        
        let keyData = NSKeyedArchiver.archivedData(withRootObject: key)
        
        let keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPasswordValue, service, account, keyData], forKeys: [kSecClassValue, kSecAttrServiceValue, kSecAttrAccountValue, kSecValueDataValue])
        
        let status = SecItemAdd(keychainQuery as CFDictionary, nil)
        
        if (status != errSecSuccess) {
            if let err = SecCopyErrorMessageString(status, nil) {
                print("Write failed: \(err)")
            }
            completion(false)
        }else {
            completion(true)
        }
    }
    
    func load(byUser user: User, completion: (_ chaves: [Key]) -> Void) {
        
        let service = user.email!
        let keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPasswordValue, service, kCFBooleanTrue, kSecMatchLimitAll], forKeys: [kSecClassValue, kSecAttrServiceValue, kSecReturnDataValue, kSecMatchLimitValue])
        
        var dataTypeRef :AnyObject?
        
        let status: OSStatus = SecItemCopyMatching(keychainQuery, &dataTypeRef)
        var keys: [Key] = []
        
        if status == errSecSuccess {
            if let retrievedDatas = dataTypeRef as? [Data] {
                retrievedDatas.forEach { (retrievedData) in
                    let key = NSKeyedUnarchiver.unarchiveObject(with: retrievedData) as! Key
                    keys.append(key)
                }
                
            }
            completion(keys)
        } else {
            print("Nothing was retrieved from the keychain. Status code \(status)")
            completion(keys)
        }
    }
    
    func logo(withURL urlKey: String, andUser user: User, completion: @escaping (_ err: Error?, _ img: UIImage?) -> Void) {
        
        //Verificando se está no cache
        if let img = imageCache.object(forKey: urlKey as NSString) {
            completion(nil, img)
            return
        }
        
        let url = URLComponents(string: AppDelegate.urlBase + "/mobile/api/v2/logo/" + urlKey)!
        
        if let token = user.token {
            var request = URLRequest(url: url.url!)
            request.setValue(token, forHTTPHeaderField: "authorization")
            request.httpMethod = "GET"
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    completion(error, nil)
                    return
                }
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 201, httpStatus.statusCode != 200 {
                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    print(response?.description ?? "Problema em ler o response")
                    let error = NSError(domain:"", code:httpStatus.statusCode, userInfo:nil)
                    completion(error, nil)
                    return
                }
                
                if let img = UIImage(data: data, scale: 1.0) {
                    //guardando imagem em cache
                    self.imageCache.setObject(img, forKey: urlKey as NSString)
                    completion(nil, img)
                }else {
                    completion(nil, nil)
                }
            }
            task.resume()
        }
    }
}
