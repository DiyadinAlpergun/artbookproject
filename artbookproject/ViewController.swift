//
//  ViewController.swift
//  artbookproject
//
//  Created by neodiyadin on 15.08.2024.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var nameArray = [String]()
    var iDArray = [UUID]()
    var selectedPainting = ""
    var selectedPaintingId : UUID?
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonClicked))
        
        
        getdata()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getdata), name: NSNotification.Name(rawValue: "newData"), object: nil)
    }
    
    
    @objc func getdata() {
        
        nameArray.removeAll(keepingCapacity: false)
        iDArray.removeAll(keepingCapacity: false)
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let context = appDelegate?.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Spiderman")
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let results = try context?.fetch(fetchRequest)
            if results!.count > 0 {
                for result in results as! [NSManagedObject] {
                    if let name = result.value(forKey: "name") as? String {
                        self.nameArray.append(name)
                    }
                    
                    if let iD = result.value(forKey: "iD") as? UUID {
                        self.iDArray.append(iD)
                    }
                    
                    self.tableView.reloadData()
                    
                }
            }
        } catch {
            print("error")
        }
        
        
        
        
        
        
    }

    
    @objc func addButtonClicked() {
        selectedPainting = ""
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        var content = cell.defaultContentConfiguration()
        content.text = nameArray[indexPath.row]
        cell.contentConfiguration = content
        return cell
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailsVC" {
            let destination = segue.destination as? DetailsVC
            destination?.chosenPainting = selectedPainting
            destination?.chosenPaintingId = selectedPaintingId
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPainting = nameArray[indexPath.row]
        selectedPaintingId = iDArray[indexPath.row]
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            
            let appdelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appdelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Spiderman")
            let idString = iDArray[indexPath.row].uuidString
            fetchRequest.predicate = NSPredicate(format: "iD = %@", idString)
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let results = try context.fetch(fetchRequest)
                
                if results.count > 0 {
                    
                    
                    for result in results as! [NSManagedObject] {
                        
                        if let id = result.value(forKey: "iD") as? UUID {
                            if id == iDArray[indexPath.row] {
                                context.delete(result)
                                nameArray.remove(at: indexPath.row)
                                iDArray.remove(at: indexPath.row)
                                self.tableView.reloadData()
                                
                                do {
                                    try context.save()
                                } catch {
                                    print("error")
                                }
                                
                                break
                            }
                        }
                        
                    }
                    
                }
            } catch {
                print("error")
            }
            
        }
    }
    

}

