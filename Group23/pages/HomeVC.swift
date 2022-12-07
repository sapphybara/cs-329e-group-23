//
//  HomeVC.swift
//  Group23
//
//  Created by Warren Wiser on 06/10/2022.
//

import UIKit
import PDFKit

// global array for file deletion from UI to server side, uses file IDs from file naming schema within application
var filestToDelete: [Int] = []

class HomeVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var scansLabel: UILabel!
    @IBOutlet weak var welcomeUser: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let collectionCellIdentifier = "pdfCell"
    let segueID = "PdfSegue"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        welcomeUser.text = updateWelcomeMessage()
        scansLabel.text = "Scan or Upload something to get started!"
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(recognizeSwipeGesture(recognizer:)))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        self.view.addGestureRecognizer(swipeLeft)
    }
    
    @IBAction func recognizeSwipeGesture(recognizer: UISwipeGestureRecognizer) {
        if recognizer.direction == .left {
            self.tabBarController?.selectedIndex += 1
        }
    }
    
    func updateWelcomeMessage() -> String {
        if let user = activeUser {
            return "Welcome \(user.email!)!\nYour Files Will Automatically Sync 🔄"
        }
        return "Welcome Anonymous User!\nLogin Or Lose Your Data ⚠️🤖"
    }
    
    // This function shows available data
    func showData() {
        if pdfStoredObjects.count != 0 {
            scansLabel.text = "Here Are Your Available PDF Files"
        }
        self.collectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // checks for change in user login and also updates welcome message based on that application response
        welcomeUser.text = updateWelcomeMessage()
        if activeUser != nil {
            if loadServerData {
                print("Retrieving files")
                // once a file is retrieved, add it to the collection view
                serverUserFilesDataRetrieval(completion: showData)
                scanOrUpload = false
                loadServerData = false
            } else {
                showData()
            }
        } else {
            // block says, since the user is Anonymous, no need to request data from server, only show local data
            print("\nUSER IS Anonymous, SERVER REQUEST NOT VALID.\n")
            showData()
        }
    }
    
    @IBAction func helpButtonPressed(_ sender: Any) {
        let controller = UIAlertController(
            title: "How to use our scanner!",
            message: "There are 3 pages: Home, Scan, and Profile. \n\n Home Screen: Here you will see the PDFs you scan! \n\n Scan Screen: Here you will be able to scan a PDF with your camera or upload and make one from your photo library. \n\n Profile Screen: Here you will see info about yourself and change settings."
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
        
        cell.myImage.image =  listPDFThumbnails[row].0
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if allowHaptics{
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueID,
           let destination = segue.destination as? FullPdfVC,
           let selectedIndex = collectionView.indexPathsForSelectedItems {
            let finalIndexPathArray = Array(selectedIndex)
            let finalIndexPath = finalIndexPathArray.last
            let finalIndex = Int((finalIndexPath?.last!)!)
            let pdfDocumentBundle = pdfStoredObjects[finalIndex]
            let pdfDocumentID = pdfDocumentBundle.1
            var pdfDocument: [PDFDocument] = []
            
            for pdfObject in pdfStoredObjects {
                pdfDocument.append(pdfObject.0)
            }
            
            destination.currentPDF = pdfDocument[finalIndex]
            destination.currentPDFFileName = "File_\(pdfDocumentID).pdf"
            destination.pdfIDInternal = pdfDocumentID
            destination.onDeleteCompletion = collectionView.reloadData
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
