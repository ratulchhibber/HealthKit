//
//  StepsTableViewController.swift
//  HealthApp
//
//  Created by Ratul Chhibber on 17/03/20.
//  Copyright © 2020 Ratul Chhibber. All rights reserved.
//

import UIKit
import HealthKit

class StepsTableViewController: UITableViewController {
    
    private var todayStep = 0
    private var stepDataSource = [[String : String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: Get Healthkit permission
        HealthKitAssistant.shared.getHealthKitPermission { (response) in
            if response { self.loadMostRecentSteps() }
        }
    }
    
    func loadMostRecentSteps()  {
        
        guard let stepsdata = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }
        
        HealthKitAssistant.shared.getMostRecentStep(for: stepsdata) { (steps , stepsData) in
            self.todayStep = steps
            self.stepDataSource = stepsData
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stepDataSource.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = (stepDataSource[indexPath.row] as AnyObject).object(forKey: "steps") as? String
        cell.detailTextLabel?.text = (stepDataSource[indexPath.row] as AnyObject).object(forKey: "enddate") as? String
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Steps"
    }
}
