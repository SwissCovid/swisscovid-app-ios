/*
 * Created by Ubique Innovation AG
 * https://www.ubique.ch
 * Copyright (c) 2020. All rights reserved.
 */

import UIKit

class NSInformViewController: InformStepViewController {
    static func present(from rootViewController: UIViewController) {
        let informVC: UIViewController

        informVC = NSSendViewController()

        let navCon = NavigationController(rootViewController: informVC)
        
        if UIDevice.current.isSmallScreenPhone {
            navCon.modalPresentationStyle = .fullScreen
        }
        
        rootViewController.present(navCon, animated: true, completion: nil)
    }
}
