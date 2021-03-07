//
//  RoundedCornerButton.swift
//  SimplifierApp
//
//  Created by Олеся Мартынюк on 07.03.2021.
//

import UIKit

@IBDesignable
class RoundedCornerButton: UIButton {

    @IBInspectable var cornerRadius: CGFloat = 0{
            didSet{
            self.layer.cornerRadius = cornerRadius
            }
        }

        @IBInspectable var borderWidth: CGFloat = 0{
            didSet{
                self.layer.borderWidth = borderWidth
            }
        }

        @IBInspectable var borderColor: UIColor = UIColor.clear{
            didSet{
                self.layer.borderColor = borderColor.cgColor
            }
        }

}
