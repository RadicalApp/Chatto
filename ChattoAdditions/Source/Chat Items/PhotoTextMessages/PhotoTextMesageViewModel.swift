//
//  PhotoTextMesageViewModel.swift
//  ChattoAdditions
//
//  Created by Matt Cielecki on 7/3/18.
//

public protocol PhotoTextMessageViewModelProtocol: TextMessageViewModelProtocol, PhotoMessageViewModelProtocol {
}

open class PhotoTextMessageViewModel<PhotoTextMessageModelT: PhotoTextMessageModelProtocol>: PhotoTextMessageViewModelProtocol {
    open var text: String {
        return self.photoTextMessage.text
    }
    open var photoTextMessage: PhotoTextMessageModelProtocol {
        return self._photoTextMessage
    }
    public let _photoTextMessage: PhotoTextMessageModelT // Can't make photoTextMessage: PhotoTextMessageModelT: https://gist.github.com/diegosanchezr/5a66c7af862e1117b556
    public let messageViewModel: MessageViewModelProtocol
    public var transferStatus: Observable<TransferStatus> = Observable(.idle)
    public var transferProgress: Observable<Double> = Observable(0)
    public var transferDirection: Observable<TransferDirection> = Observable(.download)
    public var image: Observable<UIImage?>
    public var cellAccessibilityIdentifier: String = "chatto.message.photoText.cell"
    public var bubbleAccessibilityIdentifier: String = "chatto.message.photoText.bubble"
    open var imageSize: CGSize {
        return self.photoTextMessage.imageSize
    }
    open var isShowingFailedIcon: Bool {
        return self.messageViewModel.isShowingFailedIcon || self.transferStatus.value == .failed
    }
    
    public init(photoTextMessage: PhotoTextMessageModelT, messageViewModel: MessageViewModelProtocol) {
        _photoTextMessage = photoTextMessage
        image = Observable(photoTextMessage.image)
        self.messageViewModel = messageViewModel
    }
    
    open func willBeShown() {
        // Need to declare empty. Otherwise subclass code won't execute (as of Xcode 7.2)
    }
    
    open func wasHidden() {
        // Need to declare empty. Otherwise subclass code won't execute (as of Xcode 7.2)
    }
}

open class PhotoTextMessageViewModelDefaultBuilder<PhotoTextMessageModelT: PhotoTextMessageModelProtocol>: ViewModelBuilderProtocol {
    public init() {}
    
    let messageViewModelBuilder = MessageViewModelDefaultBuilder()
    
    open func createViewModel(_ photoTextMessage: PhotoTextMessageModelT) -> PhotoTextMessageViewModel<PhotoTextMessageModelT> {
        let messageViewModel = self.messageViewModelBuilder.createMessageViewModel(photoTextMessage)
        let photoTextMessageViewModel = PhotoTextMessageViewModel(photoTextMessage: photoTextMessage, messageViewModel: messageViewModel)
        return photoTextMessageViewModel
    }
    
    open func canCreateViewModel(fromModel model: Any) -> Bool {
        return model is PhotoTextMessageModelT
    }
}

