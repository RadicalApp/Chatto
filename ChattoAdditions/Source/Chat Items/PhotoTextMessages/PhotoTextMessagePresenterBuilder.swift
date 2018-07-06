//
//  PhotoTextMessagePresenterBuilder.swift
//  ChattoAdditions
//
//  Created by Matt Cielecki on 7/3/18.
//

import Foundation
import Chatto

open class PhotoTextMessagePresenterBuilder<ViewModelBuilderT, InteractionHandlerT>
    : ChatItemPresenterBuilderProtocol where
    ViewModelBuilderT: ViewModelBuilderProtocol,
    ViewModelBuilderT.ViewModelT: PhotoTextMessageViewModelProtocol,
    InteractionHandlerT: BaseMessageInteractionHandlerProtocol,
InteractionHandlerT.ViewModelT == ViewModelBuilderT.ViewModelT {
    typealias ViewModelT = ViewModelBuilderT.ViewModelT
    public typealias ModelT = ViewModelBuilderT.ModelT
    
    public init(
        viewModelBuilder: ViewModelBuilderT,
        interactionHandler: InteractionHandlerT? = nil) {
            self.viewModelBuilder = viewModelBuilder
            self.interactionHandler = interactionHandler
    }
    
    let viewModelBuilder: ViewModelBuilderT
    let interactionHandler: InteractionHandlerT?
    let layoutCache = NSCache<AnyObject, AnyObject>()
    
    public lazy var sizingCell: PhotoTextMessageCollectionViewCell = {
        var cell: PhotoTextMessageCollectionViewCell? = nil
        if Thread.isMainThread {
            cell = PhotoTextMessageCollectionViewCell.sizingCell()
        } else {
            DispatchQueue.main.sync(execute: {
                cell =  PhotoTextMessageCollectionViewCell.sizingCell()
            })
        }
        
        return cell!
    }()
    
    public lazy var photoTextCellStyle: PhotoTextMessageCollectionViewCellStyleProtocol = PhotoTextMessageCollectionViewCellDefaultStyle()
    public lazy var baseMessageStyle: BaseMessageCollectionViewCellStyleProtocol = BaseMessageCollectionViewCellDefaultStyle()
    
    open func canHandleChatItem(_ chatItem: ChatItemProtocol) -> Bool {
        return self.viewModelBuilder.canCreateViewModel(fromModel: chatItem)
    }
    
    open func createPresenterWithChatItem(_ chatItem: ChatItemProtocol) -> ChatItemPresenterProtocol {
        return self.createPresenter(withChatItem: chatItem,
                                    viewModelBuilder: self.viewModelBuilder,
                                    interactionHandler: self.interactionHandler,
                                    sizingCell: self.sizingCell,
                                    baseCellStyle: self.baseMessageStyle,
                                    photoTextCellStyle: self.photoTextCellStyle,
                                    layoutCache: self.layoutCache)
    }
    
    open func createPresenter(withChatItem chatItem: ChatItemProtocol,
                              viewModelBuilder: ViewModelBuilderT,
                              interactionHandler: InteractionHandlerT?,
                              sizingCell: PhotoTextMessageCollectionViewCell,
                              baseCellStyle: BaseMessageCollectionViewCellStyleProtocol,
                              photoTextCellStyle: PhotoTextMessageCollectionViewCellStyleProtocol,
                              layoutCache: NSCache<AnyObject, AnyObject>) -> PhotoTextMessagePresenter<ViewModelBuilderT, InteractionHandlerT> {
        assert(self.canHandleChatItem(chatItem))
        return PhotoTextMessagePresenter<ViewModelBuilderT, InteractionHandlerT>(
            messageModel: chatItem as! ModelT,
            viewModelBuilder: viewModelBuilder,
            interactionHandler: interactionHandler,
            sizingCell: sizingCell,
            baseCellStyle: baseCellStyle,
            photoTextCellStyle: photoTextCellStyle,
            layoutCache: layoutCache
        )
    }
    
    open var presenterType: ChatItemPresenterProtocol.Type {
        return PhotoTextMessagePresenter<ViewModelBuilderT, InteractionHandlerT>.self
    }
}

