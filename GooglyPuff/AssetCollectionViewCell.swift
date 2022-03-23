

import UIKit

class AssetCollectionViewCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet private var checkMark: UIView?
    
    var representedAssetIdentifier: String?
    var thumbnailImage: UIImage? {
        didSet {
            imageView.image = thumbnailImage
        }
    }
    
    override var isSelected: Bool {
        didSet {
            checkMark?.isHidden = !isSelected
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
}
