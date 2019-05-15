//
//  AlbumTableViewController.swift
//  TextOnPhoto
//
//  Created by Mostafizur Rahman on 26/2/19.
//  Copyright © 2019 Mostafizur Rahman. All rights reserved.
//

import UIKit

class AlbumListController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    let albumManager = AlbumManager.shared
    let scaling = UIScreen.main.scale
    var thumbSize = CGSize.zero
    @IBOutlet weak var cancelButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.thumbSize = CGSize(width: 75 * self.scaling, height: 75 * self.scaling)
        
        let locExit = "cancel".localized(withComment: "__")
        self.cancelButton.setTitle(locExit, for: .normal)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    

    @IBAction func exitAlbumView(_ sender: Any) {
        self.dismiss(animated: true) {
            print("done")
        }
    }
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return albumManager.albumCollection.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableCell", for: indexPath) as! AlbumTableCell

        let albumName = self.albumManager.albumTitleArray[indexPath.row]
        cell.tableAlbumTitle.text = albumName
        cell.accessoryType = (albumName+" 🔻").elementsEqual(self.albumManager.titleName) ? .checkmark : .none
        let assetArray = self.albumManager.albumCollection[albumName]
        cell.tableImageCount.text = "\(assetArray?.count ?? 0) photos."
        if let asset = assetArray?.first {
            self.albumManager.requestImage(for: asset, targetSize:self.thumbSize ) { (thumbImage) in
                DispatchQueue.main.async {
                    cell.tableAlbumIcon.image = thumbImage
                }
            }
        }
        
        
        // Configure the cell...

        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var index  = 0
        while index < self.albumManager.albumTitleArray.count {
            let __title = self.albumManager.albumTitleArray[index]
            if __title.elementsEqual(self.albumManager.titleName) {
                let __indexPath = IndexPath.init(row: index, section: 0)
                let row = tableView.cellForRow(at: __indexPath)
                row?.accessoryType = .none
                break
            }
            index += 1
        }
        
        let row = tableView.cellForRow(at: indexPath)
        row?.accessoryType = .checkmark
        let _albumTitle = self.albumManager.albumTitleArray[indexPath.row]
        guard let array = self.albumManager.albumCollection[_albumTitle] else {return}
        self.albumManager.selectedArray = array
        self.albumManager.titleName = _albumTitle + " 🔻"
        let notificationName = Notification.Name(rawValue: "media_reading_done")
        NotificationCenter.default.post(name: notificationName, object: nil)
        self.dismiss(animated: true) {
            
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
