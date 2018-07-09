//
//  Enum.swift
//  EverPass
//
//  Created by Anderson Oliveira on 08/07/2018.
//  Copyright © 2018 Anderson Oliveira. All rights reserved.
//

import UIKit

enum LoginStatus: Int {
    case entrar, cadastrar
}

enum visibilidadeStatus: Int {
    case visivel, invisivel
    
    func value() -> Int {
        
        switch self {
        case .visivel:
            return 1
        case .invisivel:
            return 0
        }
    }
}
