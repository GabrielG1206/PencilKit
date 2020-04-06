/// Copyright (c) 2019 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

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
    
    var count: Int {
        return sketches.count
    }
    
    func deleteSketch(at indexPaths: IndexPath) {
        sketches.remove(at: indexPaths.item)
    }
    
    func deleteSketches(at indexPaths: [IndexPath]){
        for path in indexPaths {
            deleteSketch(at: path)
        }
    }
}
