

import UIKit
import Photos

private let reuseIdentifier = "AlbumsCell"

class AlbumsTableViewController: UITableViewController {
    var selectedAssets: SelectedAssets?
    weak var assetPickerDelegate: AssetPickerDelegate?
    
    private let sectionNames = ["", "Albums"]
    private var userLibrary: PHFetchResult<PHAssetCollection>?
    private var userAlbums: PHFetchResult<PHCollection>?
    
    private var doneButton: UIBarButtonItem?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if selectedAssets == nil {
            selectedAssets = SelectedAssets()
        }
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            guard let self = self else {
                return
            }
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    self.fetchCollections()
                    self.tableView.reloadData()
                default:
                    self.showNoAccessAlertAndCancel()
                }
            }
        }
        doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(donePressed(_:)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateDoneButton()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard
            let destination = segue.destination as? AssetsCollectionViewController,
            let cell = sender as? UITableViewCell,
            let indexPath = tableView.indexPath(for: cell)
        else {
            return
        }
        
        // Set up AssetCollectionViewController
        destination.selectedAssets = selectedAssets
        destination.title = cell.textLabel?.text ?? ""
        destination.assetPickerDelegate = self
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        switch indexPath.section {
        case 0:
            // Camera Roll
            guard let library = userLibrary?[indexPath.row] else {
                break
            }
            destination.assetsFetchResults = PHAsset.fetchAssets(
                in: library,
                options: options
            ) as? PHFetchResult<AnyObject>
        case 1:
            // Albums
            guard let album = userAlbums?[indexPath.row] as? PHAssetCollection else {
                break
            }
            destination.assetsFetchResults = PHAsset.fetchAssets(
                in: album,
                options: options
            ) as? PHFetchResult<AnyObject>
        default:
            break
        }
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        assetPickerDelegate?.assetPickerDidCancel()
    }
    
    @IBAction func donePressed(_ sender: Any) {
        // Should only be invoked when there are selected assets
        if let assets = selectedAssets?.assets {
            assetPickerDelegate?.assetPickerDidFinishPickingAssets(assets)
            // Clear out selections
            selectedAssets?.assets.removeAll()
        }
    }
}

// MARK: - Private Methods
extension AlbumsTableViewController {
    func fetchCollections() {
        userAlbums = PHCollectionList.fetchTopLevelUserCollections(with: nil)
        userLibrary = PHAssetCollection.fetchAssetCollections(
            with: .smartAlbum,
            subtype: .smartAlbumUserLibrary,
            options: nil)
    }
    
    func showNoAccessAlertAndCancel() {
        let alert = UIAlertController(
            title: "No Photo Permissions",
            message: "Please grant photo permissions in Settings",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
            guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            UIApplication.shared.open(
                settingsURL,
                options: [:],
                completionHandler: nil
            )
            return
        }
        alert.addAction(settingsAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func updateDoneButton() {
        guard let selectedAssets = selectedAssets else {
            return
        }
        // Add a done button when there are selected assets
        if !selectedAssets.assets.isEmpty {
            navigationItem.rightBarButtonItem = doneButton
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }
}

// MARK: - Table view data source
extension AlbumsTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionNames.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return userLibrary?.count ?? 0
        case 1:
            return userAlbums?.count ?? 0
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        cell.textLabel?.text = ""
        
        switch indexPath.section {
        case 0:
            guard let library = userLibrary?[indexPath.row] else {
                break
            }
            var title = library.localizedTitle ?? ""
            if library.estimatedAssetCount != NSNotFound {
                title += " (\(library.estimatedAssetCount))"
            }
            cell.textLabel?.text = title
        case 1:
            guard let album = userAlbums?[indexPath.row] as? PHAssetCollection else {
                break
            }
            var title = album.localizedTitle ?? ""
            if album.estimatedAssetCount != NSNotFound {
                title += " (\(album.estimatedAssetCount))"
            }
            cell.textLabel?.text = title
        default:
            break
        }
        
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
}

// MARK: - AssetPickerDelegate
extension AlbumsTableViewController: AssetPickerDelegate {
    func assetPickerDidCancel() {
        assetPickerDelegate?.assetPickerDidCancel()
    }
    
    func assetPickerDidFinishPickingAssets(_ selectedAssets: [PHAsset]) {
        assetPickerDelegate?.assetPickerDidFinishPickingAssets(selectedAssets)
        // Clear out selections
        self.selectedAssets?.assets.removeAll()
    }
}
