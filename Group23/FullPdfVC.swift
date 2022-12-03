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
        
        uiInteraction.title = currentPDFFileName
    }
    
    
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
//                CODE
            }))
        
        present(controller, animated: true)
    }
}
