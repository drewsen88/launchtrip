//
//  AppDetailViewController.swift
//  AppStoreTransition
//
//  Created by Marcos Griselli on 18/03/2018.
//  Copyright © 2018 Marcos Griselli. All rights reserved.
//

import UIKit
import EasyTransitions

class EventDetailViewController: UIViewController {
    
    @IBOutlet weak var cardView: CardView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var eventNameLabel: UILabel!
    
    public var eventName: String
    public var eventCenterName: String
    public var startDate: String
    
    // TODO: - Inject card detail.
    init() {
        eventName = ""
        eventCenterName = ""
        startDate = ""
        super.init(nibName: String(describing: EventDetailViewController.self),
                   bundle: Bundle(for: EventDetailViewController.self))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        cardView.titleLabel.text = eventName
        cardView.eventCenterLabel.text = eventCenterName
        cardView.dateLabel.text = startDate
        cardView.delegate = self
        eventNameLabel.text = eventName
        backView.set(shadowStyle: .todayCard)
        layout(presenting: false)
        if #available(iOS 11, *) {
            contentView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
    }
    
    func layout(presenting: Bool) {
        let cardLayout: CardView.Layout = presenting ? .expanded : .collapsed
        contentView.layer.cornerRadius = cardLayout.cornerRadius
        backView.layer.cornerRadius = cardLayout.cornerRadius
        cardView.set(layout: cardLayout)
    }
}

extension EventDetailViewController: CardViewDelegate {
    func closeCardView() {
        dismiss(animated: true, completion: nil)
    }
}
