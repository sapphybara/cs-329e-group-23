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
import PDFKit
import FirebaseAuth
import FirebaseCore
import FirebaseStorage // Addition for PDF File management - SL

// global arrays needed for application functionality
var listPDFThumbnails: [UIImage] = []
var pdfStoredObjects: [(PDFDocument, Int)] = []

// switches to load/reload data globally
var scanOrUpload = false
var loadServerData = true

// firebase db storage setup
private let storageRef = Storage.storage(url:"gs://final-project-group-23.appspot.com/").reference()

// This function retrives all server data created by the user
func serverUserFilesDataRetrieval() {
    // server bucket reference
    let dbUserFilesRef = storageRef.child("userFiles")
    
    print("\nGetting List of all stored server files.")
    
    dbUserFilesRef.listAll{ (result, error) in
        if let error = error {
            print("\nWARNING: ERROR IN RETREIVING DATA. SEE MESSAGE BELOW - \n\(error.localizedDescription)\n")
        } else {
            
            print("\nRetrieving DB Data...")
            
            var dataCheckArray: [Int] = []
            
            // array to check and not add duplicate objects
            for itemCheck in pdfStoredObjects {
                dataCheckArray.append(itemCheck.1)
            }
            
            // this retreives all pdfdocuments from server side and file id's from original file names
            if result.items.count > 0 {
                for item in result.items {
                    // get original file id from server-stored name
                    let strIDNameSearch = String(item.name)
                    let firstIndex = strIDNameSearch.firstIndex(of: "_")
                    let firstIndexOneOver = strIDNameSearch.index(after: firstIndex!)
                    let secondIndex = strIDNameSearch.lastIndex(of: ".")
                    let range = firstIndexOneOver..<secondIndex!
                    let tempFileID = Int(strIDNameSearch[range])!
                    
                    print("-Attempting to add file with ID: \(tempFileID)-")
                    // if items are already in the listPDFDocuments Array, skip readdition, otherwise add data to global array
                    if dataCheckArray.contains(tempFileID) {
                        print("-DUPLICATE ID FOUND: FILE WITH ID \"\(tempFileID)\" WAS SKIPPED-")
                    } else {
                        // get pdf document from server
                        let path = dbUserFilesRef.child("\(strIDNameSearch)")
                        
                        // maxSize is maxSize of INT 64 for swift, just to play it safe
                        path.getData(maxSize: 9223372036854775807) { (data, error) -> Void in
                            print("Getting File...")
                            
                            let bytemanager = Data(data!)
                            
                            let pdfFileItem = PDFDocument(data: (bytemanager as NSData) as Data)
                            
//                            print(pdfFileItem!)
                            
                            let pdfFileOut = pdfFileItem!
                            
                            print("pdfFileOut: \(pdfFileOut)")
                            
                            // pdf tuple array for file management on UI and server side
                            pdfStoredObjects.append((pdfFileOut, tempFileID))
                            
                            // regenerate all thumbnails once the data is loaded in
                            var tempList: [PDFDocument] = []
                            
                            tempList.append(pdfFileOut)
                            
                            listPDFThumbnails.append(generatePDFThumbnail(currentpdf: tempList.last!))
                        }
                        
                        print("CHECK IN PDF STORED OBJECTS: \(pdfStoredObjects.count)")
                        print("pdfDocument Retreival Path: \(path)")
                        print("fileID Retrieved = \"\(tempFileID)\"\n")
                    }
                }
            } else {
                print("\nNo Files Stored In Server DB...")
            }
        }
    }
}

//function to turn pdf into thumbnail image
func generatePDFThumbnail(currentpdf: PDFDocument) -> UIImage {
    let pdfDocumentCover = currentpdf.page(at: 0)
    let thumbnailSize = CGSize(width: 130, height: 200)
    return (pdfDocumentCover?.thumbnail(of: thumbnailSize, for: .mediaBox))!
}

class ScanVC: UIViewController {
	
	var imageArray: [UIImage] = []
	
