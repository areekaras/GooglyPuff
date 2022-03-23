

import UIKit

final class PhotoCollectionViewCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!
    var representedAssetIdentifier: String?
    var thumbnailImage: UIImage? {
        didSet {
            imageView.image = thumbnailImage
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
}
