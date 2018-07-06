//
//  PhotoTextMessageCollectionViewCell.swift
//  ChattoAdditions
//
//  Created by Matt Cielecki on 7/3/18.
//

import UIKit

public typealias PhotoTextMessageCollectionViewCellStyleProtocol = PhotoTextBubbleViewStyleProtocol

public final class PhotoTextMessageCollectionViewCell: BaseMessageCollectionViewCell<PhotoTextBubbleView> {
    
    public static func sizingCell() -> PhotoTextMessageCollectionViewCell {
        let cell = PhotoTextMessageCollectionViewCell(frame: CGRect.zero)
        cell.viewContext = .sizing
        return cell
    }
    
    // MARK: Subclassing (view creation)
    
    public override func createBubbleView() -> PhotoTextBubbleView {
        return PhotoTextBubbleView()
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
    
    public var photoTextMessageViewModel: PhotoTextMessageViewModelProtocol! {
        didSet {
            self.messageViewModel = self.photoTextMessageViewModel
            self.bubbleView.photoTextMessageViewModel = self.photoTextMessageViewModel
        }
    }
    
    public var photoTextMessageStyle: PhotoTextMessageCollectionViewCellStyleProtocol! {
        didSet {
            self.bubbleView.photoTextMessageStyle = self.photoTextMessageStyle
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

