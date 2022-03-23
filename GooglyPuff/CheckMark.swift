

import UIKit
import CoreGraphics

class CheckMark: UIView {
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        drawRectChecked()
    }
    
    func drawRectChecked() {
        // General Declarations
        let context = UIGraphicsGetCurrentContext()
        
        // Color Declarations
        let checkmarkBlue2 = UIColor(red: 0.078, green: 0.435, blue: 0.875, alpha: 1.0)
        
        // Shadow Declarations
        let shadow2 = UIColor.black
        let shadow2Offset = CGSize(width: 0.1, height: -0.1)
        let shadow2BlurRadius = 2.5
        
        // Frames
        let frame = bounds
        
        // Subframes
        let group = CGRect(x: frame.minX + 3, y: frame.minY + 3, width: frame.width - 6, height: frame.height - 6)
        
        // CheckedOval Drawing
        let checkedOvalPath = UIBezierPath(
            ovalIn: CGRect(
                x: group.minX + 0.5,
                y: group.minY + 0.5,
                width: group.width + 1,
                height: group.height + 1
            )
        )
        context?.saveGState()
        context?.setShadow(offset: shadow2Offset, blur: CGFloat(shadow2BlurRadius), color: shadow2.cgColor)
        checkmarkBlue2.setFill()
        checkedOvalPath.fill()
        context?.restoreGState()
        
        UIColor.white.setStroke()
        checkedOvalPath.lineWidth = 1
        checkedOvalPath.stroke()
        
        // Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: group.minX + 0.27083 * group.width, y: group.minY + 0.54167 * group.height))
        bezierPath.addLine(to: CGPoint(x: group.minX + 0.41667 * group.width, y: group.minY + 0.68750 * group.height))
        bezierPath.addLine(to: CGPoint(x: group.minX + 0.75000 * group.width, y: group.minY + 0.35417 * group.height))
        bezierPath.lineCapStyle = .square
        
        UIColor.white.setStroke()
        bezierPath.lineWidth = 1.3
        bezierPath.stroke()
    }
}
