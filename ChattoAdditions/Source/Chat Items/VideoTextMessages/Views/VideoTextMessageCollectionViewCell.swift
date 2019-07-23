//
//  VideoTextMessageCollectionViewCell.swift
//  ChattoAdditions
//
//  Created by Sameer Khavanekar on 7/22/19.
//

import UIKit

public typealias VideoTextMessageCollectionViewCellStyleProtocol = VideoTextBubbleViewStyleProtocol

public final class VideoTextMessageCollectionViewCell: BaseMessageCollectionViewCell<VideoTextBubbleView> {
    
    public static func sizingCell() -> VideoTextMessageCollectionViewCell {
        let cell = VideoTextMessageCollectionViewCell(frame: CGRect.zero)
        cell.viewContext = .sizing
        return cell
    }
    
    // MARK: Subclassing (view creation)
    
    public override func createBubbleView() -> VideoTextBubbleView {
        return VideoTextBubbleView()
    }
    
    public override func performBatchUpdates(_ updateClosure: @escaping () -> Void, animated: Bool, completion: (() -> Void)?) {
        super.performBatchUpdates({ () -> Void in
            self.bubbleView.performBatchUpdates(updateClosure, animated: false, completion: nil)
        }, animated: animated, completion: completion)
    }
    
    // MARK: Property forwarding
    
    override public var viewContext: ViewContext {
        didSet {
            self.bubbleView.viewContext = self.viewContext
        }
    }
    
    public var videoTextMessageViewModel: VideoTextMessageViewModelProtocol! {
        didSet {
            self.messageViewModel = self.videoTextMessageViewModel
            self.bubbleView.videoTextMessageViewModel = self.videoTextMessageViewModel
        }
    }
    
    public var videoTextMessageStyle: VideoTextMessageCollectionViewCellStyleProtocol! {
        didSet {
            self.bubbleView.videoTextMessageStyle = self.videoTextMessageStyle
        }
    }
    
    override public var isSelected: Bool {
        didSet {
            self.bubbleView.selected = self.isSelected
        }
    }
    
    public var layoutCache: NSCache<AnyObject, AnyObject>! {
        didSet {
            self.bubbleView.layoutCache = self.layoutCache
        }
    }
}


