import UIKit
import PencilKit

class ThumbnailCollectionViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    
    private let sketchDataSource = SketchDataSource()
    private let reuseIdentifier = "ThumbnailCell"
    private let itemsPerRow: CGFloat = 3
    private let sectionInsets = UIEdgeInsets(top: 50.0,
                                             left: 20.0,
                                             bottom: 50.0,
                                             right: 20.0)
    private var thumbnailSize: CGSize?
    private var selectedIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.allowsMultipleSelection = true
        sketchDataSource.observers.append(self)
        deleteButton.isEnabled = false
        navigationItem.leftBarButtonItem = editButtonItem
        let width = (view.frame.size.width - (sectionInsets.left * 2 + 20.0)) / 3
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: width, height: width * 4 / 3)
        thumbnailSize = layout.itemSize
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        deleteButton.isEnabled = isEditing
        addButton.isEnabled = !isEditing
        
        collectionView.indexPathsForVisibleItems.forEach {
            guard let sketchCell = collectionView.cellForItem(at: $0) as? SketchCell else {return}
            sketchCell.isEditing = editing
        }
        print(isEditing)
        if !isEditing{
            collectionView.indexPathsForSelectedItems?.compactMap({$0}).forEach{
                collectionView.deselectItem(at: $0, animated: false)
            }
        }
    }
    
    @IBAction func addDrawing(_ sender: Any) {
        sketchDataSource.addDrawing()
        collectionView.reloadData()
    }
    
    @IBAction func deleteDrawing(_ sender: Any) {
        guard let selectedIndices = collectionView.indexPathsForSelectedItems else { return }
        let sortedIndexPaths = selectedIndices.sorted(by: { $0.item > $1.item })
        sketchDataSource.deleteDrawing(at: sortedIndexPaths)
        collectionView.deleteItems(at: sortedIndexPaths)
    }
}

extension ThumbnailCollectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sketchDataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! SketchCell
        cell.backgroundColor = UIColor.lightGray
        cell.thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        if let thumbnailImage = sketchDataSource.sketches[indexPath.row].thumbnailImage {
            cell.image = thumbnailImage
        }
        
        return cell
    }
}

extension ThumbnailCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !isEditing{
            selectedIndexPath = indexPath
            guard let drawingViewController = storyboard?.instantiateViewController(identifier: "DrawingViewController") as? DrawingViewController,
                let navigationController = navigationController else {
                    return
            }
            drawingViewController.sketch = sketchDataSource.sketches[indexPath.row]
            drawingViewController.sketchDataSource = sketchDataSource
            navigationController.pushViewController(drawingViewController, animated: true)
        }
    }
}

extension ThumbnailCollectionViewController: SketchDataSourceObserver {
    func thumbnailDidUpdate(_ thumbnail: UIImage) {
        collectionView.reloadData()
    }
}
