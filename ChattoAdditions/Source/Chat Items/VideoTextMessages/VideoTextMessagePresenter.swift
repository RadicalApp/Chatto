//
//  VideoTextMessagePresenter.swift
//  ChattoAdditions
//
//  Created by Sameer Khavanekar on 7/22/19.
//

import Foundation

open class VideoTextMessagePresenter<ViewModelBuilderT, InteractionHandlerT>
    : BaseMessagePresenter<VideoTextBubbleView, ViewModelBuilderT, InteractionHandlerT> where
    ViewModelBuilderT: ViewModelBuilderProtocol,
    ViewModelBuilderT.ViewModelT: VideoTextMessageViewModelProtocol,
    InteractionHandlerT: BaseMessageInteractionHandlerProtocol,
InteractionHandlerT.ViewModelT == ViewModelBuilderT.ViewModelT {
    public typealias ModelT = ViewModelBuilderT.ModelT
    public typealias ViewModelT = ViewModelBuilderT.ViewModelT
    
    public init (
        messageModel: ModelT,
        viewModelBuilder: ViewModelBuilderT,
        interactionHandler: InteractionHandlerT?,
        sizingCell: VideoTextMessageCollectionViewCell,
        baseCellStyle: BaseMessageCollectionViewCellStyleProtocol,
        videoTextCellStyle: VideoTextMessageCollectionViewCellStyleProtocol,
        layoutCache: NSCache<AnyObject, AnyObject>) {
        self.layoutCache = layoutCache
        self.videoTextCellStyle = videoTextCellStyle
        super.init(
            messageModel: messageModel,
            viewModelBuilder: viewModelBuilder,
            interactionHandler: interactionHandler,
            sizingCell: sizingCell,
            cellStyle: baseCellStyle
        )
    }
    
    let layoutCache: NSCache<AnyObject, AnyObject>
    let videoTextCellStyle: VideoTextMessageCollectionViewCellStyleProtocol
    
    public final override class func registerCells(_ collectionView: UICollectionView) {
        collectionView.register(VideoTextMessageCollectionViewCell.self, forCellWithReuseIdentifier: "videoText-message-incoming")
        collectionView.register(VideoTextMessageCollectionViewCell.self, forCellWithReuseIdentifier: "videoText-message-outcoming")
    }
    
    public final override func dequeueCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = self.messageViewModel.isIncoming ? "videoText-message-incoming" : "videoText-message-outcoming"
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
    
    public var videoTextCell: VideoTextMessageCollectionViewCell? {
        if let cell = self.cell {
            if let videoTextCell = cell as? VideoTextMessageCollectionViewCell {
                return videoTextCell
            } else {
                assert(false, "Invalid cell was given to presenter!")
            }
        }
        return nil
    }
    
    open override func configureCell(_ cell: BaseMessageCollectionViewCell<VideoTextBubbleView>, decorationAttributes: ChatItemDecorationAttributes, animated: Bool, additionalConfiguration: (() -> Void)?) {
        guard let cell = cell as? VideoTextMessageCollectionViewCell else {
            assert(false, "Invalid cell received")
            return
        }
        
        super.configureCell(cell, decorationAttributes: decorationAttributes, animated: animated) { () -> Void in
            cell.layoutCache = self.layoutCache
            cell.videoTextMessageViewModel = self.messageViewModel
            cell.videoTextMessageStyle = self.videoTextCellStyle
            additionalConfiguration?()
        }
    }
    
    public func updateCurrentCell() {
        if let cell = videoTextCell, let decorationAttributes = self.decorationAttributes {
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