	@IBOutlet weak var initialTextLabel1: UILabel!
	@IBOutlet weak var initialTextLabel2: UILabel!
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}

	// MARK: - Library Upload
	@IBAction func libraryButtonPressed(_ sender: UIButton) {
		self.showPicker()
	}
	
	private func showPicker() {
		var configuration = PHPickerConfiguration(photoLibrary: .shared())
		
		// Set the filter type according to the user’s selection.
//		configuration.filter = .all(of: [.images])
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
    // This function uploads data to server
    func serverFileUpload(pdfDocument: PDFDocument, pdfID: Int) {
        let pdfRef = storageRef.child("userFiles/File_\(pdfID).pdf")
        
        print("\nUploading Instantiated Document...")
        
        // Upload the file to the path "images/rivers.jpg"
        _ = pdfRef.putData(pdfDocument.dataRepresentation()!, metadata: nil)
    }
    
	func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        
        // If there are no pdf scans then proceed with else
        guard scan.pageCount >= 1 else {
            controller.dismiss(animated: true)
            return
        }
        
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
            
            // upload data to server - this works and has been tested and verified
            self.serverFileUpload(pdfDocument: pdfDocumentInstance, pdfID: pdfDocIDExternal)
            
            // global list to use in HomeVC
            pdfStoredObjects.append((pdfDocumentInstance, pdfDocIDExternal))
            
            // temporary list just for thumbnail use for front end display
            var tempList: [PDFDocument] = []
            
            tempList.append(pdfDocumentInstance)
            
            listPDFThumbnails.append(generatePDFThumbnail(currentpdf: tempList.last!))
            
            self.dismiss(animated: true)
            
            // Debug Prints
//            print("imageArray: \(self.imageArray)")
            
            //print("\n\nMESAGE:\nImage Has Been Scanned, Number of scans: \(self.imageArray.count)\n\n")
            print("\n\nMESAGE:\nImage Has Been Scanned, Number of scans: \(pdfStoredObjects.count)\n\n")
            
            // switch required to keep track of loading data to HomeVC
            scanOrUpload = true
            loadServerData = true
        }

//		Add this to self.dismiss() to reload table/collection data after adding to imageArray
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
		var UIImageArray: [UIImage] = []
		let itemProviders = results.map(\.itemProvider)
		var imageCounter = 0
		var imagesLength = itemProviders.count
		for item in itemProviders {
			if item.canLoadObject(ofClass: UIImage.self) {
				item.loadObject(ofClass: UIImage.self) { (image, error) in
					if let image = image as? UIImage {
						UIImageArray.append(image)
						print("inner: \(UIImageArray)")
						
						imageCounter += 1
						if imageCounter == imagesLength {
							self.makePDF(UIImageArray)
						}
					}
				}
			}
		}
	}
	
	func makePDF(_ UIImages: [UIImage]) {
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
			
			for pageNum in 0..<UIImages.count {
				let image: UIImage = UIImages[pageNum]
				print("image: \(image)") // for debug only
				
				let pdfPage = PDFPage(image: image)
				pdfDocumentInstance.insert(pdfPage!, at: pageNum)
				
				self.imageArray.append(image)
				
			}
			
			// make a document id for server side data management
			pdfDocIDExternal = idMaker(pdfListCheck: pdfStoredObjects)
			
			// upload data to server - this works and has been tested and verified
			self.serverFileUpload(pdfDocument: pdfDocumentInstance, pdfID: pdfDocIDExternal)
			
			// global list to use in HomeVC
            pdfStoredObjects.append((pdfDocumentInstance, pdfDocIDExternal))
            
            // temporary list just for thumbnail use for front end display
            var tempList: [PDFDocument] = []
            
            tempList.append(pdfDocumentInstance)
            
            listPDFThumbnails.append(generatePDFThumbnail(currentpdf: tempList.last!))
			
			self.dismiss(animated: true)
			
			// Debug Prints
//            print("imageArray: \(self.imageArray)")
			
			//print("\n\nMESAGE:\nImage Has Been Scanned, Number of scans: \(self.imageArray.count)\n\n")
			print("\n\nMESAGE:\nImage Has Been Scanned, Number of scans: \(pdfStoredObjects.count)\n\n")
            
            scanOrUpload = true
            loadServerData = true
		}
	}
}


