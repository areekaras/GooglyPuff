

import UIKit
import Photos

private let reuseIdentifier = "AssetCell"

class AssetsCollectionViewController: UICollectionViewController {
    // MARK: - Variables
    var assetsFetchResults: PHFetchResult<AnyObject>?
    var selectedAssets: SelectedAssets?
    weak var assetPickerDelegate: AssetPickerDelegate?
    
    private var thumbnailSize = CGSize.zero
    private let imageManager = PHImageManager()
    
    private var doneButton: UIBarButtonItem?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.allowsMultipleSelection = true
        
        doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(donePressed(_:)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Determine the size of the thumbnails to request from the PHCachingImageManager
        let scale = UIScreen.main.scale
        if let cellSize = (collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize {
            thumbnailSize = CGSize(width: cellSize.width * scale, height: cellSize.height * scale)
        }
        
        collectionView?.reloadData()
        updateSelectedItems()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView?.reloadData()
        updateSelectedItems()
    }
    
    // MARK: - Button handlers
    @objc func donePressed(_ sender: UIBarButtonItem) {
        guard let assets = selectedAssets?.assets else {
            return
        }
        assetPickerDelegate?.assetPickerDidFinishPickingAssets(assets)
    }
}

// MARK: - Private Methods
extension AssetsCollectionViewController {
    private func updateSelectedItems() {
        guard let assets = selectedAssets?.assets else {
            return
        }
        // Select the selected items
        if let fetchResult = assetsFetchResults {
            for asset in assets {
                let index = fetchResult.index(of: asset)
                if index != NSNotFound {
                    let indexPath = IndexPath(item: index, section: 0)
                    collectionView?.selectItem(
                        at: indexPath,
                        animated: false,
                        scrollPosition: UICollectionView.ScrollPosition()
                    )
                }
            }
        } else {
            for i in 0..<assets.count {
                let indexPath = IndexPath(item: i, section: 0)
                collectionView?.selectItem(
                    at: indexPath,
                    animated: false,
                    scrollPosition: UICollectionView.ScrollPosition()
                )
            }
        }
        updateDoneButton()
    }
    
    private func updateDoneButton() {
        guard selectedAssets != nil else {
            return
        }
        // Add a done button when there are selected assets
        let assetsAreEmpty = selectedAssets?.assets.isEmpty ?? true
        if !assetsAreEmpty {
            navigationItem.rightBarButtonItem = doneButton
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }
}

// MARK: - UICollectionViewDataSource
extension AssetsCollectionViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assetsFetchResults?.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        let assetCell = cell as? AssetCollectionViewCell ?? AssetCollectionViewCell()
        
        // Configure the cell
        if let fetchResults = assetsFetchResults, let asset = fetchResults[indexPath.item] as? PHAsset {
            let options = PHImageRequestOptions()
            options.isNetworkAccessAllowed = true
            
            assetCell.representedAssetIdentifier = asset.localIdentifier
            imageManager.requestImage(
                for: asset,
                   targetSize: thumbnailSize,
                   contentMode: .aspectFill,
                   options: options
            ) { image, _ in
                if assetCell.representedAssetIdentifier == asset.localIdentifier {
                    assetCell.thumbnailImage = image
                }
            }
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension AssetsCollectionViewController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Update selected Assets
        if let asset = assetsFetchResults?[indexPath.item] as? PHAsset {
            selectedAssets?.assets.append(asset)
            updateDoneButton()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        // Update de-selected Assets
        if let assetToDelete = assetsFetchResults?[indexPath.item] as? PHAsset {
            selectedAssets?.assets = (selectedAssets?.assets ?? []).filter { asset in
                !(asset == assetToDelete)
            }
            if assetsFetchResults == nil {
                collectionView.deleteItems(at: [indexPath])
            }
            updateDoneButton()
        }
    }
}
