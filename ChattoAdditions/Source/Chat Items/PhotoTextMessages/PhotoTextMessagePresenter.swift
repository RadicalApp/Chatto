//
//  PhotoTextMessagePresenter.swift
//  ChattoAdditions
//
//  Created by Matt Cielecki on 7/3/18.
//

import UIKit

open class PhotoTextMessagePresenter<ViewModelBuilderT, InteractionHandlerT>
    : BaseMessagePresenter<PhotoTextBubbleView, ViewModelBuilderT, InteractionHandlerT> where
    ViewModelBuilderT: ViewModelBuilderProtocol,
    ViewModelBuilderT.ViewModelT: PhotoTextMessageViewModelProtocol,
    InteractionHandlerT: BaseMessageInteractionHandlerProtocol,
InteractionHandlerT.ViewModelT == ViewModelBuilderT.ViewModelT {
    public typealias ModelT = ViewModelBuilderT.ModelT
    public typealias ViewModelT = ViewModelBuilderT.ViewModelT
    
    public init (
        messageModel: ModelT,
        viewModelBuilder: ViewModelBuilderT,
        interactionHandler: InteractionHandlerT?,
        sizingCell: PhotoTextMessageCollectionViewCell,
        baseCellStyle: BaseMessageCollectionViewCellStyleProtocol,
        photoTextCellStyle: PhotoTextMessageCollectionViewCellStyleProtocol,
        layoutCache: NSCache<AnyObject, AnyObject>) {
        self.layoutCache = layoutCache
        self.photoTextCellStyle = photoTextCellStyle
        super.init(
            messageModel: messageModel,
            viewModelBuilder: viewModelBuilder,
            interactionHandler: interactionHandler,
            sizingCell: sizingCell,
            cellStyle: baseCellStyle
        )
    }
    
    let layoutCache: NSCache<AnyObject, AnyObject>
    let photoTextCellStyle: PhotoTextMessageCollectionViewCellStyleProtocol
    
    public final override class func registerCells(_ collectionView: UICollectionView) {
        collectionView.register(PhotoTextMessageCollectionViewCell.self, forCellWithReuseIdentifier: "photoText-message-incoming")
        collectionView.register(PhotoTextMessageCollectionViewCell.self, forCellWithReuseIdentifier: "photoText-message-outcoming")
    }
    
    public final override func dequeueCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = self.messageViewModel.isIncoming ? "photoText-message-incoming" : "photoText-message-outcoming"
        return collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
    }
    
    open override func createViewModel() -> ViewModelBuilderT.ViewModelT {
        let viewModel = self.viewModelBuilder.createViewModel(self.messageModel)
        let updateClosure = { [weak self] (old: Any, new: Any) -> Void in
            self?.updateCurrentCell()
        }
        viewModel.avatarImage.observe(self, closure: updateClosure)
        viewModel.image.observe(self, closure: updateClosure)
        viewModel.transferDirection.observe(self, closure: updateClosure)
        viewModel.transferProgress.observe(self, closure: updateClosure)
        viewModel.transferStatus.observe(self, closure: updateClosure)
        return viewModel
    }
    
    public var photoTextCell: PhotoTextMessageCollectionViewCell? {
        if let cell = self.cell {
            if let photoTextCell = cell as? PhotoTextMessageCollectionViewCell {
                return photoTextCell
            } else {
                assert(false, "Invalid cell was given to presenter!")
            }
        }
        return nil
    }
    
    open override func configureCell(_ cell: BaseMessageCollectionViewCell<PhotoTextBubbleView>, decorationAttributes: ChatItemDecorationAttributes, animated: Bool, additionalConfiguration: (() -> Void)?) {
        guard let cell = cell as? PhotoTextMessageCollectionViewCell else {
            assert(false, "Invalid cell received")
            return
        }
        
        super.configureCell(cell, decorationAttributes: decorationAttributes, animated: animated) { () -> Void in
            cell.layoutCache = self.layoutCache
            cell.photoTextMessageViewModel = self.messageViewModel
            cell.photoTextMessageStyle = self.photoTextCellStyle
            additionalConfiguration?()
        }
    }
    
    public func updateCurrentCell() {
        if let cell = photoTextCell, let decorationAttributes = self.decorationAttributes {
            self.configureCell(cell, decorationAttributes: decorationAttributes, animated: self.itemVisibility != .appearing, additionalConfiguration: nil)
        }
    }
    
    open override func canShowMenu() -> Bool {
        return true
    }
    
    open override func canPerformMenuControllerAction(_ action: Selector) -> Bool {
        let selector = #selector(UIResponderStandardEditActions.copy(_:))
        let deleteSelector = UIResponderCustomEditActions.delete
        return action == selector || action == deleteSelector
    }
    
    open override func performMenuControllerAction(_ action: Selector) {
        let selector = #selector(UIResponderStandardEditActions.copy(_:))
        if action == selector {
            UIPasteboard.general.string = self.messageViewModel.text
        } else {
            assert(false, "Unexpected action")
        }
    }
}

