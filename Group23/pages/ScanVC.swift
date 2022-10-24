//
//  ScanVC.swift
//  Group23
//
//  Created by m1 on 06/10/2022.
//

import UIKit
import VisionKit

class ScanVC: UIViewController {
	
	var imageArray: [UIImage] = []
	
	@IBOutlet weak var initialTextLabel1: UILabel!
	@IBOutlet weak var initialTextLabel2: UILabel!
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
	}
	
	override func viewDidAppear(_ animated: Bool) {
		// configureDocumentView()
	}

	@IBAction func cameraButtonPressed(_ sender: UIButton) {
		configureDocumentScanView()
	}
	
	@IBAction func libraryButtonPressed(_ sender: UIButton) {
//		TODO: Upload Files
	}
	
	
	private func configureDocumentScanView() {
		let documentViewVC = VNDocumentCameraViewController()
		documentViewVC.delegate = self
		self.present(documentViewVC, animated: true)
	}
	
}

extension ScanVC:VNDocumentCameraViewControllerDelegate {
	func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
		for pageNum in 0..<scan.pageCount {
			let image = scan.imageOfPage(at: pageNum)
			print("image: \(image)") // for debug only
			self.imageArray.append(image)
		}
		self.dismiss(animated: true)
		print("imageArray: \(imageArray)")

//		Add this to self.dismiss() reload table/collection data after adding to imageArray
//		{
//			DispatchQueue.main.async {
//				self.myCollectionOrTableView.reloadData()
//			}
//		}
		
	}
}


