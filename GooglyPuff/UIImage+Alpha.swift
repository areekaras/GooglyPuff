

import UIKit

extension UIImage {
    var hasAlpha: Bool {
        guard let cgImage = self.cgImage else {
            return false
        }
        let alpha = cgImage.alphaInfo
        return alpha == .first || alpha == .last || alpha == .premultipliedFirst || alpha == .premultipliedLast
    }
    
    func imageWithAlpha() -> UIImage {
        if hasAlpha {
            return self
        }
        
        let scale = max(self.scale, 1)
        guard let imageRef = self.cgImage, let colorSpace = imageRef.colorSpace else {
            return self
        }
        let width = imageRef.width * Int(scale)
        let height = imageRef.height * Int(scale)
        
        guard
            let offscreenContext = CGContext(
                data: nil,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: 0,
                space: colorSpace,
                bitmapInfo: UInt32(CGBitmapInfo.alphaInfoMask.rawValue) & UInt32(CGImageAlphaInfo.premultipliedLast.rawValue)
            )
        else {
            return self
        }
        
        offscreenContext.draw(imageRef, in: CGRect(x: 0, y: 0, width: width, height: height))
        guard let imageRefWithAlpha = offscreenContext.makeImage() else {
            return self
        }
        return UIImage(cgImage: imageRefWithAlpha, scale: self.scale, orientation: .up)
    }
    
    func transparentBorderImage(borderSize: CGFloat) -> UIImage {
        let image = imageWithAlpha()
        let scale = max(self.scale, 1)
        let scaledBorderSize = borderSize * scale
        let newRect = CGRect(
            x: 0,
            y: 0,
            width: image.size.width * scale + scaledBorderSize * 2,
            height: image.size.height * scale + scaledBorderSize * 2
        )
        guard let imageRef = self.cgImage, let colorSpace = imageRef.colorSpace else {
            return self
        }
        guard
            let bitmap = CGContext(
                data: nil,
                width: Int(newRect.size.width),
                height: Int(newRect.size.height),
                bitsPerComponent: imageRef.bitsPerComponent,
                bytesPerRow: imageRef.bytesPerRow,
                space: colorSpace,
                bitmapInfo: imageRef.bitmapInfo.rawValue
            )
        else {
            return self
        }
        
        let imageLocation = CGRect(
            x: scaledBorderSize,
            y: scaledBorderSize,
            width: image.size.width * scale,
            height: image.size.height * scale
        )
        bitmap.draw(imageRef, in: imageLocation)
        guard let borderImageRef = bitmap.makeImage() else {
            return self
        }
        
        guard
            let maskImageRef = newBorderMask(borderSize: scaledBorderSize, size: newRect.size),
            let transparentBorderImageRef = borderImageRef.masking(maskImageRef)
        else {
            return self
        }
        return UIImage(cgImage: transparentBorderImageRef, scale: self.scale, orientation: .up)
    }
    
    func newBorderMask(borderSize: CGFloat, size: CGSize) -> CGImage? {
        let colorSpace = CGColorSpaceCreateDeviceGray()
        
        guard
            let maskContext = CGContext(
                data: nil,
                width: Int(size.width),
                height: Int(size.height),
                bitsPerComponent: 8,
                bytesPerRow: 8,
                space: colorSpace,
                bitmapInfo: UInt32(CGImageAlphaInfo.none.rawValue)
            )
        else {
            return nil
        }
        
        maskContext.setFillColor(UIColor.black.cgColor)
        maskContext.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        maskContext.setFillColor(UIColor.white.cgColor)
        maskContext.fill(
            CGRect(
                x: borderSize,
                y: borderSize,
                width: size.width - borderSize * 2,
                height: size.height - borderSize * 2
            )
        )
        
        return maskContext.makeImage()
    }
}
