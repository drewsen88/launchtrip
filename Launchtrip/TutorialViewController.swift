//
//  TutorialViewController.swift
//  Launchtrip
//
//  Created by Drew Sen on 2019-07-15.
//  Copyright © 2019 Drew Sen. All rights reserved.
//


import UIKit
import paper_onboarding
import SPStorkController

class TutorialViewController: UIViewController {
    
    @IBOutlet var skipButton: UIButton!
    @IBOutlet weak var eventSearchView: UIView!
        
    @IBOutlet weak var tutorialView: UIView!
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
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isBeingDismissed{
            print("is being dismissed")
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        skipButton.isHidden = true
        
        setupPaperOnboardingView()
        view.bringSubviewToFront(skipButton)
        
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
    
    
    public func goToEventSearchView() {
        //        isFlipped = !isFlipped
        //
        //        let cardToFlip = isFlipped ? goldenView : greenView
        //        let bottomCard = isFlipped ? greenView : goldenView
        
        UIView.transition(from: tutorialView,
                          to: eventSearchView,
                          duration: 0.5,
                          options: [.transitionCurlUp, .showHideTransitionViews],
                          completion: nil)
        
        
        //        UIView.transition(with: cardToFlip!,
        //                          duration: 0.5,
        //                          options: [.transitionFlipFromRight],
        //                          animations: {
        //
        //                            cardToFlip?.isHidden =  true
        //        },
        //                          completion: { _ in
        //
        //                            self.view.bringSubview(toFront: bottomCard!)
        //                            cardToFlip?.isHidden = false
        //        })
    }

    
}

extension TutorialViewController {
    
    @IBAction func skipButtonTapped(_: UIButton) {
        
        print(#function)
        
        let viewControllerStoryboardId = "OnboardingViewController"
        let storyboardName = "Main"
        let storyboard = UIStoryboard(name: storyboardName, bundle: Bundle.main)
        let onboardingViewController = storyboard.instantiateViewController(withIdentifier: viewControllerStoryboardId)
        object_setClass(onboardingViewController, OnboardingViewController.self)

        let transitionDelegate = SPStorkTransitioningDelegate()
        transitionDelegate.storkDelegate = self
        transitionDelegate.confirmDelegate = onboardingViewController as? SPStorkControllerConfirmDelegate
        onboardingViewController.transitioningDelegate = transitionDelegate
        onboardingViewController.modalPresentationStyle = .custom        
        
        present(onboardingViewController, animated: true, completion: nil)
        
    }
    
    
}

// MARK: PaperOnboardingDelegate

extension TutorialViewController: PaperOnboardingDelegate {
    
    func onboardingWillTransitonToIndex(_ index: Int) {
        skipButton.isHidden = index == 2 ? false : true
    }
    
    func onboardingConfigurationItem(_ item: OnboardingContentViewItem, index: Int) {
        
        // configure item
        
        //item.titleLabel?.backgroundColor = .redColor()
        //item.descriptionLabel?.backgroundColor = .redColor()
        //item.imageView = ...
    }
}

// MARK: SPStorkControllerDelegate

extension TutorialViewController: SPStorkControllerDelegate {
    
    func didDismissStorkByTap() {
        print("SPStorkControllerDelegate - didDismissStorkByTap")
    }
    
    func didDismissStorkBySwipe() {
        print("SPStorkControllerDelegate - didDismissStorkBySwipe")
    }
}

// MARK: PaperOnboardingDataSource

extension TutorialViewController: PaperOnboardingDataSource {
    
    func onboardingItem(at index: Int) -> OnboardingItemInfo {
        return items[index]
    }
    
    func onboardingItemsCount() -> Int {
        return 3
    }
    
    //    func onboardinPageItemRadius() -> CGFloat {
    //        return 2
    //    }
    //
    //    func onboardingPageItemSelectedRadius() -> CGFloat {
    //        return 10
    //    }
    //    func onboardingPageItemColor(at index: Int) -> UIColor {
    //        return [UIColor.white, UIColor.red, UIColor.green][index]
    //    }
}



//MARK: Constants
private extension TutorialViewController {
    
    static let titleFont = UIFont(name: "Nunito-Bold", size: 36.0) ?? UIFont.boldSystemFont(ofSize: 36.0)
    static let descriptionFont = UIFont(name: "OpenSans-Regular", size: 14.0) ?? UIFont.systemFont(ofSize: 14.0)
}


