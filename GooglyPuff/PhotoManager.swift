
import UIKit

enum PhotoManagerNotification {
    // Notification when new photo instances are added
    static let contentAdded = Notification.Name("com.raywenderlich.GooglyPuff.PhotoManagerContentAdded")
    // Notification when content updates (i.e. Download finishes)
    static let contentUpdated = Notification.Name("com.raywenderlich.GooglyPuff.PhotoManagerContentUpdated")
}

enum PhotoURLString {
    static let overlyAttachedGirlfriend = "https://i.imgur.com/L3eCjyH.jpeg"
    static let successKid = "https://i.imgur.com/zvEBWo1.jpeg"
    static let lotsOfFaces = "https://i.imgur.com/qW2YRBg.jpeg"
}

typealias PhotoProcessingProgressClosure = (_ completionPercentage: CGFloat) -> Void
typealias BatchPhotoDownloadingCompletionClosure = (_ error: NSError?) -> Void

final class PhotoManager {
    private init() {}
    static let shared = PhotoManager()
    
    private var unsafePhotos: [Photo] = []
    
    var photos: [Photo] {
        return unsafePhotos
    }
    
    func addPhoto(_ photo: Photo) {
        unsafePhotos.append(photo)
        DispatchQueue.main.async { [weak self] in
            self?.postContentAddedNotification()
        }
    }
    
    func downloadPhotos(withCompletion completion: BatchPhotoDownloadingCompletionClosure?) {
        var storedError: NSError?
        for address in [
            PhotoURLString.overlyAttachedGirlfriend,
            PhotoURLString.successKid,
            PhotoURLString.lotsOfFaces
        ] {
            guard let url = URL(string: address) else {
                return
            }
            let photo = DownloadPhoto(url: url) { _, error in
                if let error = error {
                    storedError = error
                }
            }
            PhotoManager.shared.addPhoto(photo)
        }
        
        completion?(storedError)
    }
    
    private func postContentAddedNotification() {
        NotificationCenter.default.post(name: PhotoManagerNotification.contentAdded, object: nil)
    }
}
