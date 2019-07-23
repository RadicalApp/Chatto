//
//  VideoTextMessagePresenterBuilder.swift
//  ChattoAdditions
//
//  Created by Sameer Khavanekar on 7/22/19.
//

import Foundation
import Chatto

open class VideoTextMessagePresenterBuilder<ViewModelBuilderT, InteractionHandlerT>
    : ChatItemPresenterBuilderProtocol where
    ViewModelBuilderT: ViewModelBuilderProtocol,
    ViewModelBuilderT.ViewModelT: VideoTextMessageViewModelProtocol,
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
    
    public lazy var sizingCell: VideoTextMessageCollectionViewCell = {
        var cell: VideoTextMessageCollectionViewCell? = nil
        if Thread.isMainThread {
            cell = VideoTextMessageCollectionViewCell.sizingCell()
        } else {
            DispatchQueue.main.sync(execute: {
                cell =  VideoTextMessageCollectionViewCell.sizingCell()
            })
        }
        
        return cell!
    }()
    
    public lazy var videoTextCellStyle: VideoTextMessageCollectionViewCellStyleProtocol = VideoTextMessageCollectionViewCellDefaultStyle()
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
                                    videoTextCellStyle: self.videoTextCellStyle,
                                    layoutCache: self.layoutCache)
    }
    
    open func createPresenter(withChatItem chatItem: ChatItemProtocol,
                              viewModelBuilder: ViewModelBuilderT,
                              interactionHandler: InteractionHandlerT?,
                              sizingCell: VideoTextMessageCollectionViewCell,
                              baseCellStyle: BaseMessageCollectionViewCellStyleProtocol,
                              videoTextCellStyle: VideoTextMessageCollectionViewCellStyleProtocol,
                              layoutCache: NSCache<AnyObject, AnyObject>) -> VideoTextMessagePresenter<ViewModelBuilderT, InteractionHandlerT> {
        assert(self.canHandleChatItem(chatItem))
        return VideoTextMessagePresenter<ViewModelBuilderT, InteractionHandlerT>(
            messageModel: chatItem as! ModelT,
            viewModelBuilder: viewModelBuilder,
            interactionHandler: interactionHandler,
            sizingCell: sizingCell,
            baseCellStyle: baseCellStyle,
            videoTextCellStyle: videoTextCellStyle,
            layoutCache: layoutCache
        )
    }
    
    open var presenterType: ChatItemPresenterProtocol.Type {
        return VideoTextMessagePresenter<ViewModelBuilderT, InteractionHandlerT>.self
    }
}

