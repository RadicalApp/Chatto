//
//  VideoTextMessageCollectionViewCellDefaultStyle.swift
//  ChattoAdditions
//
//  Created by Sameer Khavanekar on 7/22/19.
//

import Foundation
import Chatto

open class VideoTextMessageCollectionViewCellDefaultStyle: VideoTextMessageCollectionViewCellStyleProtocol {
    
    typealias Class = VideoTextMessageCollectionViewCellDefaultStyle
    
    let bubbleMasks: PhotoMessageCollectionViewCellDefaultStyle.BubbleMasks
    let sizes: PhotoMessageCollectionViewCellDefaultStyle.Sizes
    let colors: PhotoMessageCollectionViewCellDefaultStyle.Colors
    public let bubbleImages: TextMessageCollectionViewCellDefaultStyle.BubbleImages
    public let textStyle: TextMessageCollectionViewCellDefaultStyle.TextStyle
    public let baseStyle: BaseMessageCollectionViewCellDefaultStyle
    public init (
        bubbleMasks: PhotoMessageCollectionViewCellDefaultStyle.BubbleMasks = Class.createDefaultBubbleMasks(),
        sizes: PhotoMessageCollectionViewCellDefaultStyle.Sizes = Class.createDefaultSizes(),
        colors: PhotoMessageCollectionViewCellDefaultStyle.Colors = Class.createDefaultColors(),
        bubbleImages: TextMessageCollectionViewCellDefaultStyle.BubbleImages = Class.createDefaultBubbleImages(),
        textStyle: TextMessageCollectionViewCellDefaultStyle.TextStyle = Class.createDefaultTextStyle(),
        baseStyle: BaseMessageCollectionViewCellDefaultStyle = BaseMessageCollectionViewCellDefaultStyle()) {
        self.bubbleMasks = bubbleMasks
        self.sizes = sizes
        self.colors = colors
        self.bubbleImages = bubbleImages
        self.textStyle = textStyle
        self.baseStyle = baseStyle
    }
    
    lazy private var images: [ImageKey: UIImage] = {
        return [
            .template(isIncoming: true, showsTail: true): self.bubbleImages.incomingTail(),
            .template(isIncoming: true, showsTail: false): self.bubbleImages.incomingNoTail(),
            .template(isIncoming: false, showsTail: true): self.bubbleImages.outgoingTail(),
            .template(isIncoming: false, showsTail: false): self.bubbleImages.outgoingNoTail()
        ]
    }()
    
    
    lazy private var maskImageIncomingTail: UIImage = self.bubbleMasks.incomingTail()
    lazy private var maskImageIncomingNoTail: UIImage = self.bubbleMasks.incomingNoTail()
    lazy private var maskImageOutgoingTail: UIImage = self.bubbleMasks.outgoingTail()
    lazy private var maskImageOutgoingNoTail: UIImage = self.bubbleMasks.outgoingNoTail()
    
    lazy private var placeholderBackgroundIncoming: UIImage = {
        return UIImage.bma_imageWithColor(self.baseStyle.baseColorIncoming, size: CGSize(width: 1, height: 1))
    }()
    
    lazy private var placeholderBackgroundOutgoing: UIImage = {
        return UIImage.bma_imageWithColor(self.baseStyle.baseColorOutgoing, size: CGSize(width: 1, height: 1))
    }()
    
    lazy private var placeholderIcon: UIImage = {
        return UIImage(named: "photo-bubble-placeholder-icon", in: Bundle(for: Class.self), compatibleWith: nil)!
    }()
    
    open func maskingImage(viewModel: PhotoMessageViewModelProtocol) -> UIImage {
        switch (viewModel.isIncoming, viewModel.decorationAttributes.isShowingTail) {
        case (true, true):
            return self.maskImageIncomingTail
        case (true, false):
            return self.maskImageIncomingNoTail
        case (false, true):
            return self.maskImageOutgoingTail
        case (false, false):
            return self.maskImageOutgoingNoTail
        }
    }
    
    open func borderImage(viewModel: PhotoMessageViewModelProtocol) -> UIImage? {
        return self.baseStyle.borderImage(viewModel: viewModel)
    }
    
    open func placeholderBackgroundImage(viewModel: PhotoMessageViewModelProtocol) -> UIImage {
        return viewModel.isIncoming ? self.placeholderBackgroundIncoming : self.placeholderBackgroundOutgoing
    }
    
    open func placeholderIconImage(viewModel: PhotoMessageViewModelProtocol) -> UIImage {
        return self.placeholderIcon
    }
    
