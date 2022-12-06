//
//  ScanCamera.swift
//  Group23
//
//  Created by Warren Wiser on 05/12/2022.
//

import UIKit
import PDFKit
import VisionKit

/// extends ScanVC to implement documents scanned by user
extension ScanVC: VNDocumentCameraViewControllerDelegate {
    // This function uploads data to server
    func serverFileUpload(pdfDocument: PDFDocument, pdfID: Int) {
        
        if let user = activeUser {
            let pdfRef = currentStorageRef.child("userFiles/\(user.email!)/File_\(pdfID).pdf")
            // Upload user data to the appropriate server location for the appropriate user
            _ = pdfRef.putData(pdfDocument.dataRepresentation()!, metadata: nil)
        } else {
            print("User not found, cannot upload!")
        }
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        
        // If there are no pdf scans then proceed with else
        guard scan.pageCount >= 1 else {
            controller.dismiss(animated: true)
            return
        }
        
		self.scheduleNotification()
        // Multithreading for PDF Scan Where Number Of Scans >= 1
        DispatchQueue.main.async {
            var pdfDocIDExternal: Int
            
            // Block of code below makes a file ID and makes sure that ID does not exist
            func idMaker(pdfListCheck: [(PDFDocument, Int)]) -> Int {
                var pdfDocID: Int
                var idArray:[Int] = []
                
                for pdfFileIDs in pdfListCheck {
                    idArray.append(pdfFileIDs.1)
                }
                
                // ID Generator
                pdfDocID = Int.random(in: 0..<100000)
                
                if idArray.contains(pdfDocID) {
                    while idArray.contains(pdfDocID) {
                        print("\nID \(pdfDocID) Is Already In Use, Generating New PDF File ID\n")
                        pdfDocID = Int.random(in: 0..<100000)
                    }
                }
                
                print("\nNew PDF Document Has An ID of \(pdfDocID)")
                return pdfDocID
            }
            
            // PDF file or PDF document instantiation
            let pdfDocumentInstance = PDFDocument()
            
            for pageNum in 0..<scan.pageCount {
                let image: UIImage = scan.imageOfPage(at: pageNum)
                print("image: \(image)") // for debug only
                
                let pdfPage = PDFPage(image: image)
                pdfDocumentInstance.insert(pdfPage!, at: pageNum)
                
                self.imageArray.append(image)
            }
            
            // make a document id for server side data management
            pdfDocIDExternal = idMaker(pdfListCheck: pdfStoredObjects)
            
            // upload data to server if user is not "Anonymous"
            if activeUser != nil {
                self.serverFileUpload(pdfDocument: pdfDocumentInstance, pdfID: pdfDocIDExternal)
            }
            
            // global list to use in HomeVC
            pdfStoredObjects.append((pdfDocumentInstance, pdfDocIDExternal))
            // temporary list just for thumbnail use for front end display
            var tempList: [PDFDocument] = []
            tempList.append(pdfDocumentInstance)
            listPDFThumbnails.append(((generatePDFThumbnail(currentpdf: tempList.last!)), pdfDocIDExternal))
            
            self.dismiss(animated: true)
            print("\n\nMESAGE:\nImage Has Been Scanned, Number of scans: \(pdfStoredObjects.count)\n\n")
            // switches required to keep track of loading data to HomeVC
            if activeUser != nil {
                scanOrUpload = true
                loadServerData = true
            }
        }
    }
}
