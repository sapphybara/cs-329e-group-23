//
//  HomeVC.swift
//  Group23
//
//  Created by m1 on 06/10/2022.
//

import UIKit
import PDFKit

let pdflist = ["pdf 1", "pdf 2", "pdf 3","pdf 4", "pdf 5"]

class HomeVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let collectionCellIdentifier = "pdfCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        //        // Add PDFView to view controller.
        //        let pdfView = PDFView(frame: self.view.bounds)
        //        pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        //        self.view.addSubview(pdfView)
        //
        //        // Fit content in PDFView.
        //        pdfView.autoScales = true
        //
        //        // Load Sample.pdf file from app bundle.
        //        let fileURL = Bundle.main.url(forResource: "sample-scan-1", withExtension: "pdf")
        //        pdfView.document = PDFDocument(url: fileURL!)

        
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func helpButtonPressed(_ sender: Any) {
        let controller = UIAlertController(
            title: "How to use our scanner!",
            message: "There are 3 pages to note, Home, Scan, and Profile. \n\n Home Screen: Here you will see the pdfs you scan! \n\n Scan Screen: Here you will be able to scan a pdf with your camera or upload from photo library. \n\n Profile Screen: Here you will see info about yourself and change settings."
            ,
            preferredStyle: .alert)
        controller.addAction(UIAlertAction(
            title: "OK",
            style: .default))
        present(controller, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        pdflist.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionCellIdentifier, for: indexPath) as! pdfCollectionViewCell
        let row = indexPath.row
        cell.myLabel.text = pdflist[row]
        cell.myImage.image = UIImage(named:"sample-scan-image-1")
        
        return cell
    }
}
