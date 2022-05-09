import UIKit


class BaseHomeCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 16
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 12
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowOpacity = 0.2
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 16).cgPath
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class HomeCollectionCell: BaseHomeCell {

    private let preImgView = UIImageView()

    func config(model: Canvas) {
        preImgView.image = model.image
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white

        preImgView.contentMode = .scaleAspectFill
        preImgView.backgroundColor = UIColor.white

        contentView.addSubview(preImgView)
        contentView.clipsToBounds = true

        preImgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class NewCanvasCollectionCell: BaseHomeCell {

    private var imageView = UIImageView(image: UIImage(named: "homeAdd"))

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        contentView.addSubview(imageView)
        imageView.contentMode = .center
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
