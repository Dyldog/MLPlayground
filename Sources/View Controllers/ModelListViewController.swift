//
//  ModelListViewController.swift
//  MachineLearningTests
//
//  Created by Dylan Elliot on 15/2/18.
//  Copyright © 2018 Dylan Elliott. All rights reserved.
//

import UIKit

class ModelListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

  @IBOutlet var tableView: UITableView!

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return ModelManager.shared.numberOfModels
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cellId = "CellId"
    let cell = tableView.dequeueReusableCell(withIdentifier: cellId) ?? UITableViewCell(style: .default, reuseIdentifier: cellId)

    let model = ModelManager.shared.model(at: indexPath.row)
    cell.textLabel?.text = model.name

    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let model = ModelManager.shared.model(at: indexPath.row)

    // let storyboard = UIStoryboard(name: "Main", bundle: nil)
    //let viewController = storyboard.instantiateViewController(withIdentifier: "ModelDetailScreen") as! ModelDetailViewController
    // viewController.model = model
    let viewController = ModelDetailViewController(model: model)
    self.navigationController?.pushViewController(viewController, animated: true)
  }

  func showNewModelAlert() {
    let alert = UIAlertController(title: "Add Model", message: nil, preferredStyle: .alert)

    alert.addTextField { (textfield) in
      textfield.placeholder = "Model name"
    }

    alert.addTextField { (textfield) in
      textfield.placeholder = "Model url"
    }

    let confirmAction = UIAlertAction(title: "Add", style: .default) { (action) in
      guard let name = alert.textFields?[0].text, let urlString = alert.textFields?[1].text
        else { return }

      ModelManager.shared.newModel(withName: name, networkURL: URL(string: urlString)!)
      self.tableView.reloadData()
    }
    alert.addAction(confirmAction)

    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    alert.addAction(cancelAction)

    self.present(alert, animated: true, completion: nil)
  }

  @IBAction func addButtonTapped(_ sender: Any) {
    showNewModelAlert()
  }
}
