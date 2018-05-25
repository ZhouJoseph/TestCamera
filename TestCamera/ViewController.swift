//
//  InfoViewController.swift
//  TestCamera
//
//  Created by 周凯旋 on 5/21/18.
//  Copyright © 2018 Kaixuan Zhou. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var label:UILabel = UILabel(frame: CGRect(x: 100, y: 200, width: 300, height: 40))
    var UTIbutton : UIButton = UIButton(frame:CGRect(x: 100, y: 400, width: 100, height: 50))

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        [label,UTIbutton].forEach{ view.addSubview($0) }

        label.text = "I'm a test label"
        label.font.withSize(35)
        label.anchor(top: view.topAnchor, bottom: nil, leading: view.centerXAnchor, trailing: nil, padding: .init(top: 100, left: 0, bottom: 0, right: 0), size: .init(width: 300, height: 40),centerX: true, centerY: false)

        UTIbutton.setTitle("UTI self test", for: .normal)
        UTIbutton.setTitleColor(UIColor.black, for: .normal)
        UTIbutton.addTarget(self, action: #selector(self.goToUTI(_:)), for: .touchUpInside)
        UTIbutton.anchor(top: view.centerYAnchor, bottom: nil, leading: view.centerXAnchor, trailing: nil, padding: .zero, size: .init(width: 100, height: 40), centerX: true, centerY: true)

    
    }
    

    
    @objc func goToUTI(_ sender: UIButton){
        present(UTIViewController(),animated: true,completion: nil)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


extension UIView{
    func anchor(top: NSLayoutYAxisAnchor?, bottom: NSLayoutYAxisAnchor?, leading: NSLayoutXAxisAnchor?, trailing: NSLayoutXAxisAnchor?, padding: UIEdgeInsets = .zero, size: CGSize = .zero, centerX : Bool = false, centerY : Bool = false){
        
        if size.width != 0 {
            widthAnchor.constraint(equalToConstant: size.width)
        }
        if size.height != 0 {
            heightAnchor.constraint(equalToConstant: size.height)
        }
        
        translatesAutoresizingMaskIntoConstraints = false
        if let top = top {
            if centerY{
                centerYAnchor.constraint(equalTo: top, constant: padding.top).isActive = true
            } else if !centerY {
                topAnchor.constraint(equalTo: top, constant: padding.top).isActive = true
            }
        }
        
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -padding.bottom).isActive = true
        }
        
        if let leading = leading {
            if centerX{
                centerXAnchor.constraint(equalTo: leading, constant: padding.left).isActive = true
            } else if !centerX{
                leadingAnchor.constraint(equalTo: leading, constant: padding.left).isActive = true
            }
        }
        
        if let trailing = trailing{
            trailingAnchor.constraint(equalTo: trailing, constant: -padding.right).isActive = true
            
        }

    }
}
