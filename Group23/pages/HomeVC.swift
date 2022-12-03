//
//  HomeVC.swift
//  Group23
//
//  Created by m1 on 06/10/2022.
//

import UIKit
import PDFKit

class HomeVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var scansLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let collectionCellIdentifier = "pdfCell"
    let segueID = "PdfSegue"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        scansLabel.text = "Scan or Upload something to get started!"
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
    
//    // Need to show data on start up -- Need help here, not sure how to do this immediately after application launches
//    override func viewWillAppear(_ animated: Bool) {
//        // Retrieve server data, and reloadData
//        serverUserFilesDataRetrieval()
//        self.collectionView.reloadData()
//    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("-HOME VC CHECK- pdfObjectCheck: \(pdfStoredObjects.count)-")
        
        // This function shows data
        func showData() {
            if pdfStoredObjects.count != 0{
                scansLabel.text = "Your PDFs"
            }
            print("number of scans \(pdfStoredObjects.count)")
            //        print(listPDFThumbnails)
            //        print(listPDFThumbnails.count)
            self.collectionView.reloadData()
        }
        
        if scanOrUpload == true && loadServerData == true {
            // block says, if file has been scanned or uploaded, reload the server data (add data procedure)
            
            // This line retrieves server data in background
            serverUserFilesDataRetrieval()
            
            print("\nTHROWING SERVER DATA TO HOMEVC, CASE 1\n")
            
            showData()
            
            scanOrUpload = false
            loadServerData = false
        } else if scanOrUpload == false && loadServerData == true {
            // block says, if file has not been scanned or uploaded, and server data has not been loaded locally
            // then load server data once with an array check to mitigate copies (start up procedure)
            
            // This line retrieves server data in background
            serverUserFilesDataRetrieval()
            
            print("\nTHROWING SERVER DATA TO HOMEVC, CASE 2\n")
            
            showData()
            
            loadServerData = false
        } else {
            // block says, if file has not been scanned or uploaded, and server data has been loaded locally
            // just show locally loaded data, not need to make a server request (navigation procedure)
            
            print("\nNO DATA HAS BEEN SCANNED, JUST SHOW DATA\n")
            showData()
        }
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
        pdfStoredObjects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionCellIdentifier, for: indexPath) as! pdfCollectionViewCell
        let row = indexPath.row
        
        cell.myImage.image =  listPDFThumbnails[row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("picked pdf \(indexPath.item)")
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueID,
           let destination = segue.destination as? FullPdfVC,
           let selectedIndex = collectionView.indexPathsForSelectedItems{
            let finalIndexPathArray = Array(selectedIndex)
            let finalIndexPath = finalIndexPathArray.last
            let finalIndex = Int((finalIndexPath?.last!)!)
            print(finalIndex)
            
            var pdfDocument: [PDFDocument] = []
            
            for pdfObject in pdfStoredObjects {
                pdfDocument.append(pdfObject.0)
            }
            
            destination.currentPDF = pdfDocument[finalIndex]
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let layout = UICollectionViewFlowLayout()
        let containerWidth = collectionView.bounds.width
        let cellSize = (containerWidth-20)/3
        layout.itemSize = CGSize(width: cellSize, height: cellSize * 1.3)
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 4
        layout.sectionInset = UIEdgeInsets(top: 10, left: 4, bottom: 0, right: 4)
        
        collectionView.collectionViewLayout = layout
    }
    
}
