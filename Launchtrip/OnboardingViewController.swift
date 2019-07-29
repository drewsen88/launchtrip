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
import SwiftEntryKit

class OnboardingViewController: SurveyViewController, SurveyAnswerDelegate, CustomConditionDelegate, ValidationFailedDelegate  {

    
    let navBar = SPFakeBarView(style: .stork)
    var lightStatusBar: Bool = false
    var attributes: EKAttributes? = nil
    
    // Cumputed for the sake of reusability
    var bottomAlertAttributes: EKAttributes {
        var attributes = EKAttributes.bottomFloat
        attributes.hapticFeedbackType = .success
        attributes.displayDuration = .infinity
        attributes.entryBackground = .color(color: .white)
        attributes.screenBackground = .color(color: .dimmedLightBackground)
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.3, radius: 8))
        attributes.screenInteraction = .dismiss
        attributes.entryInteraction = .absorbTouches
        attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .jolt)
        attributes.roundCorners = .all(radius: 25)
        attributes.entranceAnimation = .init(translate: .init(duration: 0.7, spring: .init(damping: 1, initialVelocity: 0)),
                                             scale: .init(from: 1.05, to: 1, duration: 0.4, spring: .init(damping: 1, initialVelocity: 0)))
        attributes.exitAnimation = .init(translate: .init(duration: 0.2))
        attributes.popBehavior = .animated(animation: .init(translate: .init(duration: 0.2)))
        attributes.positionConstraints.verticalOffset = 10
        attributes.positionConstraints.size = .init(width: .offset(value: 20), height: .intrinsic)
        attributes.positionConstraints.maxSize = .init(width: .constant(value: UIScreen.main.bounds.size.width), height: .intrinsic)
        attributes.statusBar = .dark
        return attributes
    }


    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.lightStatusBar ? .lightContent : .default
    }



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
            setupPopupAttributes()

            let viewControllerStoryboardId = "EventSearchViewController"
            let storyboardName = "Main"
            let storyboard = UIStoryboard(name: storyboardName, bundle: Bundle.main)
            guard let eventSearchViewController = storyboard.instantiateViewController(withIdentifier: viewControllerStoryboardId) as UIViewController? else { return }
            eventSearchViewController.modalPresentationStyle = .currentContext
            
//            self.presentingViewController?.dismiss(animated: true, completion: {
////                tutorialViewController.present(eventSearchViewController, animated: true, completion: nil)
//                print("Showing event search view in top most controller now")
//
//            })

            showLightAwesomePopupMessage(attributes: attributes!)
            print("Showing event search view in top most controller")
            
//            let tutorialViewController = self.presentingViewController! as! TutorialViewController
//            tutorialViewController.goToEventSearchView()
            
            
            //TODO: Properly present event search view controller
            //Change view to a thank you here
//                        self.presentingViewController?.view.isHidden = true
//            self.navigationController?.dismiss(animated: true, completion: {
//                print("dismissing navigation controller")
//                })
//            self.presentingViewController?.navigationController?.pushViewController(eventSearchViewController, animated: true)
            
//            self.navigationController?.present(eventSearchViewController, animated: true, completion: nil)
//        self.presentingViewController?.present(eventSearchViewController, animated: false, completion: nil)

        }

    }
    
    
    
    private func setupPopupAttributes() {
        
        attributes = bottomAlertAttributes
        attributes?.scroll = .edgeCrossingDisabled(swipeable: true)
        attributes?.entranceAnimation = .init(translate: .init(duration: 0.5, spring: .init(damping: 1, initialVelocity: 0)))
        attributes?.entryBackground = .gradient(gradient: .init(colors: [EKColor.LightPink.first, EKColor.LightPink.last], startPoint: .zero, endPoint: CGPoint(x: 1, y: 1)))
        attributes?.positionConstraints = .fullWidth
        attributes?.positionConstraints.safeArea = .empty(fillSafeArea: true)
        attributes?.roundCorners = .top(radius: 20)

    }
    
    private func showLightAwesomePopupMessage(attributes: EKAttributes) {
        let image = UIImage(named: "ic_done_all_light_48pt")!
        let title = "Awesome!"
        let description = "Thank you for submitting your answers. Time to Launch your trip!"
        showPopupMessage(attributes: attributes, title: title, titleColor: .white, description: description, descriptionColor: .white, buttonTitleColor: EKColor.Gray.mid, buttonBackgroundColor: .white, image: image)
    }

    
    private func showPopupMessage(attributes: EKAttributes, title: String, titleColor: UIColor, description: String, descriptionColor: UIColor, buttonTitleColor: UIColor, buttonBackgroundColor: UIColor, image: UIImage? = nil) {
        
        var themeImage: EKPopUpMessage.ThemeImage?
        
        if let image = image {
            themeImage = .init(image: .init(image: image, size: CGSize(width: 60, height: 60), contentMode: .scaleAspectFit))
        }
        
        let title = EKProperty.LabelContent(text: title, style: .init(font: MainFont.medium.with(size: 24), color: titleColor, alignment: .center))
        let description = EKProperty.LabelContent(text: description, style: .init(font: MainFont.light.with(size: 16), color: descriptionColor, alignment: .center))
        let button = EKProperty.ButtonContent(label: .init(text: "Got it!", style: .init(font: MainFont.bold.with(size: 16), color: buttonTitleColor)), backgroundColor: buttonBackgroundColor, highlightedBackgroundColor: buttonTitleColor.withAlphaComponent(0.05))
        let message = EKPopUpMessage(themeImage: themeImage, title: title, description: description, button: button) {
            SwiftEntryKit.dismiss()
        }
        
        let contentView = EKPopUpMessageView(with: message)
        SwiftEntryKit.display(entry: contentView, using: attributes)
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

