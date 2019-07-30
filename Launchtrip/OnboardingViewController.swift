//
//  OnboardingViewController.swift
//  Launchtrip
//
//  Created by Drew Sen on 2019-07-15.
//  Copyright © 2019 Drew Sen. All rights reserved.
//


import UIKit
import SPStorkController
import Hue
import Presentation
import SwiftEntryKit

class OnboardingViewController: PresentationController, UITextFieldDelegate {
    
    var attributes: EKAttributes! = nil

    private struct BackgroundImage {
        let name: String
        let left: CGFloat
        let top: CGFloat
        let speed: CGFloat
        
        init(name: String, left: CGFloat, top: CGFloat, speed: CGFloat) {
            self.name = name
            self.left = left
            self.top = top
            self.speed = speed
        }
        
        func positionAt(_ index: Int) -> Position? {
            var position: Position?
            
            if index == 0 || speed != 0.0 {
                let currentLeft = left + CGFloat(index) * speed
                position = Position(left: currentLeft, top: top)
            }
            
            return position
        }
    }
    
    private lazy var leftButton: UIBarButtonItem = { [unowned self] in
        let leftButton = UIBarButtonItem(
            title: "Previous",
            style: .plain,
            target: self,
            action: #selector(moveBack))
        
        leftButton.setTitleTextAttributes(
            [NSAttributedString.Key.foregroundColor : UIColor.black],
            for: .normal
        )
        
        return leftButton
        }()
    
    private lazy var rightButton: UIBarButtonItem = { [unowned self] in
        let rightButton = UIBarButtonItem(
            title: "Next",
            style: .plain,
            target: self,
            action: #selector(moveForward)
        )
        
        rightButton.setTitleTextAttributes(
            [NSAttributedString.Key.foregroundColor : UIColor.black],
            for: .normal
        )
        
        return rightButton
    }()
    
    private func setupPopupAttributes() {
        attributes = EKAttributes.centerFloat
        attributes.hapticFeedbackType = .success
        attributes.displayDuration = .infinity
        attributes.entryBackground = .gradient(gradient: .init(colors: [UIColor(rgb: 0xfffbd5), UIColor(rgb: 0xb20a2c)], startPoint: .zero, endPoint: CGPoint(x: 1, y: 1)))
        attributes.screenBackground = .color(color: .dimmedDarkBackground)
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.3, radius: 8))
        attributes.screenInteraction = .dismiss
        attributes.entryInteraction = .absorbTouches
        attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .jolt)
        attributes.roundCorners = .all(radius: 8)
        attributes.entranceAnimation = .init(translate: .init(duration: 0.7, spring: .init(damping: 0.7, initialVelocity: 0)),
                                             scale: .init(from: 0.7, to: 1, duration: 0.4, spring: .init(damping: 1, initialVelocity: 0)))
        attributes.exitAnimation = .init(translate: .init(duration: 0.2))
        attributes.popBehavior = .animated(animation: .init(translate: .init(duration: 0.35)))
        attributes.positionConstraints.size = .init(width: .offset(value: 20), height: .intrinsic)
        attributes.positionConstraints.maxSize = .init(width: .constant(value: UIScreen.main.bounds.size.width), height: .intrinsic)
        attributes.statusBar = .dark

    }

    private var nameTextField : UITextField!
    private var emailTextField : UITextField!

    private lazy var username: String = ""
    
    private var skipButton: UIButton!
    @IBOutlet weak var eventSearchView: UIView!
        
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isBeingDismissed{
            print("is being dismissed")
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationTitle = false
        navigationItem.leftBarButtonItem = leftButton
        navigationItem.rightBarButtonItem = rightButton
        view.backgroundColor = UIColor(hex: "FFBC00")
        
        setupPopupAttributes()

        configureSlides()
        configureBackground()
    }
    
    
    // MARK: - Configuration
    
    private func configureSlides() {
        let ratio: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 1 : 0.6
        let font = UIFont(name: "HelveticaNeue", size: 34.0 * ratio)!
        let color = UIColor(hex: "000000")
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.center
        
        let attributes = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: color,
            NSAttributedString.Key.paragraphStyle: paragraphStyle
        ]
        
        let titles = [
            "Welcome to Launchtrip \n \n We'd like to ask you 5 questions to get know you! \n \n Let's get Started",
            "Let's start off with your name:",
            "Tell us a bit about yourself, " + username + ", so we can create a better experience for you \n \n Hotel Type?",
            "What do you prioritize when booking a hotel?",
            "What bests fits your dining style? \n \n (Select all that apply)",
            "Thanks! Lastly please enter your email to help us store your preferences",
            "All set " + username + ", we'll use your choices to help build the best experience"].enumerated().map { (index, title) -> Content in
                let view = UIView(frame: CGRect(x: 0, y: 0, width: 550 * ratio, height: (300 * ratio) + 400))
                view.isUserInteractionEnabled = true
                let label = UILabel(frame: CGRect(x: 0, y: 50, width: view.frame.size.width, height: 300 * ratio))
                label.numberOfLines = 7
                label.attributedText = NSAttributedString(string: title, attributes: attributes)
                view.addSubview(label)
                
                switch index {
                    case 1:
                        //add name textfield
                        nameTextField = UITextField(frame: CGRect(x: 0, y: label.frame.origin.y + label.frame.size.height*0.75, width: label.frame.size.width, height: 40))
                        nameTextField.borderStyle = .roundedRect
                        nameTextField.clearButtonMode = .whileEditing
                        nameTextField.placeholder = "Name"
                        nameTextField.delegate = self
                        nameTextField.tag = 1
                        view.addSubview(nameTextField)
                        view.bringSubviewToFront(nameTextField)
                    case 2:
                        let tagView = configureMultipleChoice(dy: label.frame.origin.y + label.frame.size.height, answers: ["ans1","ans2","ans3","ans4"], isSingleTap: true)
                        view.addSubview(tagView)
                        view.bringSubviewToFront(tagView)
                    case 3:
                        let tagView = configureMultipleChoice(dy: label.frame.size.height, answers: ["Price is affordable","ans2","ans3","ans4"], isSingleTap: true)
                        view.addSubview(tagView)
                    case 4:
                        let tagView = configureMultipleChoice(dy: label.frame.size.height, answers: ["Michelin Starred","ans2","ans3","ans4", "ans5"], isSingleTap: false)
                        view.addSubview(tagView)
                    case 5:
                        emailTextField = UITextField(frame: CGRect(x: 0, y: label.frame.origin.y + label.frame.size.height, width: label.frame.size.width, height: 40))
                        emailTextField.borderStyle = .roundedRect
                        emailTextField.clearButtonMode = .whileEditing
                        emailTextField.placeholder = "email"
                        emailTextField.delegate = self
                        emailTextField.tag = 2
                        view.addSubview(emailTextField)
                        let skipButton = UIButton(frame: CGRect(x: view.center.x - 50, y: 500, width: 100, height: 50))
                        skipButton.backgroundColor = .white
                        skipButton.setTitleColor(.black, for: .normal)
                        skipButton.layer.cornerRadius = 10
                        skipButton.setTitle("Skip", for: [])
                        skipButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)

                        view.addSubview(skipButton)
                        print(#function)
                    case 6:
                        let startTripButton = UIButton(frame: CGRect(x: 0, y: label.frame.origin.y +  label.frame.size.height, width: view.frame.size.width, height: 50))
                        startTripButton.backgroundColor = .white
                        startTripButton.setTitleColor(.black, for: .normal)
                        startTripButton.layer.cornerRadius = 10
                        startTripButton.setTitle("Start Trip", for: [])
                        startTripButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
                        
                        view.addSubview(startTripButton)

                    default:
                        print("No text needed")
                }
                
                let position = Position(left: 0.7, top: 0.55)
                
                return Content(view: view, position: position)
        }
        
        var slides = [SlideController]()
        
        for index in 0...6 {
            let controller = SlideController(contents: [titles[index]])
            controller.add(animations: [Content.centerTransition(forSlideContent: titles[index])])
            slides.append(controller)
        }
        
        
        add(slides)
    }
    
    private func configureBackground() {
        let backgroundImages = [
            BackgroundImage(name: "Trees", left: 0.0, top: 0.743, speed: -0.3),
            BackgroundImage(name: "Bus", left: -0.03, top: 0.77, speed: 0.18),
            BackgroundImage(name: "Truck", left: 1.3, top: 0.73, speed: -0.5),
            BackgroundImage(name: "Roadlines", left: 0.0, top: 0.79, speed: -0.24),
            BackgroundImage(name: "Houses", left: 0.0, top: 0.627, speed: -0.16),
            BackgroundImage(name: "Hills", left: 0.0, top: 0.51, speed: -0.08),
            BackgroundImage(name: "Mountains", left: 0.0, top: 0.29, speed: 0.0),
            BackgroundImage(name: "Clouds", left: -0.415, top: 0.14, speed: 0.18),
            BackgroundImage(name: "Sun", left: 0.8, top: 0.07, speed: 0.0)
        ]
        
        var contents = [Content]()
        
        for backgroundImage in backgroundImages {
            let imageView = UIImageView(image: UIImage(named: backgroundImage.name))
            if let position = backgroundImage.positionAt(0) {
                contents.append(Content(view: imageView, position: position, centered: false))
            }
        }
        
        addToBackground(contents)
        
        for row in 1...6 {
            for (column, backgroundImage) in backgroundImages.enumerated() {
                if let position = backgroundImage.positionAt(row), let content = contents.at(column) {
                    addAnimation(TransitionAnimation(content: content, destination: position,
                                                     duration: 2.0, damping: 1.0), forPage: row)
                }
            }
        }
        
        let groundView = UIView(frame: CGRect(x: 0, y: 0, width: 1024, height: 60))
        groundView.backgroundColor = UIColor(hex: "FFCD41")
        
        let groundContent = Content(
            view: groundView,
            position: Position(left: 0.0, bottom: 0.063),
            centered: false
        )
        
        contents.append(groundContent)
        addToBackground([groundContent])
    }
    
    private func showLightAwesomePopupMessage(attributes: EKAttributes) {
        let image = UIImage(named: "ic_done_all_light_48pt")!
        let title = "Awesome!"
        let description = "You've successfully entered your email!"
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
            self.moveForward()
        }
        
        let contentView = EKPopUpMessageView(with: message)
        SwiftEntryKit.display(entry: contentView, using: attributes)
    }
    
    
    @objc func buttonAction(sender: UIButton!) {
        print("Button tapped")
    }

    
    public func goToEventSearchView() {
        print(#function)
    }
    
    private func configureMultipleChoice( dy : CGFloat, answers : [String], isSingleTap: Bool) -> JoTagView
    {
        let ratio: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 1 : 0.6
        // height value is not matter, you can input any value
        let tagView = JoTagView(frame: CGRect(x: 0, y: dy, width: 550 * ratio, height: 0))
        
        tagView.numberOfRow = 1
        tagView.isTagCanTouch = true
        tagView.isNeedFlipColor = true
        
        /// If u need call back
        tagView.delegate = self
        tagView.dataSource = answers
        tagView.isSingleTap = isSingleTap
        
        /// Important!!
        /// Property must set befor you setupTagView, Otherwise it setup with default property value
        tagView.setupTagView()
        
        return tagView
        
//        self.contentView.addSubview(tagView!)
//
//        /// Get Tag View Height
//        contentViewHeight.constant = CGFloat((tagView?.getContentViewHeight())!)
//
//        contentHeightLab.text = "Tag Content View Height: " + String((tagView?.getContentViewHeight())!)

    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        textField.resignFirstResponder()
        return true
    }

    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("Editing ended")
        
        switch textField.tag {
        case 1:
            username = textField.text ?? ""
            print(username)
            if username != "" {
                //            self.dataSource = nil
                //            self.dataSource = self
                removeAllSlides()
                configureSlides()
                moveForward()
                
            }
        case 2:
            if textField.text != "" {
                showLightAwesomePopupMessage(attributes: attributes!)
            }
        default:
            print(textField.text ?? "")
        }

    }

    
}

