
import UIKit
import Photos

typealias PhotoDownloadCompletionBlock = (_ image: UIImage?, _ error: NSError?) -> Void
typealias PhotoDownloadProgressBlock = (_ completed: Int, _ total: Int) -> Void

enum PhotoStatus {
    case downloading
    case goodToGo
    case failed
}

private let scale = UIScreen.main.scale
private let cellSize = CGSize(width: 64, height: 64)
private let thumbnailSize = CGSize(width: cellSize.width * scale, height: cellSize.height * scale)
private let imageManager = PHImageManager()

protocol Photo {
    var statusImage: PhotoStatus { get }
    var statusThumbnail: PhotoStatus { get }
    var image: UIImage? { get }
    var thumbnail: UIImage? { get }
}

class AssetPhoto: Photo {
    var statusImage: PhotoStatus = .downloading
    var statusThumbnail: PhotoStatus = .downloading
    var image: UIImage?
    var thumbnail: UIImage?
    
    let asset: PHAsset
    let representedAssetIdentifier: String
    private let targetSize = CGSize(width: 600, height: 600)
    
    init(asset: PHAsset) {
        self.asset = asset
        representedAssetIdentifier = asset.localIdentifier
        fetchThumbnailImage()
        fetchImage()
    }
    
    private func fetchThumbnailImage() {
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        imageManager.requestImage(
            for: asset,
               targetSize: thumbnailSize,
               contentMode: .aspectFill,
               options: options
        ) { image, info in
            if let image = image {
                if self.representedAssetIdentifier == self.asset.localIdentifier {
                    self.thumbnail = image
                    self.statusThumbnail = .goodToGo
                }
            } else if let info = info, info[PHImageErrorKey] as? NSError != nil {
                self.statusThumbnail = .failed
            }
        }
    }
    
    private func fetchImage() {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        
        PHImageManager.default().requestImage(
            for: asset,
               targetSize: targetSize,
               contentMode: .aspectFill,
               options: options
        ) { image, info in
            if let image = image {
                if image.size.width < self.targetSize.width / 2 {
                    DispatchQueue.main.asyncAfter(deadline: .now(), execute: self.fetchImage)
                }
                if self.representedAssetIdentifier == self.asset.localIdentifier {
                    self.image = image
                    self.statusImage = .goodToGo
                }
            } else if let info = info, info[PHImageErrorKey] as? NSError != nil {
                self.statusImage = .failed
            }
        }
    }
}

private let downloadSession = URLSession(configuration: URLSessionConfiguration.ephemeral)

class DownloadPhoto: Photo {
    var statusImage: PhotoStatus = .downloading
    var statusThumbnail: PhotoStatus = .downloading
    var image: UIImage?
    var thumbnail: UIImage?
    
    let url: URL
    
    init(url: URL, completion: PhotoDownloadCompletionBlock?) {
        self.url = url
        downloadImage(completion)
    }
    
    convenience init(url: URL) {
        self.init(url: url, completion: nil)
    }
    
    private func downloadImage(_ completion: PhotoDownloadCompletionBlock?) {
        let task = downloadSession.dataTask(with: url) { data, _, error in
            if let data = data {
                self.image = UIImage(data: data)
            }
            if error == nil && self.image != nil {
                self.statusImage = .goodToGo
                self.statusThumbnail = .goodToGo
            } else {
                self.statusImage = .failed
                self.statusThumbnail = .failed
            }
            
            self.thumbnail = self.image?.thumbnailImage(
                Int(cellSize.width),
                transparentBorder: 0,
                cornerRadius: 0,
                interpolationQuality: CGInterpolationQuality.default
            )
            
            completion?(self.image, error as NSError?)
            
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: PhotoManagerNotification.contentUpdated, object: nil)
            }
        }
        
        task.resume()
    }
}
