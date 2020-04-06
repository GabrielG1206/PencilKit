import Foundation
import PencilKit

class Sketch {
    
    var thumbnailImage: UIImage?
    var drawing: PKDrawing
    
    init(drawing: PKDrawing) {
        self.drawing = drawing
    }
}

protocol SketchDataSourceObserver {
    func thumbnailDidUpdate(_ thumbnail: UIImage)
}

class SketchDataSource {
    var thumbnailSize = CGSize(width: 192, height: 256)
    var canvasSize = CGSize(width: 768, height: 1024)
    var sketches: [Sketch] = []
    var observers = [SketchDataSourceObserver]()
    
    private let queue = DispatchQueue(label: "com.raywenderlich.wendersketch",
                                      qos: .background)
    
    func generateThumbnail(for sketch: Sketch) {
        let aspectRatio = thumbnailSize.width / thumbnailSize.height
        let scaleFactor = UIScreen.main.scale * thumbnailSize.width / canvasSize.width
        let thumbnailRect = CGRect(x: 0,
                                   y: 0,
                                   width: canvasSize.width,
                                   height: canvasSize.width / aspectRatio)
        
        queue.async {
            let image = sketch.drawing.image(
                from: thumbnailRect,
                scale: scaleFactor)
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                sketch.thumbnailImage = image
                self.observers.forEach {
                    $0.thumbnailDidUpdate(image)
                }
            }
        }
    }
    
    func addDrawing() {
        let sketch = Sketch(drawing: PKDrawing())
        sketches.append(sketch)
        generateThumbnail(for: sketch)
    }
    
    func deleteDrawing(at indexPath: IndexPath){
        sketches.remove(at: indexPath.item)
    }
    
    func deleteDrawing(at indexPaths: [IndexPath]){
        for path in indexPaths {
            deleteDrawing(at: path)
        }
    }
    
    var count: Int {
        return sketches.count
    }
}
