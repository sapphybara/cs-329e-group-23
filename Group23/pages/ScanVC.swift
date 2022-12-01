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

var listPDFDocuments: [PDFDocument] = []
var listPDFThumbnails: [UIImage] = []
var pdfStoredObjects: [(PDFDocument, Int)] = []

// firebase db storage setup
private let storageRef = Storage.storage(url:"gs://final-project-group-23.appspot.com/").reference()
//private let urlString = "gs://final-project-group-23.appspot.com/"


//// In development
//// firebase db data retreival
//func serverUserFilesDataRetrieval() -> [PDFDocument] { // Original Header
////func serverUserFilesDataRetrieval() { // Test Header
//    let dbUserFilesRef = storageRef.child("userFiles")
//    var listPDFDocumentsInternal: [PDFDocument] = []
//
//    dbUserFilesRef.listAll{ (result, error) in
//        if let error = error {
//            print(error.localizedDescription)
//        } else {
//
//            print("\nRetrieving DB Data...")
//
//            // this retreives pdfdocuments and file id's from originally given name
//            if result!.items.count > 0 {
//                for item in result!.items {
//                    // get original file id from server-stored name
//                    let strIDNameSearch = String(item.name)
//                    let firstIndex = strIDNameSearch.firstIndex(of: "_")
//                    let firstIndexOneOver = strIDNameSearch.index(after: firstIndex!)
//                    let secondIndex = strIDNameSearch.lastIndex(of: ".")
//                    let range = firstIndexOneOver..<secondIndex!
//                    let tempFileID = Int(strIDNameSearch[range])!
//
//                    // get pdf document from server
//                    let path = dbUserFilesRef.child("\(strIDNameSearch)")
//
//                    path.getData(maxSize: 1024 * 1024) { (data, error) -> Void in
//                        let pdfFileItem = PDFDocument(data: data!)!
//
//                        // pdf tuple array for file management on UI and server side
//                        pdfStoredObjects.append((pdfFileItem, tempFileID))
//
//                        // pdf array for quick UI use access
//                        listPDFDocumentsInternal.append(pdfFileItem)
//                    }
//
////                    downloadTask.observeStatus(.Resume) { (snapshot) -> Void in
////                          print("Downloading has started")
////
////
////                      }
//
//                    print("pdfDocument Retreival Path: \(path)")
//                    print("fileID Retrieved = \"\(tempFileID)\"\n")
//                }
//            } else {
//                print("\nNo Files Stored In Server DB...")
//            }
//        }
//    }
//    return listPDFDocumentsInternal
//}

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
    
    // In development
    // This function retreives data from server
//    func serverUserFilesDataRetrieval() -> [PDFDocument] { // Original Header
    func serverUserFilesDataRetrieval() { // Test Header
        let dbUserFilesRef = storageRef.child("userFiles")
//        let urlStringFirstChild = urlString + "userFiles"
//        var listPDFDocumentsInternal: [PDFDocument] = []
        
        print("\nGetting List of all stored server files.")
        
        dbUserFilesRef.listAll{ (result, error) in
            if let error = error {
                print("\nWARNING: ERROR IN RETREIVING DATA. SEE MESSAGE BELOW - \n\(error.localizedDescription)\n")
            } else {
                
                print("\nRetrieving DB Data...")
                
                // this retreives pdfdocuments and file id's from originally given name
                if result!.items.count > 0 {
                    for item in result!.items {
                        // get original file id from server-stored name
                        let strIDNameSearch = String(item.name)
                        let firstIndex = strIDNameSearch.firstIndex(of: "_")
                        let firstIndexOneOver = strIDNameSearch.index(after: firstIndex!)
                        let secondIndex = strIDNameSearch.lastIndex(of: ".")
                        let range = firstIndexOneOver..<secondIndex!
                        let tempFileID = Int(strIDNameSearch[range])!
                        
                        // get pdf document from server
                        let path = dbUserFilesRef.child("\(strIDNameSearch)")
                        // Failed attempt
//                        let tempServerFileNode = "\(urlStringFirstChild)/\(strIDNameSearch)"
//
//                        let filePath = URL(string: tempServerFileNode)
//
//                        print(tempServerFileNode)
//
//                        let pdfFileItem = try? Data.init(contentsOf: filePath!)
//
//                        print(pdfFileItem!)
                        
                        // Error below, current uncommented code makes a pdfdocument in memory and assigns it to a variable but cannot be put into the global array for some reason and other simliar attempts returned a nil/empty array for Home VC
                        
                        // maxSize is maxSize of INT 64 for swift, just to play it safe
                        path.getData(maxSize: 9223372036854775807) { (data, error) -> Void in
                            print("Getting File...")
                            
//                            let pdfFileItem = PDFDocument()
                            
                            let bytemanager = Data(data!)
//
//                            print("Bytemanager Check: \(bytemanager as NSData)")
//
                            let pdfFileItem = PDFDocument(data: (bytemanager as NSData) as Data)
//
                            print(pdfFileItem!)
                            
                            let pdfFileOut = pdfFileItem!
                            
                            print("pdfFileOut: \(pdfFileOut)")
                            
//                            bytemanager.write(to: pdfFileItem)
                            
//                            let pdfFileItem = PDFDocument(data: data)
                            
//                            print("PDFFileSize: \(String(describing: pdfFileItem.dataRepresentation()))")
                            
                            // pdf tuple array for file management on UI and server side
                            pdfStoredObjects.append((pdfFileOut, tempFileID))
                            
//                            // pdf array for quick UI use access
//                            listPDFDocuments.append(pdfFileItem!)
                        }
                        
                        print("CHECK IN PDF STORED OBJECTS: \(pdfStoredObjects.count)")
                        
    //                    downloadTask.observeStatus(.Resume) { (snapshot) -> Void in
    //                          print("Downloading has started")
    //
    //
    //                      }
                        
                        print("pdfDocument Retreival Path: \(path)")
                        print("fileID Retrieved = \"\(tempFileID)\"\n")
                    }
                } else {
                    print("\nNo Files Stored In Server DB...")
                }
            }
        }
//        return listPDFDocumentsInternal
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
            
            // retrieval does not work yet
            // retreive data from server for synchronized file management for global lists to use in HomeVC
//            listPDFDocuments = self.serverUserFilesDataRetrieval() // Commented out For Home VC Dev
            self.serverUserFilesDataRetrieval() // Test
//            print("\nCount Check 1: \(listPDFDocuments.count)\n")
            
            // global lists to use in HomeVC
            listPDFDocuments.append(pdfDocumentInstance)
            print("\nCount Check 2: \(listPDFDocuments.count)\n")
            
            listPDFThumbnails.append(generatePDFThumbnail(currentpdf: listPDFDocuments.last!))
            
            self.dismiss(animated: true)
            
            // Debug Prints
//            print("imageArray: \(self.imageArray)")
            
            //print("\n\nMESAGE:\nImage Has Been Scanned, Number of scans: \(self.imageArray.count)\n\n")
            print("\n\nMESAGE:\nImage Has Been Scanned, Number of scans: \(listPDFDocuments.count)\n\n")
            
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


