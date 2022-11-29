//
//  ScanVC.swift
//  Group23
//
//  Created by m1 on 06/10/2022.
//

import UIKit
import VisionKit
import Photos // needed?
import PhotosUI
import PDFKit // Addition for PDF File management - SL

var listPDFDocuments: [PDFDocument] = []
var listPDFThumbnails: [UIImage] = []

class ScanVC: UIViewController {
	
	var imageArray: [UIImage] = []
	
	@IBOutlet weak var initialTextLabel1: UILabel!
	@IBOutlet weak var initialTextLabel2: UILabel!
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}

	// MARK: - Library Upload
	@IBAction func libraryButtonPressed(_ sender: UIButton) {
//		TODO: Upload Files
		let actionSheetAlertController = UIAlertController(
			title: "Select Location",
			message: "Select where to upload from:",
			preferredStyle: .actionSheet
		)
		
		let photoLibraryAction = UIAlertAction(
			title: "Photo Library",
			style: .default,
			handler: {
				(action) in 
				print("\(action.title!) action")
				self.showPicker()
			}
		)
		actionSheetAlertController.addAction(photoLibraryAction)
		
		let fileSystemAction = UIAlertAction(
			title: "File System",
			style: .default,
			handler: {
				(action) in 
				print("\(action.title!) action")
			}
		)
		actionSheetAlertController.addAction(fileSystemAction)
		
		let cancelAction = UIAlertAction(
			title: "Cancel",
			style: .cancel,
			handler: {
				(action) in 
				print("\(action.title!) action")
			}
		)
		actionSheetAlertController.addAction(cancelAction)
		
		present(actionSheetAlertController, animated: true)
		
	}
	
	private func showPicker() {
		var configuration = PHPickerConfiguration(photoLibrary: .shared())
		
		// Set the filter type according to the user’s selection.
		configuration.filter = .all(of: [.images])
		// Set the mode to avoid transcoding, if possible, if your app supports arbitrary image/video encodings.
		configuration.preferredAssetRepresentationMode = .current
		// Set the selection behavior to respect the user’s selection order.
		configuration.selection = .ordered
		// Set the selection limit to enable multiselection.
		configuration.selectionLimit = 0
				
		let picker = PHPickerViewController(configuration: configuration)
		picker.delegate = self
		self.present(picker, animated: true)
	}
	
	
	// MARK: - Scanner Camera View
	@IBAction func cameraButtonPressed(_ sender: UIButton) {
		configureDocumentScanView()
	}

	func imageArrayToDataArray(UIImagesArray: [UIImage]) -> [Data] {
		var imageDataArray = [Data]()
		UIImagesArray.forEach({ (image) in
			if let thisImageData: Data = image.jpegData(compressionQuality: 1) {
				imageDataArray.append(thisImageData)
			}
		})
		return imageDataArray
	}
	
	func imageDataArrayToImageArray(imageDataArray: [Data]) -> [UIImage] {
		var UIImageArray = [UIImage]()
		imageDataArray.forEach({ (imageData) in
			if let thisUIImage: UIImage = UIImage(data: imageData) {
				UIImageArray.append(thisUIImage)
			}
		})
		return UIImageArray
	}
	
	private func configureDocumentScanView() {
		let documentViewVC = VNDocumentCameraViewController()
		documentViewVC.delegate = self
		self.present(documentViewVC, animated: true)
	}
}

extension ScanVC:VNDocumentCameraViewControllerDelegate {
	func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        
        // If there are no pdf scans then proceed with else
        guard scan.pageCount >= 1 else {
            controller.dismiss(animated: true)
            return
        }
        
        // Multithreading for PDF Scan Where Number Of Scans >= 1
        DispatchQueue.main.async {
            let pdfDocumentInstance = PDFDocument()
            
            for pageNum in 0..<scan.pageCount {
                let image: UIImage = scan.imageOfPage(at: pageNum)
                print("image: \(image)") // for debug only
                
                let pdfPage = PDFPage(image: image)
                pdfDocumentInstance.insert(pdfPage!, at: pageNum)
                
                self.imageArray.append(image)
                
            }
            // global lists to use in HomeVC
            listPDFDocuments.append(pdfDocumentInstance)
            
            listPDFThumbnails.append(generatePDFThumbnail(currentpdf: listPDFDocuments.last!))
            
            // Code to go from PDF > png/jpeg > xc data storage will go here
            
            self.dismiss(animated: true)
            
            // Debug Prints
//            print("imageArray: \(self.imageArray)")
            
            //print("\n\nMESAGE:\nImage Has Been Scanned, Number of scans: \(self.imageArray.count)\n\n")
            print("\n\nMESAGE:\nImage Has Been Scanned, Number of scans: \(listPDFDocuments.count)\n\n")
            // Save PDF Data to XC Data Below...
            
            //function to turn pdf into thumbnail image
            func generatePDFThumbnail(currentpdf: PDFDocument) -> UIImage {
                let pdfDocumentCover = currentpdf.page(at: 0)
                let thumbnailSize = CGSize(width: 130, height: 200)
                return (pdfDocumentCover?.thumbnail(of: thumbnailSize, for: .mediaBox))!
            }
            
        }

//		Add this to self.dismiss() reload table/collection data after adding to imageArray
//		{
//			DispatchQueue.main.async {
//				self.myCollectionOrTableView.reloadData()
//			}
//		}
		
	}
}

// Max can you explain what is happening in the code below and/or convert library image to PDFDocument objects?
extension ScanVC:PHPickerViewControllerDelegate {
	func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
		dismiss(animated: true)
		let itemProviders = results.map(\.itemProvider)
		for item in itemProviders {
			if item.canLoadObject(ofClass: UIImage.self) {
				item.loadObject(ofClass: UIImage.self) { (image, error) in
					DispatchQueue.main.async {
						if let image = image as? UIImage {
							self.imageArray.append(image)
							print(self.imageArray)
						}
					}
				}
			}
		}
	}
}


