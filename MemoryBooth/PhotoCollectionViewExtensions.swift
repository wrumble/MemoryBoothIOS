//
//  PinchAndPan.swift
//  MemoryBooth
//
//  Created by Wayne Rumble on 24/03/2017.
//  Copyright © 2017 Wayne Rumble. All rights reserved.
//

import UIKit

extension PhotoCollectionViewController {
    
    func setGestureRecognizers() {
        
        pan = UIPanGestureRecognizer(target: self, action: #selector(self.panGestureDetected))
        pinch = UIPinchGestureRecognizer(target: self, action: #selector(self.pinchGestureDetected))
        
        pan.delegate = self
        pinch.delegate = self
    }
    
    //Allow pan movements on image
    func panGestureDetected(_ recognizer: UIPanGestureRecognizer) {
        
        let state: UIGestureRecognizerState = recognizer.state
        
        if state == .began || state == .changed {
            
            let translation: CGPoint = recognizer.translation(in: recognizer.view)
            recognizer.view?.transform = (recognizer.view?.transform.translatedBy(x: translation.x, y: translation.y))!
            recognizer.setTranslation(CGPoint.zero, in: recognizer.view)
        }
    }
    
    //Allow pinch movements on image
    func pinchGestureDetected(_ recognizer: UIPinchGestureRecognizer) {
        
        let state: UIGestureRecognizerState = recognizer.state
        
        if state == .began || state == .changed {
            
            let scale: CGFloat = recognizer.scale
            recognizer.view?.transform = (recognizer.view?.transform.scaledBy(x: scale, y: scale))!
            recognizer.scale = 1.0
        }
    }
    
    //Recognise multiple gestures
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
    }
}