extension OnboardingViewController {
    
    @IBAction func skipButtonTapped(_: UIButton) {
        
        print(#function)
        
    }
    
    
}

// MARK: SPStorkControllerDelegate

extension OnboardingViewController: SPStorkControllerDelegate {
    
    func didDismissStorkByTap() {
        print("SPStorkControllerDelegate - didDismissStorkByTap")
    }
    
    func didDismissStorkBySwipe() {
        print("SPStorkControllerDelegate - didDismissStorkBySwipe")
    }
}

//MARK: JoTagViewDelegate
extension OnboardingViewController: JoTagViewDelegate {
    func didSelectTag(sender: UIButton, index: Int) {
        print("Select Tag: " + (sender.currentTitle ?? "No Data"))
    }
}


//MARK: Constants
private extension OnboardingViewController {
    
    static let titleFont = UIFont(name: "Nunito-Bold", size: 36.0) ?? UIFont.boldSystemFont(ofSize: 36.0)
    static let descriptionFont = UIFont(name: "OpenSans-Regular", size: 14.0) ?? UIFont.systemFont(ofSize: 14.0)
}

private extension Array {
    func at(_ index: Int?) -> Element? {
        var object: Element?
        if let index = index , index >= 0 && index < endIndex {
            object = self[index]
        }
        
        return object
    }
}


