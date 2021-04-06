//
//  ViewController.swift
//  BelajarCoreData
//
//  Created by zein rezky chandra on 06/04/21.
//

import UIKit
import CoreData

struct ProductModel {
    var productImage = ""
    var productName = ""
    var productPrice = 0
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, EditViewControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var productCollection = [ProductModel]()
    var selectedIndex = 0
    
    var productArray = ["Bintang", "Heineken", "Corona", "Angker", "Ziger", "Jack-D", "Smirnof", "BlackLabel", "RedLabel", "Bintang Zero", "Es-teh", "Kopi", "Bajigur", "Jahe", "Susu"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialDataToCoreData()
    }
    
    func setupInitialDataToCoreData() {
        if productCollection.count == 0 {
            createData()
        }
        retrieveData()
        tableView.reloadData()
    }
    
    func navigateToEditVC(indexSelected: Int) {
        let editVC = EditViewController()
        editVC.delegate = self
        editVC.products = self.productCollection
        editVC.prevProductName = productCollection[indexSelected].productName
        editVC.indexOf = indexSelected
        self.present(editVC, animated: true, completion: nil)
    }
    
    func updateArray(productArray: [ProductModel], prevProdName: String) {
        self.productCollection = productArray
        updateCoreData(prevName: prevProdName)
//        retrieveData()
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productCollection.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 189
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "productCellIdentifier", for: indexPath) as! ProductCell
        cell.productImage.image = UIImage(named: productCollection[indexPath.row].productImage)
        cell.productName.text = productCollection[indexPath.row].productName
        cell.productPrice.text = "Rp \(productCollection[indexPath.row].productPrice)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // Component Delete action
        let delete = UIContextualAction(style: .normal, title: "Delete") { [weak self] (action, view, completionHandler) in
            self?.deleteData(productName: self!.productCollection[indexPath.row].productName)
            completionHandler(true)
        }
        delete.backgroundColor = .red
        
        // Component edit action
        let edit = UIContextualAction(style: .normal, title: "Edit") { [weak self](action, view, completionHandler) in
            self?.updateData(indexOf: indexPath.row)
            self!.selectedIndex = indexPath.row
            completionHandler(true)
        }
        edit.backgroundColor = .orange
        
        let configuration = UISwipeActionsConfiguration(actions: [delete, edit])
        return configuration
    }
    
    // MARK: CoreData
    func createData() {
        // kita perlu buat container dari coredata nya, container core data itu ada di appdelegate file
        // 1. Kita perlu akses app delegate? karena semua codingan coredata container ada didalam appdelegate
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        // 2. Setelah ada akses ke app delegate, maka kita bisa akses si container coredata nya
        let manageContext = appDelegate.persistentContainer.viewContext
        
        // 3. Kita udah akses container nya, sekarang kita akses entity dari core datanya untuk bisa assign value dari attribute yang ada di entity core data kita
        guard let productEntity = NSEntityDescription.entity(forEntityName: "Product", in: manageContext) else { return }
        
        for i in 1...productArray.count {
            let product = NSManagedObject(entity: productEntity, insertInto: manageContext)
            product.setValue(10000*i, forKey: "product_price")
            product.setValue(productArray[i-1], forKey: "product_name")
            product.setValue("images-\(i)", forKey: "product_image")
        }
    }
    
    func retrieveData() {
        // Make sure local model juga kosong ga ada data
        productCollection.removeAll()
        // kita perlu buat container dari coredata nya, container core data itu ada di appdelegate file
        // 1. Kita perlu akses app delegate? karena semua codingan coredata container ada didalam appdelegate
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        // 2. Setelah ada akses ke app delegate, maka kita bisa akses si container coredata nya
        let manageContext = appDelegate.persistentContainer.viewContext

        // 3. Prepare fetch dari entity coredata nya
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Product")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor.init(key: "product_name", ascending: true)]
        
        do {
            let result = try manageContext.fetch(fetchRequest)
            for data in result as! [NSManagedObject] {
                productCollection.append(ProductModel(productImage: data.value(forKey: "product_image") as! String, productName: data.value(forKey: "product_name") as! String, productPrice: data.value(forKey: "product_price") as! Int))
            }
        } catch let error as NSError {
            print("Error due to : \(error.localizedDescription)")
        }
    }
    
    func updateCoreData(prevName: String) {
        // kita perlu buat container dari coredata nya, container core data itu ada di appdelegate file
        // 1. Kita perlu akses app delegate? karena semua codingan coredata container ada didalam appdelegate
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        // 2. Setelah ada akses ke app delegate, maka kita bisa akses si container coredata nya
        let manageContext = appDelegate.persistentContainer.viewContext

        // 3. Prepare fetch dari entity coredata nya
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Product")
        fetchRequest.predicate = NSPredicate(format: "product_name = %@", prevName)
        
        do {
            let object = try manageContext.fetch(fetchRequest)
            
            let objectToUpdate = object[0] as! NSManagedObject
            objectToUpdate.setValue(productCollection[selectedIndex].productName, forKey: "product_name")
            objectToUpdate.setValue(productCollection[selectedIndex].productPrice, forKey: "product_price")
            
            do {
                try manageContext.save()
            } catch {
                print(error)
            }
        } catch let error as NSError {
            print(error)
        }

    }
    
    func updateData(indexOf: Int) {
        navigateToEditVC(indexSelected: indexOf)
    }
    
    func deleteData(productName: String) {
        // kita perlu buat container dari coredata nya, container core data itu ada di appdelegate file
        // 1. Kita perlu akses app delegate? karena semua codingan coredata container ada didalam appdelegate
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        // 2. Setelah ada akses ke app delegate, maka kita bisa akses si container coredata nya
        let manageContext = appDelegate.persistentContainer.viewContext

        // 3. Prepare fetch dari entity coredata nya
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Product")
        fetchRequest.predicate = NSPredicate(format: "product_name = %@", productName)
        
        do {
            let objectFrom = try manageContext.fetch(fetchRequest)
            
            let objectToDelete = objectFrom[0] as! NSManagedObject
            manageContext.delete(objectToDelete)
            
            do {
                try manageContext.save()
            } catch {
                print(error)
            }

        } catch let error as NSError {
            print("Error due to : \(error.localizedDescription)")
        }
        
        retrieveData()
        tableView.reloadData()
    }
}

