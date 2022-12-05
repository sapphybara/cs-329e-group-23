//
//  ScanVC.swift
//  Group23
//
//  Created by Warren Wiser on 06/10/2022.
//

import UIKit
import VisionKit
import PhotosUI
import PDFKit
import FirebaseAuth
import FirebaseStorage

// global arrays needed for application functionality
var listPDFThumbnails: [(UIImage, Int)] = []
var pdfStoredObjects: [(PDFDocument, Int)] = []

// switches to load/reload logged-in user data globally
var scanOrUpload = false
var loadServerData = true

// firebase db storage setup
private let storageRef = Storage.storage(url:"gs://final-project-group-23.appspot.com/").reference()

/// Fetches all server files associated with user
/// - Parameters:
///     - completion: function to call once data has been fetched
func serverUserFilesDataRetrieval(completion: @escaping () -> Void) {
    // if user is logged in, load their data, else don't save data
    if let user = activeUser {
        // server bucket reference for user data
        let dbUserFilesRef = storageRef.child("userFiles/\(user.email!)")
        
        // retrieve files asynchronously without need for function to be async
        // using a Task is important for this, as user file interactions are often called in synchronous lifecycle methods
        Task {
            // specify the task to run async on the main thread, so UI updates can be made
            do {
                // this async retrieves all pdfdocuments from server side and file id's from original file names
                let userFiles = try await dbUserFilesRef.listAll()
                userFiles.items.forEach { item in
                    var dataCheckArray: [Int] = []
                    
                    // array to check and not add duplicate objects
                    for itemCheck in pdfStoredObjects {
                        dataCheckArray.append(itemCheck.1)
                    }
                    // get original file id from server-stored name
                    let strIDNameSearch = String(item.name)
                    let firstIndex = strIDNameSearch.firstIndex(of: "_")
                    let firstIndexOneOver = strIDNameSearch.index(after: firstIndex!)
                    let secondIndex = strIDNameSearch.lastIndex(of: ".")
                    let range = firstIndexOneOver..<secondIndex!
                    let tempFileID = Int(strIDNameSearch[range])!
                    
                    // if items are already in the listPDFDocuments Array, skip readdition, otherwise add data to global array
                    if !dataCheckArray.contains(tempFileID) {
                        // get pdf document from server
                        let path = dbUserFilesRef.child("\(strIDNameSearch)")
                        
                        // maxSize is maxSize of INT 64 for swift, just to play it safe
                        path.getData(maxSize: 9223372036854775807) { (data, error) -> Void in
                            
                            let bytemanager = Data(data!)
                            
                            let pdfFileItem = PDFDocument(data: (bytemanager as NSData) as Data)
                            if let pdfFileOut = pdfFileItem {
                                // pdf tuple array for file management on UI and server side
                                pdfStoredObjects.append((pdfFileOut, tempFileID))
                                if allowHaptics{
                                    let generator = UINotificationFeedbackGenerator()
                                    generator.notificationOccurred(.success)
                                }
                                
                                // regenerate all thumbnails once the data is loaded in
                                var tempList: [PDFDocument] = []
                                tempList.append(pdfFileOut)
                                // regenerate all thumbnails once the data is loaded in
                                listPDFThumbnails.append(((generatePDFThumbnail(currentpdf: tempList.last!)), tempFileID))
                                // run the completion on the main thread, as it is a UI element
                                DispatchQueue.main.async {
                                    completion()
                                }
                            }
                        }
                    }
                }
            } catch {
                print("\nWARNING: ERROR IN RETREIVING DATA. SEE MESSAGE BELOW - \n\(error.localizedDescription)\n")
            }
        }
    } else {
        print("\nUser Is Anonymous, No Data To Get From Server DB...")
        completion()
    }
}

