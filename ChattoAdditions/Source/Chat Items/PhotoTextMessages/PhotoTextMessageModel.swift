//
//  PhotoTextMessageModel.swift
//  ChattoAdditions
//
//  Created by Matt Cielecki on 7/3/18.
//

import Foundation

public protocol PhotoTextMessageModelProtocol: TextMessageModelProtocol, PhotoMessageModelProtocol {
}

open class PhotoTextMessageModel<MessageModelT: MessageModelProtocol>: PhotoTextMessageModelProtocol {
    public var messageModel: MessageModelProtocol {
        return self._messageModel
    }
    public let _messageModel: MessageModelT // Can't make messasgeModel: MessageModelT: https://gist.github.com/diegosanchezr/5a66c7af862e1117b556
    public let text: String
    public var image: UIImage
    public let imageSize: CGSize
    public var imageURL: String?
    public init(messageModel: MessageModelT, text: String, imageSize: CGSize, image: UIImage, imageURL: String?) {
        self._messageModel = messageModel
        self.text = text
        self.imageSize = imageSize
        self.image = image
        self.imageURL = imageURL
    }
}
