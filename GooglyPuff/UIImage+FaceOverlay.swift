

import UIKit

extension UIImage {
    private enum ScaleFactor {
        static let retinaToEye: CGFloat = 0.5
        static let faceBoundsToEye: CGFloat = 4.0
    }
    
    func faceOverlayImageFrom() -> UIImage? {
        guard
            let detector = CIDetector(
                ofType: CIDetectorTypeFace,
                context: nil,
                options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]
            )
        else {
            return nil
        }
        
        // Get features from the image
        guard let cgImage = cgImage else {
            return nil
        }
        let newImage = CIImage(cgImage: cgImage)
        guard let features = detector.features(in: newImage) as? [CIFaceFeature] else {
            return nil
        }
        
        UIGraphicsBeginImageContext(size)
        let imageRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        // Draws this in the upper left coordinate system
        draw(in: imageRect, blendMode: .normal, alpha: 1.0)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        for faceFeature in features {
            let faceRect = faceFeature.bounds
            context.saveGState()
            
            // CI and CG work in different coordinate systems, we should translate to
            // the correct one so we don't get mixed up when calculating the face position.
            context.translateBy(x: 0.0, y: imageRect.size.height)
            context.scaleBy(x: 1.0, y: -1.0)
            
            if faceFeature.hasLeftEyePosition {
                let leftEyePosition = faceFeature.leftEyePosition
                let eyeWidth = faceRect.size.width / ScaleFactor.faceBoundsToEye
                let eyeHeight = faceRect.size.height / ScaleFactor.faceBoundsToEye
                let eyeRect = CGRect(
                    x: leftEyePosition.x - eyeWidth / 2.0,
                    y: leftEyePosition.y - eyeHeight / 2.0,
                    width: eyeWidth,
                    height: eyeHeight
                )
                drawEyeBallForFrame(eyeRect)
            }
            
            if faceFeature.hasRightEyePosition {
                let leftEyePosition = faceFeature.rightEyePosition
                let eyeWidth = faceRect.size.width / ScaleFactor.faceBoundsToEye
                let eyeHeight = faceRect.size.height / ScaleFactor.faceBoundsToEye
                let eyeRect = CGRect(
                    x: leftEyePosition.x - eyeWidth / 2.0,
                    y: leftEyePosition.y - eyeHeight / 2.0,
                    width: eyeWidth,
                    height: eyeHeight
                )
                drawEyeBallForFrame(eyeRect)
            }
            
            context.restoreGState()
        }
        
        let overlayImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return overlayImage
    }
    
    func faceRotationInRadians(leftEyePoint startPoint: CGPoint, rightEyePoint endPoint: CGPoint) -> CGFloat {
        let deltaX = endPoint.x - startPoint.x
        let deltaY = endPoint.y - startPoint.y
        let angleInRadians = CGFloat(atan2f(Float(deltaY), Float(deltaX)))
        
        return angleInRadians
    }
    
    func drawEyeBallForFrame(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.addEllipse(in: rect)
        context?.setFillColor(UIColor.white.cgColor)
        context?.fillPath()
        
        let eyeSizeWidth = rect.size.width * ScaleFactor.retinaToEye
        let eyeSizeHeight = rect.size.height * ScaleFactor.retinaToEye
        
        var x = CGFloat.random(in: 0...CGFloat(rect.size.width - eyeSizeWidth))
        var y = CGFloat.random(in: 0...CGFloat(rect.size.height - eyeSizeHeight))
        x += rect.origin.x
        y += rect.origin.y
        
        let eyeSize = min(eyeSizeWidth, eyeSizeHeight)
        let eyeBallRect = CGRect(x: x, y: y, width: eyeSize, height: eyeSize)
        context?.addEllipse(in: eyeBallRect)
        context?.setFillColor(UIColor.black.cgColor)
        context?.fillPath()
    }
}
