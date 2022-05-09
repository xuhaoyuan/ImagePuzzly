import UIKit
import Disk
import RxSwift
import RxCocoa
import MBProgressHUD


struct Canvas: Codable, Equatable {

    let image: UIImage?

    init(image: UIImage) {
        self.image = image
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Self.CodingKeys)
        if let data = self.image?.pngData() {
            let str = data.base64EncodedString()
            try container.encode(str, forKey: .image)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Self.CodingKeys)
        let dataStr = try container.decode(String.self, forKey: .image)
        if let data = Data(base64Encoded: dataStr) {
            self.image = UIImage(data: data)
        } else {
            self.image = nil
        }
    }

    enum CodingKeys: CodingKey {
        case image
    }
}

class HomeViewModel: NSObject {

    static let shared = HomeViewModel()

    var obserable: Observable<[Canvas]> {
        return relay.distinctUntilChanged().asObservable()
    }

    private var relay: BehaviorRelay<[Canvas]> = BehaviorRelay(value: [])

    private static let path = "/canvasList/data"
    private let disposbag = DisposeBag()

    override init() {
        super.init()
        MBProgressHUD.show()
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            if let result = try? Disk.retrieve(Self.path, from: .documents, as: [Canvas].self), result.count > 0 {
                DispatchQueue.main.async { [weak self] in
                    self?.relay.accept(result)
                    MBProgressHUD.hide()
                }
            } else {
                var canvasList: [Canvas] = []
                for i in 0...13 {
                    guard let image = UIImage(named: "image\(i)") else { continue }
                    let canvas = Canvas(image: image)
                    canvasList.append(canvas)
                }
                DispatchQueue.main.async { [weak self] in
                    self?.relay.accept(canvasList)
                    self?.saveData()
                    MBProgressHUD.hide()
                }
            }
        }
    }

    func update(list: [Canvas]) {
        //        var list = relay.value
        relay.accept(list)
        saveData()
    }

    func update(model: Canvas) {
        //        var list = relay.value
        //        list = list.map {
        //            $0.uuid == model.uuid ? model : $0
        //        }
        //        relay.accept(list)
        //        saveData()
    }

    func append(model: Canvas) {
        var list = relay.value
        list.append(model)
        relay.accept(list)
        saveData()
    }

    func remove(index: Int) {
        var list = relay.value
        list.remove(at: index)
        relay.accept(list)
        saveData()
    }

    func saveData() {
        let list = relay.value
        DispatchQueue.global().async {
            try? Disk.save(list, to: .documents, as: Self.path)
        }
    }
}
