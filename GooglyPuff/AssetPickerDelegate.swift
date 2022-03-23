

import Foundation
import Photos

protocol AssetPickerDelegate: AnyObject {
    func assetPickerDidFinishPickingAssets(_ selectedAssets: [PHAsset])
    func assetPickerDidCancel()
}