    open func placeholderIconTintColor(viewModel: PhotoMessageViewModelProtocol) -> UIColor {
        return viewModel.isIncoming ? self.colors.placeholderIconTintIncoming : self.colors.placeholderIconTintOutgoing
    }
    
    open func tailWidth(viewModel: PhotoMessageViewModelProtocol) -> CGFloat {
        return self.bubbleMasks.tailWidth
    }
    
    open func bubbleSize(viewModel: PhotoMessageViewModelProtocol) -> CGSize {
        let aspectRatio = viewModel.imageSize.height > 0 ? viewModel.imageSize.width / viewModel.imageSize.height : 0
        
        if aspectRatio == 0 || self.sizes.aspectRatioIntervalForSquaredSize.contains(aspectRatio) {
            return self.sizes.photoSizeSquare
        } else if aspectRatio < self.sizes.aspectRatioIntervalForSquaredSize.lowerBound {
            return self.sizes.photoSizePortrait
        } else {
            return self.sizes.photoSizeLandscape
        }
    }
    
    open func progressIndicatorColor(viewModel: PhotoMessageViewModelProtocol) -> UIColor {
        return viewModel.isIncoming ? self.colors.progressIndicatorColorIncoming : self.colors.progressIndicatorColorOutgoing
    }
    
    open func overlayColor(viewModel: PhotoMessageViewModelProtocol) -> UIColor? {
        let showsOverlay = viewModel.image.value != nil && (viewModel.transferStatus.value == .transfering || viewModel.status != MessageViewModelStatus.success)
        return showsOverlay ? self.colors.overlayColor : nil
    }
    
    lazy var font: UIFont = self.textStyle.font()
    lazy var incomingColor: UIColor = self.textStyle.incomingColor()
    lazy var outgoingColor: UIColor = self.textStyle.outgoingColor()
    
    open func textFont(viewModel: TextMessageViewModelProtocol, isSelected: Bool) -> UIFont {
        return self.font
    }
    
    open func textColor(viewModel: TextMessageViewModelProtocol, isSelected: Bool) -> UIColor {
        return viewModel.isIncoming ? self.incomingColor : self.outgoingColor
    }
    
    open func textInsets(viewModel: TextMessageViewModelProtocol, isSelected: Bool) -> UIEdgeInsets {
        return viewModel.isIncoming ? self.textStyle.incomingInsets : self.textStyle.outgoingInsets
    }
    
    open func bubbleImageBorder(viewModel: TextMessageViewModelProtocol, isSelected: Bool) -> UIImage? {
        return self.baseStyle.borderImage(viewModel: viewModel)
    }
    
    open func bubbleImage(viewModel: TextMessageViewModelProtocol, isSelected: Bool) -> UIImage {
        let key = ImageKey.normal(isIncoming: viewModel.isIncoming, status: viewModel.status, showsTail: viewModel.decorationAttributes.isShowingTail, isSelected: isSelected, isHidden: isHidden(viewModel: viewModel as! VideoTextMessageViewModelProtocol))
        
        if let image = self.images[key] {
            return image
        } else {
            let templateKey = ImageKey.template(isIncoming: viewModel.isIncoming, showsTail: viewModel.decorationAttributes.isShowingTail)
            if let image = self.images[templateKey] {
                let image = self.createImage(templateImage: image, isIncoming: viewModel.isIncoming, status: viewModel.status, isSelected: isSelected, isHidden: isHidden(viewModel: viewModel as! VideoTextMessageViewModelProtocol))
                self.images[key] = image
                return image
            }
        }
        
        assert(false, "coulnd't find image for this status. ImageKey: \(key)")
        return UIImage()
    }
    
    private func isHidden(viewModel: VideoTextMessageViewModelProtocol) -> Bool {
        return viewModel.isHidden || viewModel.isDeleted
    }
    
    open func createImage(templateImage image: UIImage, isIncoming: Bool, status: MessageViewModelStatus, isSelected: Bool, isHidden: Bool) -> UIImage {
        var color = isIncoming ? self.baseStyle.baseColorIncoming : self.baseStyle.baseColorOutgoing
        
        switch status {
        case .success:
            break
        case .read:
            color = color.bma_blendWithColor(UIColor.black.withAlphaComponent(0.10))
            break
        case .failed, .sending:
            color = color.bma_blendWithColor(UIColor.white.withAlphaComponent(0.70))
        }
        if isSelected && !isHidden {
            color = color.bma_blendWithColor(UIColor.black.withAlphaComponent(0.20))
        }
        return image.bma_tintWithColor(color)
    }
    
