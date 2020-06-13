//
//  VideoTextMessageModel.swift
//  ChattoAdditions
//
//  Created by Sameer Khavanekar on 7/22/19.
//

import Foundation

public protocol VideoTextMessageModelProtocol: TextMessageModelProtocol, PhotoMessageModelProtocol {
}

open class VideoTextMessageModel<MessageModelT: MessageModelProtocol>: VideoTextMessageModelProtocol {
    public var messageModel: MessageModelProtocol {
        return self._messageModel
    }
    public let _messageModel: MessageModelT // Can't make messasgeModel: MessageModelT: https://gist.github.com/diegosanchezr/5a66c7af862e1117b556
    public let text: String
    public var image: UIImage
    public let imageSize: CGSize
    public var imageURL: String?
    public var thumbnail: UIImage
    public var thumbnailURL: String?
    public var videoURL: URL?
    
    public init(messageModel: MessageModelT,
                text: String,
                videoURL: URL,
                imageSize: CGSize,
                thumbnail: UIImage,
                thumbnailURL: String?)
    {
        self._messageModel = messageModel
        self.text = text
        self.imageSize = imageSize
        self.image = thumbnail
        self.thumbnail = thumbnail
        self.imageURL = thumbnailURL
        self.thumbnailURL = thumbnailURL
        self.videoURL = videoURL
    }
}
