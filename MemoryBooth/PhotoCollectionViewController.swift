//
//  PhotoCollectionViewController.swift
//  MemoryBooth
//
//  Created by Wayne Rumble on 23/03/2017.
//  Copyright © 2017 Wayne Rumble. All rights reserved.
//

import UIKit

class PhotoCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate {
    
    let sectionInsets = UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0.0, right: 10.0)
    let itemsPerRow: CGFloat = 2
    
    var selectedImage = UIImageView()
    var selectedImagesArray = [URL]()
    var selectedImageBackgroundView = UIView()
    var selectedArray = [Bool]()
    var imagesURLArray: [URL]!
    var pan: UIPanGestureRecognizer!
    var pinch: UIPinchGestureRecognizer!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var activityIndicatorLabel: UILabel!
    @IBOutlet weak var activityIndicatorBackGroundView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createSelectedArray()
        setActivityViews()
        setCollectionView()
        setGestureRecognizers()
        setButton()
    }
    
    func createSelectedArray() {
        
        for _ in 0...imagesURLArray.count {
            
            selectedArray.append(false)
        }
    }
    
    func setActivityViews() {
        
        activityIndicator.isHidden = true
        
        activityIndicatorLabel.isHidden = true
        activityIndicatorLabel.text = "Saving to Photo Library..."
        
        activityIndicatorBackGroundView.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        activityIndicatorBackGroundView.isHidden = true
    }
    
    func setButton() {
        
        downloadButton.isHidden = false
        downloadButton.backgroundColor = UIColor.darkGray.withAlphaComponent(0.7)
    }
    
    func setCollectionView() {
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return imagesURLArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCell
        let tap = UITapGestureRecognizer(target: self, action: #selector(checkmarkWasTapped(_ :)))
        
        cell.backgroundColor = .clear
        cell.imageView.image = UIImage(contentsOfFile: imagesURLArray[indexPath.row].path)
        cell.checkmarkView.checkMarkStyle = .GrayedOut
        cell.checkmarkView.tag = indexPath.row
        cell.checkmarkView.addGestureRecognizer(tap)
        
        if !selectedArray[indexPath.row] {
            
            cell.checkmarkView.checked = false
        } else {
            
            cell.checkmarkView.checked = true
        }
        
        
        return cell
    }
    
    func checkmarkWasTapped(_ sender: UIGestureRecognizer) {
        
        let checkmarkView = sender.view as! SSCheckMark
        let indexPath = IndexPath(row: checkmarkView.tag, section: 0)
        
        let imageURL = imagesURLArray[indexPath.row]
        
        if checkmarkView.checked == true {
            
            checkmarkView.checked = false
            selectedArray[indexPath.row] = false
            selectedImagesArray.remove(at: selectedImagesArray.index(of: imageURL)!)
        } else {
            
            checkmarkView.checked = true
            selectedArray[indexPath.row] = true
            selectedImagesArray.append(imageURL)
        }
        
        collectionView.reloadItems(at: [indexPath])
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return sectionInsets.left
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        addZoomedImage(indexPath.row)
        addGestureToImage()
        addBackGroundView()
        
        view.addSubview(selectedImage)
    }
    
    func addZoomedImage(_ indexPath: Int) {
        
        selectedImage.image = UIImage(contentsOfFile: imagesURLArray[indexPath].path)
        selectedImage.frame = view.frame
        
        setImage()
    }
    
    func setImage() {
        
        selectedImage.contentMode = .scaleAspectFit
        selectedImage.isUserInteractionEnabled = true
    }
    
    func addGestureToImage() {
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissImage))
        
        selectedImage.addGestureRecognizer(tap)
        selectedImage.addGestureRecognizer(pinch)
        selectedImage.addGestureRecognizer(pan)
    }
    
    func addBackGroundView() {
        
        selectedImageBackgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        selectedImageBackgroundView.frame = view.frame
        
        view.addSubview(selectedImageBackgroundView)
    }
    
    func dismissImage() {
        
        selectedImageBackgroundView.removeFromSuperview()
        selectedImage.removeFromSuperview()
    }
    
    @IBAction func downloadButtonWasTapped(_ sender: UIButton) {
        
        
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        activityIndicatorLabel.isHidden = false
        activityIndicatorBackGroundView.isHidden = false
        
        DispatchQueue.global(qos: .background).async { [weak weakSelf = self] in
            
            weakSelf?.selectedImagesArray.forEach { image in
                
                let watermarkedImage = weakSelf?.addWatermark(image: UIImage(contentsOfFile: image.path)!)
                
                let imageRepresentation = UIImageJPEGRepresentation(watermarkedImage!, 0.25)
                let imageData = UIImage(data: imageRepresentation!)
                
                UIImageWriteToSavedPhotosAlbum(imageData!, nil, nil, nil)
            }
            
            DispatchQueue.main.sync {
                
                self.activityIndicator.isHidden = true
                self.activityIndicatorLabel.isHidden = true
                self.activityIndicator.stopAnimating()
                
                let alert = UIAlertController(title: "Success", message: nil, preferredStyle: .alert)
                let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
                
                self.activityIndicatorBackGroundView.isHidden = true
            }
        }
    }
    
    func addWatermark(image: UIImage) -> UIImage {
        
        let height = image.size.width * 0.2
        let width = image.size.width * 0.2
        let originalImage = UIImageView()
        
        originalImage.frame.size = image.size
        let waterMark = UIImageView()
        
        originalImage.contentMode = .scaleToFill
        originalImage.image = image
        
        
        waterMark.frame = CGRect(x: 15, y: 15, width: width, height: height)
        waterMark.image = UIImage(named: "MemoryBoothLogo")
        waterMark.contentMode = .scaleAspectFit
        
        originalImage.addSubview(waterMark)
        UIGraphicsBeginImageContext(originalImage.frame.size)
        originalImage.layer.render(in: UIGraphicsGetCurrentContext()!)
        
        let waterMarkedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return waterMarkedImage
    }
}
