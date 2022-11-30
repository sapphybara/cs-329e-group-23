//
//  ProfileTable.swift
//  Group23
//
//  Created by m1 on 30/11/2022.
//

import UIKit

class ProfileTable: UITableViewController {

    @IBOutlet var profileTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        profileTable.delegate = self
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        profileTable.deselectRow(at: indexPath, animated: true)
    }

}
