import UIKit

class SketchCell: UICollectionViewCell {
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    
    var image: UIImage? {
        didSet {
            if let image = image {
                thumbnailImageView.image = image
            }
        }
    }
    
    var isEditing: Bool = false
    
    override var isSelected: Bool {
        didSet{
            if isEditing{
                thumbnailImageView.image = isSelected ? UIImage(systemName: "xmark") : image
            }
            else{
                thumbnailImageView.image = image
            }
        }
    }
}
