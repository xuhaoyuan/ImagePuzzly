import UIKit

protocol HeaderViewDelegate: AnyObject {
    func newGameButtonTapped()
    func preview()
}

class HeaderView: UIStackView {

    private let newGameButton: UIButton = {
        let newGameButton = UIButton(type: .custom)
        newGameButton.setTitle(Constant.String.newGameButtonTitle, for: .normal)
        newGameButton.titleLabel?.font = UIFont(name: Constant.Font.Name.helveticaNeue, size: 15)
        newGameButton.setTitleColor(UIColor.white, for: .normal)
        newGameButton.backgroundColor = UIColor.main
        return newGameButton
    }()

    let movesLabel: UILabel = {
        let movesLabel = UILabel()
        movesLabel.text = Constant.String.movesLabelText
        movesLabel.font = UIFont(name: Constant.Font.Name.helveticaNeue, size: 15)
        movesLabel.backgroundColor = UIColor.white
        movesLabel.textAlignment = .center
        return movesLabel
    }()

    private let previewButton: UIButton = {
        let newGameButton = UIButton(type: .custom)
        newGameButton.setTitle("Preview", for: .normal)
        newGameButton.titleLabel?.font = UIFont(name: Constant.Font.Name.helveticaNeue, size: 15)
        newGameButton.setTitleColor(UIColor.white, for: .normal)
        newGameButton.backgroundColor = UIColor.main
        return newGameButton
    }()


    weak var delegate: HeaderViewDelegate?

    required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }


    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addArrangedSubview(newGameButton)
        addArrangedSubview(movesLabel)
        addArrangedSubview(previewButton)
        axis = .horizontal
        distribution = .fillEqually
        alignment = .fill

        newGameButton.addTarget(self, action: #selector(newGameButtonTapped), for: .touchUpInside)
        previewButton.addTarget(self, action: #selector(previewButtonTapped), for: .touchUpInside)

    }

    @objc private func newGameButtonTapped() {
        delegate?.newGameButtonTapped()
    }

    @objc private func previewButtonTapped() {
        delegate?.preview()
    }
}
