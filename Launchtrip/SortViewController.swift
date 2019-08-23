//
//  SortViewController.swift
//  Launchtrip
//
//  Created by Drew Sen on 2019-08-19.
//  Copyright © 2019 Drew Sen. All rights reserved.
//

import UIKit

class SortViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    weak var delegate: SortViewControllerDelegate?
    
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
        
        if let sortOption = SortBy(index: indexPath.row) {
            delegate?.sortBy(option: sortOption)
        }
        
        if let path = selectedIndexPath {
            let cell = tableView.cellForRow(at: path as IndexPath)
            cell?.accessoryType = .none
        }
        
        dismiss(animated: true, completion: nil)

    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    private var selectedIndexPath: NSIndexPath?
    @IBOutlet var tableView: UITableView!
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SortCell", for: indexPath as IndexPath)
        
        if let sortOption = SortBy(index: indexPath.row) {
            cell.textLabel?.text = sortOption.description
            if sortOption == SortBy.Popularity {
                cell.accessoryType = .checkmark
                selectedIndexPath = indexPath as NSIndexPath
            }
        }
        
        return cell
    }


}
