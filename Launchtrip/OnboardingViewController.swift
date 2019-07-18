//
//  OnboardingViewController.swift
//  Launchtrip
//
//  Created by Drew Sen on 2019-06-26.
//  Copyright © 2019 Drew Sen. All rights reserved.
//

import UIKit
import paper_onboarding
import SurveyNative
import SPStorkController

class OnboardingViewController: SurveyViewController, SurveyAnswerDelegate, CustomConditionDelegate, ValidationFailedDelegate  {

    
    let navBar = SPFakeBarView(style: .stork)
    var lightStatusBar: Bool = false
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.lightStatusBar ? .lightContent : .default
    }


    fileprivate let items = [
        OnboardingItemInfo(informationImage: Asset.hotels.image,
                           title: "Hotels",
                           description: "All hotels and hostels are sorted by hospitality rating",
                           pageIcon: Asset.key.image,
                           color: UIColor(red: 0.40, green: 0.56, blue: 0.71, alpha: 1.00),
                           titleColor: UIColor.white, descriptionColor: UIColor.white, titleFont: titleFont, descriptionFont: descriptionFont),
        
        OnboardingItemInfo(informationImage: Asset.banks.image,
                           title: "Banks",
                           description: "We carefully verify all banks before add them into the app",
                           pageIcon: Asset.wallet.image,
                           color: UIColor(red: 0.40, green: 0.69, blue: 0.71, alpha: 1.00),
                           titleColor: UIColor.white, descriptionColor: UIColor.white, titleFont: titleFont, descriptionFont: descriptionFont),
        
        OnboardingItemInfo(informationImage: Asset.stores.image,
                           title: "Stores",
                           description: "All local stores are categorized for your convenience",
                           pageIcon: Asset.shoppingCart.image,
                           color: UIColor(red: 0.61, green: 0.56, blue: 0.74, alpha: 1.00),
                           titleColor: UIColor.white, descriptionColor: UIColor.white, titleFont: titleFont, descriptionFont: descriptionFont),
        
        ]


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setSurveyAnswerDelegate(self)
        self.setCustomConditionDelegate(self)
        self.setValidationFailedDelegate(self)
        
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isBeingDismissed{
            // TODO: Do your stuff here.
            print("Onboarding view is being dismissed")

            let viewControllerStoryboardId = "EventSearchViewController"
            let storyboardName = "Main"
            let storyboard = UIStoryboard(name: storyboardName, bundle: Bundle.main)
            guard let eventSearchViewController = storyboard.instantiateViewController(withIdentifier: viewControllerStoryboardId) as UIViewController? else { return }
            
            //Change view to a thank you here
//            self.presentingViewController?.view = true
            self.presentingViewController?.present(eventSearchViewController, animated: false, completion: nil)
            print("Showing event search view in top most controller")

        }

    }
    
    
    private func setupPaperOnboardingView() {
        let onboarding = PaperOnboarding()
        onboarding.delegate = self
        onboarding.dataSource = self
        onboarding.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(onboarding)
        
        // Add constraints
        for attribute: NSLayoutConstraint.Attribute in [.left, .right, .top, .bottom] {
            let constraint = NSLayoutConstraint(item: onboarding,
                                                attribute: attribute,
                                                relatedBy: .equal,
                                                toItem: view,
                                                attribute: attribute,
                                                multiplier: 1,
                                                constant: 0)
            view.addConstraint(constraint)
        }
    }
    
    override func surveyJsonFile() -> String {
        return "ExampleQuestions"
    }
    
    override func surveyTitle() -> String {
        return "Launchtrip Survey"
    }
    
    func question(for id: String, answer: Any) {
        print("Question: \(id) has answer (maybe is complete): \(answer)")
        if (surveyQuestions!.isQuestionFullyAnswered(id)) {
            print("Question: \(id) is complete")
        }
    }
    
    func isConditionMet(answers: [String: Any], extra: [String: Any]?) -> Bool {
        let id = extra!["id"] as! String
        if id == "check_age" {
            if let birthYearStr = answers["birthyear"] as? String, let ageStr = answers["age"] as? String {
                let birthYear = Int(birthYearStr)
                let age = Int(ageStr)
                let wiggleRoom = extra!["wiggle_room"] as? Int
                let date = Date()
                let calendar = Calendar.current
                let components = calendar.dateComponents([.year], from: date)
                let currentYear =  components.year
                return abs(birthYear! + age! - currentYear!) > wiggleRoom!
            } else {
                return false
            }
        } else {
            Logger.log("Unknown custom condition check: \(id)")
            return false
        }
    }
    
    func validationFailed(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func getTopMostViewController() -> UIViewController? {
        var topMostViewController = UIApplication.shared.keyWindow?.rootViewController
        
        while let presentedViewController = topMostViewController?.presentedViewController {
            topMostViewController = presentedViewController
        }
        
        return topMostViewController
    }
    
    @objc func dismissAction() {
        SPStorkController.dismissWithConfirmation(controller: self, completion: nil)
    }



}


extension OnboardingViewController: SPStorkControllerConfirmDelegate {
    
    var needConfirm: Bool {
        return true
    }
    
    func confirm(_ completion: @escaping (Bool) -> ()) {
        let alertController = UIAlertController(title: "Need dismiss?", message: "It test confirm option for SPStorkController", preferredStyle: .actionSheet)
        print(#function)
        //        alertController.addDestructiveAction(title: "Confirm", complection: {
        //            completion(true)
        //        })
        //        alertController.addCancelAction(title: "Cancel") {
        //            completion(false)
        //        }
        //        self.present(alertController)
    }
}


//MARK: Extensions
private extension OnboardingViewController {
    
    static let titleFont = UIFont(name: "Nunito-Bold", size: 36.0) ?? UIFont.boldSystemFont(ofSize: 36.0)
    static let descriptionFont = UIFont(name: "OpenSans-Regular", size: 14.0) ?? UIFont.systemFont(ofSize: 14.0)
}

