//
//  FullPdfVC.swift
//  Group23
//
//  Created by Corey Zhang on 12/1/22.
//

import UIKit
import PDFKit

class FullPdfVC: UIViewController {

    @IBOutlet weak var uiInteraction: UINavigationItem!
    
    var currentPDF: PDFDocument?
    var currentPDFFileName: String = ""
    var pdfIDInternal: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Add PDFView to view controller.
        let pdfView = PDFView(frame: self.view.bounds)
        pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(pdfView)

        // Fit content in PDFView.
        pdfView.autoScales = true

        pdfView.document = currentPDF
        //pdfView.contentMode
        
        // title of file in display in single view mode
        uiInteraction.title = currentPDFFileName
    }
    
    // delete pdf file in single view mode
    @IBAction func deleteIndividualFile(_ sender: Any) {
        let controller = UIAlertController(
            title: "Delete File",
            message: "Do You Want To Delete \(currentPDFFileName)?",
            preferredStyle: .alert)
        
        controller.addAction(UIAlertAction(
            title: "Cancel",
            style: .cancel))
        
        controller.addAction(UIAlertAction(
            title: "Delete PDF File",
            style: .destructive,
            handler: {_ in
                // delete data with request to server
                filestToDelete.append(self.pdfIDInternal)
                
                // make request with server and delete file
                deleteUserFiles(tempFileDeletionIDs: filestToDelete)
                
                // pop VC
                self.navigationController?.popViewController(animated: true)
            }))
        
        present(controller, animated: true)
    }
}