/// This deletes file(s) on the server, syncing with the UI on completion
/// - Parameters:
///     - tempFileDeletionIDs: the id's of the files to delete
///     - completion: the function to all once the deletion is complete
func deleteUserFiles(tempFileDeletionIDs: [Int], completion: @escaping () -> Void) {
    // if user is logged in, synchronize server file deletion with local file deletion
    if let user = activeUser {
        Task {
            var pdfObjectsToDelete: [(PDFDocument, Int)] = []
            let dbUserFilesRef = storageRef.child("userFiles/\(user.email!)")
            // server bucket reference for user data
            
            
            // get objects to delete from application
            for pdfStoredObject in pdfStoredObjects {
                if tempFileDeletionIDs.contains(pdfStoredObject.1) {
                    pdfObjectsToDelete.append(pdfStoredObject)
                }
            }
            
            for (i, (_, id)) in pdfObjectsToDelete.enumerated() {
                let tempRefServerNode = dbUserFilesRef.child("File_\(id).pdf")
                
                //server data deletion
                do {
                    try await tempRefServerNode.delete()
                    print("~File_\(id).pdf Was Successfully Deleted On The Server Side~")
                } catch {
                    print("\nWARNING: THERE WAS AN ERROR IN DELETING YOUR DATA. SEE MESSAGE BELOW - \n\(error.localizedDescription)\n")
                }
                if i >= pdfObjectsToDelete.count - 1 {
                    // main thread for UI updates
                    DispatchQueue.main.async {
                        completion()
                    }
                }
            }
            
            for pdfObjectToDelete in pdfObjectsToDelete {
                pdfStoredObjects.removeAll(where: {$1 == pdfObjectToDelete.1})
                listPDFThumbnails.removeAll(where: {$1 == pdfObjectToDelete.1})
            }
        }
    } else {
        // Anonymous user, invalid server data synchronization, therefore only delete local application data
        Task {
            var pdfObjectsToDelete: [(PDFDocument, Int)] = []
            
            // get objects to delete from application
            for pdfStoredObject in pdfStoredObjects {
                if tempFileDeletionIDs.contains(pdfStoredObject.1) {
                    pdfObjectsToDelete.append(pdfStoredObject)
                }
            }
            
            // deletes local Anonymous user uploaded file(s)
            for pdfObjectToDelete in pdfObjectsToDelete {
                pdfStoredObjects.removeAll(where: {$1 == pdfObjectToDelete.1})
                listPDFThumbnails.removeAll(where: {$1 == pdfObjectToDelete.1})
            }
            // main thread for UI
            DispatchQueue.main.async {
                completion()
            }
        }
    }
}

/// creates a thumbnail image for a given pdf
/// - Parameters:
///     - currentpdf: the pdf from which to create a thumbnail
func generatePDFThumbnail(currentpdf: PDFDocument) -> UIImage {
    let pdfDocumentCover = currentpdf.page(at: 0)
    let thumbnailSize = CGSize(width: 130, height: 200)
    return (pdfDocumentCover?.thumbnail(of: thumbnailSize, for: .mediaBox))!
}

class ScanVC: UIViewController {
    
    var imageArray: [UIImage] = []
    var currentStorageRef = storageRef
    
    @IBOutlet weak var initialTextLabel1: UILabel!
    @IBOutlet weak var initialTextLabel2: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(recognizeSwipeGesture(recognizer:)))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        self.view.addGestureRecognizer(swipeLeft)
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(recognizeSwipeGesture(recognizer:)))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        self.view.addGestureRecognizer(swipeRight)
    }
    @IBAction func recognizeSwipeGesture(recognizer: UISwipeGestureRecognizer)
    {
        if recognizer.direction == .left{
            print("swiped left")
            self.tabBarController?.selectedIndex += 1
        }
        if recognizer.direction == .right{
            print("swiped right")
            self.tabBarController?.selectedIndex -= 1
        }
    }
    
    // MARK: - Library Upload
    @IBAction func libraryButtonPressed(_ sender: UIButton) {
        self.showPicker()
    }
    
    private func showPicker() {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        
        // Set the filter type according to the user’s selection.
        //        configuration.filter = .all(of: [.images])
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

extension ScanVC: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        var UIImageArray: [UIImage] = []
        let itemProviders = results.map(\.itemProvider)
        var imageCounter = 0
        let imagesLength = itemProviders.count
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
            
            // upload data to server if user is not "Anonymous"
            if activeUser != nil {
                self.serverFileUpload(pdfDocument: pdfDocumentInstance, pdfID: pdfDocIDExternal)
            }
            
            // global list to use in HomeVC
            pdfStoredObjects.append((pdfDocumentInstance, pdfDocIDExternal))
            if allowHaptics{
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
            }
            
            // temporary list just for thumbnail use for front end display
            var tempList: [PDFDocument] = []
            tempList.append(pdfDocumentInstance)
            listPDFThumbnails.append(((generatePDFThumbnail(currentpdf: tempList.last!)), pdfDocIDExternal))
            self.dismiss(animated: true)
            
            // switches required to keep track of loading data to HomeVC
            if activeUser != nil {
                scanOrUpload = true
                loadServerData = true
            }
        }
    }
}
