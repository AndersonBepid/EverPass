//
//  ChaveCollectionViewCell.swift
//  EverPass
//
//  Created by Anderson Oliveira on 12/07/2018.
//  Copyright © 2018 Anderson Oliveira. All rights reserved.
//

import UIKit

class ChaveCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imgUrl: UIImageView!
    @IBOutlet weak var lblUrl: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    
    var chave: Key? {
        didSet{
            if let chave = chave {
                self.lblUrl.text = chave.url
                self.lblEmail.text = chave.email
            }
        }
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        self.layer.masksToBounds = false
        shadow(to: self.layer, color: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5))
        
    }
}
