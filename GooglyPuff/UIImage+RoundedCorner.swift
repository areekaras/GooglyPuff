

import UIKit

extension UIImage {
    func roundedCornerImage(cornerSize: CGFloat, borderSize: CGFloat) -> UIImage {
        let image = imageWithAlpha()
        let scale = max(self.scale, 1.0)
        let scaledBorderSize = CGFloat(borderSize) * scale
        
        guard let imageRef = cgImage, let colorSpace = imageRef.colorSpace else {
            return self
        }
        
        guard
            let context = CGContext(
                data: nil,
                width: Int(image.size.width * scale),
                height: Int(image.size.height * scale),
                bitsPerComponent: imageRef.bitsPerComponent,
                bytesPerRow: 0,
                space: colorSpace,
                bitmapInfo: imageRef.bitmapInfo.rawValue
            )
        else {
            return self
        }
        
        context.beginPath()
        addRoundedRectToPath(
            rect: CGRect(
                x: scaledBorderSize,
                y: scaledBorderSize,
                width: image.size.width * scale,
                height: image.size.height * scale
            ),
            context: context,
            ovalWidth: cornerSize * scale,
            ovalHeight: cornerSize * scale
        )
        context.closePath()
        context.clip()
        
        context.draw(imageRef, in: CGRect(x: 0, y: 0, width: image.size.width * scale, height: image.size.height * scale))
        guard let clippedImage = context.makeImage() else {
            return self
        }
        
        return UIImage(cgImage: clippedImage, scale: self.scale, orientation: .up)
    }
    
    func addRoundedRectToPath(rect: CGRect, context: CGContext, ovalWidth: CGFloat, ovalHeight: CGFloat) {
        if ovalWidth == 0 || ovalHeight == 0 {
            context.addRect(rect)
            return
        }
        context.saveGState()
        context.translateBy(x: rect.minX, y: rect.minY)
        context.scaleBy(x: ovalWidth, y: ovalHeight)
        let width = rect.width / ovalWidth
        let height = rect.height / ovalHeight
        context.move(to: CGPoint(x: width, y: height / 2))
        context.addArc(tangent1End: CGPoint(x: width, y: height), tangent2End: CGPoint(x: width / 2, y: height), radius: 1)
        context.addArc(tangent1End: CGPoint(x: 0, y: height), tangent2End: CGPoint(x: 0, y: height / 2), radius: 1)
        context.addArc(tangent1End: CGPoint(x: 0, y: 0), tangent2End: CGPoint(x: width / 2, y: 0), radius: 1)
        context.addArc(tangent1End: CGPoint(x: width, y: 0), tangent2End: CGPoint(x: width, y: height / 2), radius: 1)
        context.closePath()
        context.restoreGState()
    }
}