    private enum ImageKey: Hashable {
        case template(isIncoming: Bool, showsTail: Bool)
        case normal(isIncoming: Bool, status: MessageViewModelStatus, showsTail: Bool, isSelected: Bool, isHidden: Bool)
        
        var hashValue: Int {
            switch self {
            case let .template(isIncoming: isIncoming, showsTail: showsTail):
                return Chatto.bma_combine(hashes: [1 /*template*/, isIncoming.hashValue, showsTail.hashValue])
            case let .normal(isIncoming: isIncoming, status: status, showsTail: showsTail, isSelected: isSelected, isHidden: isHidden):
                return Chatto.bma_combine(hashes: [2 /*normal*/, isIncoming.hashValue, status.hashValue, showsTail.hashValue, isSelected.hashValue, isHidden.hashValue])
            }
        }
        
        static func == (lhs: VideoTextMessageCollectionViewCellDefaultStyle.ImageKey, rhs: VideoTextMessageCollectionViewCellDefaultStyle.ImageKey) -> Bool {
            switch (lhs, rhs) {
            case let (.template(lhsValues), .template(rhsValues)):
                return lhsValues == rhsValues
            case let (.normal(lhsValues), .normal(rhsValues)):
                return lhsValues == rhsValues
            default:
                return false
            }
        }
    }
}

public extension VideoTextMessageCollectionViewCellDefaultStyle { // Default values
    
    static public func createDefaultBubbleImages() -> TextMessageCollectionViewCellDefaultStyle.BubbleImages {
        return TextMessageCollectionViewCellDefaultStyle.BubbleImages(
            incomingTail: UIImage(named: "bubble-incoming-tail", in: Bundle(for: Class.self), compatibleWith: nil)!,
            incomingNoTail: UIImage(named: "bubble-incoming", in: Bundle(for: Class.self), compatibleWith: nil)!,
            outgoingTail: UIImage(named: "bubble-outgoing-tail", in: Bundle(for: Class.self), compatibleWith: nil)!,
            outgoingNoTail: UIImage(named: "bubble-outgoing", in: Bundle(for: Class.self), compatibleWith: nil)!
        )
    }
    
    static public func createDefaultTextStyle() -> TextMessageCollectionViewCellDefaultStyle.TextStyle {
        return TextMessageCollectionViewCellDefaultStyle.TextStyle(
            font: UIFont.systemFont(ofSize: 16),
            incomingColor: UIColor.black,
            outgoingColor: UIColor.white,
            incomingInsets: UIEdgeInsets(top: 30, left: 19, bottom: 30, right: 15),
            outgoingInsets: UIEdgeInsets(top: 30, left: 15, bottom: 30, right: 19)
        )
    }
    
    static public func createDefaultBubbleMasks() -> PhotoMessageCollectionViewCellDefaultStyle.BubbleMasks {
        return PhotoMessageCollectionViewCellDefaultStyle.BubbleMasks(
            incomingTail: UIImage(named: "bubble-incoming-tail", in: Bundle(for: Class.self), compatibleWith: nil)!,
            incomingNoTail: UIImage(named: "bubble-incoming", in: Bundle(for: Class.self), compatibleWith: nil)!,
            outgoingTail: UIImage(named: "bubble-outgoing-tail", in: Bundle(for: Class.self), compatibleWith: nil)!,
            outgoingNoTail: UIImage(named: "bubble-outgoing", in: Bundle(for: Class.self), compatibleWith: nil)!,
            tailWidth: 6
        )
    }
    
    static public func createDefaultSizes() -> PhotoMessageCollectionViewCellDefaultStyle.Sizes {
        return PhotoMessageCollectionViewCellDefaultStyle.Sizes(
            aspectRatioIntervalForSquaredSize: 0.90...1.10,
            photoSizeLandscape: CGSize(width: 210, height: 136),
            photoSizePortrait: CGSize(width: 136, height: 210),
            photoSizeSquare: CGSize(width: 210, height: 210)
        )
    }
    
    static public func createDefaultColors() -> PhotoMessageCollectionViewCellDefaultStyle.Colors {
        return PhotoMessageCollectionViewCellDefaultStyle.Colors(
            placeholderIconTintIncoming: UIColor.bma_color(rgb: 0xced6dc),
            placeholderIconTintOutgoing: UIColor.bma_color(rgb: 0x508dfc),
            progressIndicatorColorIncoming: UIColor.bma_color(rgb: 0x98a3ab),
            progressIndicatorColorOutgoing: UIColor.white,
            overlayColor: UIColor.black.withAlphaComponent(0.70)
        )
    }
}

