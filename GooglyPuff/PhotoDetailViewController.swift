

import UIKit

private enum ScaleFactor {
    static let retinaToEye: CGFloat = 0.5
    static let faceBoundsToEye: CGFloat = 4.0
}

final class PhotoDetailViewController: UIViewController {
    @IBOutlet weak var photoImageView: UIImageView!
    
    var image: UIImage?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        assert(image != nil, "Image not set; required to use view controller")
        guard let image = image else {
            return
        }
        photoImageView.image = image
        
        // Resize if necessary to ensure it's not pixelated
        if image.size.height <= photoImageView.bounds.size.height &&
            image.size.width <= photoImageView.bounds.size.width {
            photoImageView.contentMode = .center
        }
        
        
        
        guard let overlayImage = image.faceOverlayImageFrom() else {
            return
        }
        fadeInNewImage(overlayImage)
    }
}

// MARK: - Private Methods
private extension PhotoDetailViewController {
    func fadeInNewImage(_ newImage: UIImage) {
        let tmpImageView = UIImageView(image: newImage)
        tmpImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tmpImageView.contentMode = photoImageView.contentMode
        tmpImageView.frame = photoImageView.bounds
        tmpImageView.alpha = 0.0
        photoImageView.addSubview(tmpImageView)
        
        UIView.animate(withDuration: 0.75, animations: {
            tmpImageView.alpha = 1.0
        }, completion: { _ in
            self.photoImageView.image = newImage
            tmpImageView.removeFromSuperview()
        })
    }
}
