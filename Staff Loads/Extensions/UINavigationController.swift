//
//  UINavigationController.swift
//  Staff Loads
//
//  Created by Hamza Amin on 03/02/2023.
//

import Foundation
import UIKit

extension UINavigationController {
    override open func viewDidLoad() {
        super.viewDidLoad()
        let standard = UINavigationBarAppearance()
        standard.backgroundColor = UIColor(rgb: 0x00B0F0)
        standard.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        standard.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
    
        let compact = UINavigationBarAppearance()
        compact.backgroundColor = UIColor(rgb: 0x00B0F0)
        compact.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        compact.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
    
        let scrollEdge = UINavigationBarAppearance()
        scrollEdge.backgroundColor = UIColor(rgb: 0x00B0F0)
        scrollEdge.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        scrollEdge.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        
        navigationBar.standardAppearance = standard
        navigationBar.compactAppearance = compact
        navigationBar.scrollEdgeAppearance = scrollEdge
    }
    
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        navigationBar.topItem?.backButtonDisplayMode = .minimal
    }

}
