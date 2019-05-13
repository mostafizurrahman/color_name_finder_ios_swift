//
//  ColorListViewController.swift
//  ColorFinder
//
//  Created by NoboPay on 12/5/19.
//  Copyright © 2019 Mostafizur Rahman. All rights reserved.
//

import UIKit

class ColorListViewController: UIViewController {
    let saver = ColorSaver.shared
    let dataLoader = ColorData.shared
    @IBOutlet weak var colorCollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let layout = UICollectionViewFlowLayout()
        let __thumb_height = CGFloat(220)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            let __width = (UIScreen.main.bounds.width - 60) / 2
            
            layout.itemSize = CGSize.init(width:  __width - 10,
                                          height: __thumb_height )
//            layout.sectionInset = UIEdgeInsets(top: 30, left: 20,
//                                               bottom: 80, right: 20)
            
        } else if UIDevice.current.userInterfaceIdiom == .phone {
            let __width = UIScreen.main.bounds.width - 40
            
            layout.itemSize = CGSize.init(width:  __width,
                                          height: __thumb_height )
            
        }
        layout.sectionInset = UIEdgeInsets(top: 30, left: 20,
                                           bottom: 30, right: 20)
        layout.minimumLineSpacing = 24
        self.colorCollectionView.collectionViewLayout = layout
        // Do any additional setup after loading the view.
        let notname = Notification.Name.init("color_saved")
        NotificationCenter.default.addObserver(self, selector: #selector(reloadColor(_ :)), name: notname, object: nil)
        for _ in 1...5 {
            let r = Int(arc4random() % 255)
            let g = Int(arc4random() % 255)
            let b = Int(arc4random() % 255)
            let color = Color(r: r, g: g, b: b)
            self.dataLoader.colorDataArray.append(color)
        }
        self.colorCollectionView.reloadData()
    }
    @objc func reloadColor(_ not:Notification){
        self.colorCollectionView.reloadData()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ColorListViewController:UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataLoader.colorDataArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CCell", for: indexPath) as! ColorCell
        let data = self.dataLoader.colorDataArray[indexPath.row]
        cell.color = data
        return cell
    }
    
}
