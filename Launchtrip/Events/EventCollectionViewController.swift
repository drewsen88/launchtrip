//
//  TodayCollectionViewController.swift
//  AppStoreTransition
//
//  Created by Marcos Griselli on 18/03/2018.
//  Copyright © 2018 Marcos Griselli. All rights reserved.
//

import UIKit
import EasyTransitions
import AMScrollingNavbar
import RFISO8601DateTime

struct AppStoreAnimatorInfo {
    var animator: AppStoreAnimator
    var index: IndexPath
}

class EventCollectionViewController: UICollectionViewController {

    private var modalTransitionDelegate = ModalTransitionDelegate()
    private var animatorInfo: AppStoreAnimatorInfo?
    private var eventsList = [Int]()
    public lazy var eventLandmarks = [EventLandmark]()
    
    // MARK: - Init
    public init() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 335, height: 412)
        layout.minimumLineSpacing = 30
        layout.minimumInteritemSpacing = 20
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        layout.scrollDirection = .vertical
        super.init(collectionViewLayout: layout)
        eventsList = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
    }

    required init?(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 335, height: 412)
        layout.minimumLineSpacing = 30
        layout.minimumInteritemSpacing = 20
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        layout.scrollDirection = .vertical
        eventsList = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]

        super.init(collectionViewLayout: layout)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //title = "CollectionView"
        //navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
        //navigationController?.navigationBar.barTintColor = UIColor(red:0.91, green:0.3, blue:0.24, alpha:1)

        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(EventCollectionViewCell.self)
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationController?.navigationBar.tintColor = .black
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        recalculateItemSizes(givenWidth: self.view.frame.size.width)
        
        if let navigationController = self.navigationController as? ScrollingNavigationController {
            navigationController.followScrollView(collectionView, delay: 50.0)
        }

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let navigationController = self.navigationController as? ScrollingNavigationController {
            navigationController.stopFollowingScrollView()
        }
    }
    
    func recalculateItemSizes(givenWidth width: CGFloat) {
        let vcWidth = width - 20//20 is left margin
        var width: CGFloat = 355 //335 is ideal size + 20 of right margin for each item
        let colums = round(vcWidth / width) //Aproximate times the ideal size fits the screen
        width = (vcWidth / colums) - 20 //we substract the right marging
        (collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize = CGSize(width: width, height: 412)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        recalculateItemSizes(givenWidth: size.width)

        coordinator.animate(alongsideTransition: nil) { (context) in
            //As the position of the cells might have changed, if we have an AppStoreAnimator, we update it's
            //"initialFrame" so the dimisss animation still matches
            if let animatorInfo = self.animatorInfo {
                if let cell = self.collectionView?.cellForItem(at: animatorInfo.index) {
                    let cellFrame = self.view.convert(cell.frame, from: self.collectionView)
                    animatorInfo.animator.initialFrame = cellFrame
                }
                else {
                    //ups! the cell is not longer on the screen so… ¯\_(ツ)_/¯ lets move it out of the screen
                    animatorInfo.animator.initialFrame = CGRect(x: (size.width-animatorInfo.animator.initialFrame.width)/2.0, y: size.height, width: animatorInfo.animator.initialFrame.width, height: animatorInfo.animator.initialFrame.height)
                }
            }
        }
    }

    // MARK: - UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.eventLandmarks.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: EventCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
//        cell.cardView.titleLabel.text = String(eventsList[indexPath.item])
        cell.cardView.titleLabel.text = String(self.eventLandmarks[indexPath.item].name)
        cell.cardView.eventCenterLabel.text = String(self.eventLandmarks[indexPath.item].eventCenter.name)
        
        let startString = self.eventLandmarks[indexPath.item].starts
        
        let parsedDateTime = Date.parseDateString(startString)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        let dateString = formatter.string(from: parsedDateTime!)
        cell.cardView.dateLabel.text = dateString
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let detailViewController = EventDetailViewController()
        
        let eventName = self.eventLandmarks[indexPath.item].name
        detailViewController.eventName = eventName
        detailViewController.eventCenterName = String(self.eventLandmarks[indexPath.item].eventCenter.name)
        
        let startString = self.eventLandmarks[indexPath.item].starts
        
        let parsedDateTime = Date.parseDateString(startString)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        let dateString = formatter.string(from: parsedDateTime!)
        detailViewController.startDate = dateString
        
        guard let cell = collectionView.cellForItem(at: indexPath) else {
            present(detailViewController, animated: true, completion: nil)
            return
        }

        let cellFrame = view.convert(cell.frame, from: collectionView)
        
        let appStoreAnimator = AppStoreAnimator(initialFrame: cellFrame)
        appStoreAnimator.onReady = { cell.isHidden = true }
        appStoreAnimator.onDismissed = { cell.isHidden = false }
        appStoreAnimator.auxAnimation = { detailViewController.layout(presenting: $0) }
    
        modalTransitionDelegate.set(animator: appStoreAnimator, for: .present)
        modalTransitionDelegate.set(animator: appStoreAnimator, for: .dismiss)
        modalTransitionDelegate.wire(
            viewController: detailViewController,
            with: .regular(.fromTop),
            navigationAction: {
                detailViewController.dismiss(animated: true, completion: nil)       
        })
        
        detailViewController.transitioningDelegate = modalTransitionDelegate
        detailViewController.modalPresentationStyle = .custom
        
        present(detailViewController, animated: true, completion: nil)
        animatorInfo = AppStoreAnimatorInfo(animator: appStoreAnimator, index: indexPath)
    }
}
