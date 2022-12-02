//
//  FullPdfVC.swift
//  Group23
//
//  Created by Corey Zhang on 12/1/22.
//

import UIKit
import PDFKit

class FullPdfVC: UIViewController {

    var currentPDF: PDFDocument?
    
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
        // Do any additional setup after loading the view.
    }
       
    
    

}
