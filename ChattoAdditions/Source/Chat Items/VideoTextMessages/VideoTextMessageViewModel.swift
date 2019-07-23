//
//  VideoTextMessageViewModel.swift
//  ChattoAdditions
//
//  Created by Sameer Khavanekar on 7/22/19.
//

import Foundation

public protocol VideoTextMessageViewModelProtocol: TextMessageViewModelProtocol, PhotoMessageViewModelProtocol {
}

open class VideoTextMessageViewModel<VideoTextMessageModelT: VideoTextMessageModelProtocol>: VideoTextMessageViewModelProtocol {
    open var text: String {
        return self.videoTextMessage.text
    }
    open var videoTextMessage: VideoTextMessageModelProtocol {
        return self._videoTextMessage
    }
    public let _videoTextMessage: VideoTextMessageModelT // Can't make videoTextMessage: VideoTextMessageModelT: https://gist.github.com/diegosanchezr/5a66c7af862e1117b556
    public let messageViewModel: MessageViewModelProtocol
    public var transferStatus: Observable<TransferStatus> = Observable(.idle)
    public var transferProgress: Observable<Double> = Observable(0)
    public var transferDirection: Observable<TransferDirection> = Observable(.download)
    public var image: Observable<UIImage?>
    public var cellAccessibilityIdentifier: String = "chatto.message.videoText.cell"
    public var bubbleAccessibilityIdentifier: String = "chatto.message.videoText.bubble"
    open var imageSize: CGSize {
        return self.videoTextMessage.imageSize
    }
    open var isShowingFailedIcon: Bool {
        return self.messageViewModel.isShowingFailedIcon || self.transferStatus.value == .failed
    }
    
    public init(videoTextMessage: VideoTextMessageModelT, messageViewModel: MessageViewModelProtocol) {
        _videoTextMessage = videoTextMessage
        image = Observable(videoTextMessage.image)
        self.messageViewModel = messageViewModel
    }
    
    open func willBeShown() {
        // Need to declare empty. Otherwise subclass code won't execute (as of Xcode 7.2)
    }
    
    open func wasHidden() {
        // Need to declare empty. Otherwise subclass code won't execute (as of Xcode 7.2)
    }
}

open class VideoTextMessageViewModelDefaultBuilder<VideoTextMessageModelT: VideoTextMessageModelProtocol>: ViewModelBuilderProtocol {
    public init() {}
    
    let messageViewModelBuilder = MessageViewModelDefaultBuilder()
    
    open func createViewModel(_ videoTextMessage: VideoTextMessageModelT) -> VideoTextMessageViewModel<VideoTextMessageModelT> {
        let messageViewModel = self.messageViewModelBuilder.createMessageViewModel(videoTextMessage)
        let videoTextMessageViewModel = VideoTextMessageViewModel(videoTextMessage: videoTextMessage, messageViewModel: messageViewModel)
        return videoTextMessageViewModel
    }
    
    open func canCreateViewModel(fromModel model: Any) -> Bool {
        return model is VideoTextMessageModelT
    }
}

