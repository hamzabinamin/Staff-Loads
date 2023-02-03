//
//  WebViewController.swift
//  Staff Loads
//
//  Created by Hamza Amin on 08/12/2022.
//

import Foundation
import UIKit

extension WebViewController : WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print(message.body)
        let dict = message.body as? Dictionary<String, String>
        print(dict)
        let userdata = UserData((dict?["firstName"])!, (dict?["email"])!, (dict?["lastName"])!)
        if message.name == "sumbitToiOS" {
            self.sumbitToiOS(user: userdata)
        }
    }
}
