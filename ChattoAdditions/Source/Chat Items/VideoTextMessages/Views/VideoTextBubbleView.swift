//
//  VideoTextBubbleView.swift
//  ChattoAdditions
//
//  Created by Sameer Khavanekar on 7/22/19.
//

import Foundation
import Chatto

public protocol VideoTextBubbleViewStyleProtocol: TextBubbleViewStyleProtocol, PhotoBubbleViewStyleProtocol {}

public final class VideoTextBubbleView: UIView, MaximumLayoutWidthSpecificable, BackgroundSizingQueryable {
    
    public var preferredMaxLayoutWidth: CGFloat = 0
    public var animationDuration: CFTimeInterval = 0.33
    public var viewContext: ViewContext = .normal {
        didSet {
            if self.viewContext == .sizing {
                self.textView.dataDetectorTypes = UIDataDetectorTypes()
                self.textView.isSelectable = false
            } else {
                self.textView.dataDetectorTypes = .all
                self.textView.isSelectable = true
            }
        }
    }
    
    public var videoTextMessageStyle: VideoTextBubbleViewStyleProtocol! {
        didSet {
            self.updateViews()
        }
    }
    
    public var videoTextMessageViewModel: VideoTextMessageViewModelProtocol! {
        didSet {
            self.updateViews()
        }
    }
    
    public var selected: Bool = false {
        didSet {
            if self.selected != oldValue {
                self.updateViews()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        addSubview(bubbleImageView)
        addSubview(textView)
        addSubview(imageView)
        addSubview(progressIndicatorView)
    }
    
    // MARK:  Image Properties
    
    public private(set) var progressIndicatorView: CircleProgressIndicatorView = {
        return CircleProgressIndicatorView(size: CGSize(width: 33, height: 33))
    }()
    
    private var placeholderIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.autoresizingMask = UIView.AutoresizingMask()
        return imageView
    }()
    
    public private(set) lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.autoresizingMask = UIView.AutoresizingMask()
        imageView.clipsToBounds = true
        imageView.autoresizesSubviews = false
        imageView.autoresizingMask = UIView.AutoresizingMask()
        imageView.contentMode = .scaleAspectFill
        imageView.addSubview(borderView)
        imageView.layer.cornerRadius = 5
        return imageView
    }()
    
    private lazy var bubbleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.addSubview(self.borderImageView)
        return imageView
    }()
    
    private var borderImageView: UIImageView = UIImageView()
    private lazy var borderView = UIImageView()
    
    private func updateProgressIndicator() {
        let transferStatus = videoTextMessageViewModel.transferStatus.value
        let transferProgress = videoTextMessageViewModel.transferProgress.value
        progressIndicatorView.isHidden = [TransferStatus.idle, TransferStatus.success, TransferStatus.failed].contains(videoTextMessageViewModel.transferStatus.value)
        progressIndicatorView.progressLineColor = videoTextMessageStyle.progressIndicatorColor(viewModel: videoTextMessageViewModel)
        progressIndicatorView.progressLineWidth = 1
        progressIndicatorView.setProgress(CGFloat(transferProgress))
        
        switch transferStatus {
        case .idle, .success, .failed:
            
            break
        case .transfering:
            switch transferProgress {
            case 0:
                if progressIndicatorView.progressStatus != .starting { progressIndicatorView.progressStatus = .starting }
            case 1:
                if progressIndicatorView.progressStatus != .completed { progressIndicatorView.progressStatus = .completed }
            default:
                if progressIndicatorView.progressStatus != .inProgress { progressIndicatorView.progressStatus = .inProgress }
            }
        }
    }
    
    private func updateImages() {
        placeholderIconView.image = videoTextMessageStyle.placeholderIconImage(viewModel: videoTextMessageViewModel)
        placeholderIconView.tintColor = videoTextMessageStyle.placeholderIconTintColor(viewModel: videoTextMessageViewModel)
        
        if let image = videoTextMessageViewModel.image.value {
            self.imageView.image = image
            self.placeholderIconView.isHidden = true
        } else {
            self.imageView.image = videoTextMessageStyle.placeholderBackgroundImage(viewModel: videoTextMessageViewModel)
            self.placeholderIconView.isHidden = self.videoTextMessageViewModel.transferStatus.value != .failed
        }
        borderView.image = videoTextMessageStyle.borderImage(viewModel: videoTextMessageViewModel)
    }
    
    // MARK:  Text Properties
    
    private var textView: UITextView = {
        let textView = ChatMessageTextView()
        UIView.performWithoutAnimation({ () -> Void in // fixes iOS 8 blinking when cell appears
            textView.backgroundColor = UIColor.clear
        })
        textView.isEditable = false
        textView.isSelectable = true
        textView.dataDetectorTypes = .all
        textView.scrollsToTop = false
        textView.isScrollEnabled = false
        textView.bounces = false
        textView.bouncesZoom = false
        textView.showsHorizontalScrollIndicator = false
        textView.showsVerticalScrollIndicator = false
        textView.isExclusiveTouch = true
        textView.textContainer.lineFragmentPadding = 0
        return textView
    }()
    
    public private(set) var isUpdating: Bool = false
    public func performBatchUpdates(_ updateClosure: @escaping () -> Void, animated: Bool, completion: (() -> Void)?) {
        self.isUpdating = true
        let updateAndRefreshViews = {
            updateClosure()
            self.isUpdating = false
            self.updateViews()
            if animated {
                self.layoutIfNeeded()
            }
        }
        if animated {
            UIView.animate(withDuration: self.animationDuration, animations: updateAndRefreshViews, completion: { (_) -> Void in
                completion?()
            })
        } else {
            updateAndRefreshViews()
        }
    }
    
    private func updateViews() {
        if self.viewContext == .sizing { return }
        if isUpdating { return }
        guard videoTextMessageViewModel != nil, let style = videoTextMessageStyle else { return }
        
        self.updateTextView()
        
        imageView.isHidden = _isHidden
        placeholderIconView.isHidden = _isHidden
        
        let bubbleImage = style.bubbleImage(viewModel: self.videoTextMessageViewModel, isSelected: self.selected)
        let borderImage = style.bubbleImageBorder(viewModel: self.videoTextMessageViewModel, isSelected: self.selected)
        if self.bubbleImageView.image != bubbleImage { self.bubbleImageView.image = bubbleImage }
        if self.borderImageView.image != borderImage { self.borderImageView.image = borderImage }
        
        self.updateProgressIndicator()
        self.updateImages()
        self.setNeedsLayout()
    }
    
    private func updateTextView() {
        guard let style = videoTextMessageStyle, let viewModel = self.videoTextMessageViewModel else { return }
        
        let font = style.textFont(viewModel: viewModel, isSelected: self.selected)
        let textColor = style.textColor(viewModel: viewModel, isSelected: self.selected)
        
        var needsToUpdateText = false
        
        if self.textView.isHidden != _isHidden {
            self.textView.isHidden = _isHidden
            needsToUpdateText = true
        }
        if self.textView.font != font {
            self.textView.font = font
            needsToUpdateText = true
        }
        
        if self.textView.textColor != textColor {
            self.textView.textColor = textColor
            self.textView.linkTextAttributes = [
                NSAttributedString.Key.foregroundColor: textColor,
                NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
            ]
            needsToUpdateText = true
        }
        if needsToUpdateText || self.textView.text != viewModel.text {
            self.textView.text = _text
        }
        
        let textInsets = style.textInsets(viewModel: viewModel, isSelected: self.selected)
        if self.textView.textContainerInset != textInsets { self.textView.textContainerInset = textInsets }
    }
    
    private var _isHidden: Bool {
        return (self.videoTextMessageViewModel.isHidden || self.videoTextMessageViewModel.isDeleted)
    }
    
    private var _text: String {
        guard let viewModel = self.videoTextMessageViewModel else { return "" }
        return _isHidden ? "xxxxxxx xxxxxxx" : viewModel.text
    }
    
    private func bubbleImage() -> UIImage {
        return videoTextMessageStyle.bubbleImage(viewModel: videoTextMessageViewModel, isSelected: selected)
    }
    
    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        return self.calculateTextBubbleLayout(preferredMaxLayoutWidth: size.width).size
    }
    
    // MARK: Layout
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        let layout = self.calculateTextBubbleLayout(preferredMaxLayoutWidth: self.preferredMaxLayoutWidth)
        textView.bma_rect = layout.textFrame
        imageView.bma_rect = layout.photoFrame
        imageView.layer.mask?.frame = imageView.layer.bounds
        progressIndicatorView.center = imageView.center
        placeholderIconView.center = imageView.center
        placeholderIconView.bounds = CGRect(origin: .zero, size: layout.placeholderFrame.size)
        bubbleImageView.bma_rect = layout.bubbleFrame
        borderImageView.bma_rect = bubbleImageView.bounds
    }
    
    public var layoutCache: NSCache<AnyObject, AnyObject>!
    private func calculateTextBubbleLayout(preferredMaxLayoutWidth: CGFloat) -> VideoTextBubbleLayoutModel {
        let layoutContext = VideoTextBubbleLayoutModel.LayoutContext(
            text: _text,
            font: videoTextMessageStyle.textFont(viewModel: videoTextMessageViewModel, isSelected: selected),
            photoSize: CGSize(width: 50, height: 50), //videoTextMessageViewModel.imageSize,
            placeholderSize: videoTextMessageViewModel.imageSize,
            isIncoming: videoTextMessageViewModel.isIncoming,
            textInsets: videoTextMessageStyle.textInsets(viewModel: videoTextMessageViewModel, isSelected: selected),
            preferredMaxLayoutWidth: preferredMaxLayoutWidth,
            imageOffset: 30,
            isDeleted: _isHidden
        )
        
        if let layoutModel = self.layoutCache.object(forKey: layoutContext.hashValue as AnyObject) as? VideoTextBubbleLayoutModel, layoutModel.layoutContext == layoutContext {
            return layoutModel
        }
        
        let layoutModel = VideoTextBubbleLayoutModel(layoutContext: layoutContext)
        layoutModel.calculateLayout()
        
        self.layoutCache.setObject(layoutModel, forKey: layoutContext.hashValue as AnyObject)
        return layoutModel
    }
    
    public var canCalculateSizeInBackground: Bool {
        return true
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        print("Touches Ended")
    }
    
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        print("Touches Cancelled")
    }
    
    open override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        print("Touches Moved")
    }
    
}

private final class VideoTextBubbleLayoutModel {
    let layoutContext: LayoutContext
    var textFrame: CGRect = CGRect.zero
    var photoFrame: CGRect = .zero
    var placeholderFrame: CGRect = .zero
    var bubbleFrame: CGRect = CGRect.zero
    var size: CGSize = CGSize.zero
    
    init(layoutContext: LayoutContext) {
        self.layoutContext = layoutContext
    }
    
    struct LayoutContext: Equatable, Hashable {
        let text: String
        let font: UIFont
        let photoSize: CGSize
        let placeholderSize: CGSize
        let isIncoming: Bool
        let textInsets: UIEdgeInsets
        let preferredMaxLayoutWidth: CGFloat
        let imageOffset: CGFloat
        let isDeleted: Bool
        
        var hashValue: Int {
            return Chatto.bma_combine(hashes: [self.text.hashValue, self.textInsets.bma_hashValue, self.preferredMaxLayoutWidth.hashValue, self.font.hashValue, self.isDeleted.hashValue])
        }
        
        //        static func == (lhs: VideoTextBubbleLayoutModel.LayoutContext, rhs: VideoTextBubbleLayoutModel.LayoutContext) -> Bool {
        //            let lhsValues = (lhs.text, lhs.textInsets, lhs.font, lhs.preferredMaxLayoutWidth)
        //            let rhsValues = (rhs.text, rhs.textInsets, rhs.font, rhs.preferredMaxLayoutWidth)
        //            return lhsValues == rhsValues
        //        }
    }
    
    func calculateLayout() {
        if layoutContext.isDeleted {
            bubbleFrame = CGRect(x: 0, y: 0, width: 170, height: 54)
            photoFrame = CGRect(origin: .zero, size: .zero)
            size = bubbleFrame.size
            textFrame = CGRect.zero
        } else {
            let photoSize = layoutContext.photoSize
            let photoHorizontalOffset: CGFloat = 25
            let textHorizontalInset = layoutContext.textInsets.bma_horziontalInset
            let maxTextWidth = layoutContext.preferredMaxLayoutWidth - textHorizontalInset
            let textSize = textSizeThatFitsWidth(maxTextWidth)
            let bubbleSize = textSize.bma_outsetBy(dx: textHorizontalInset, dy: layoutContext.textInsets.bma_verticalInset)
            textFrame = CGRect(origin: CGPoint.zero, size: bubbleSize)
            let frameSize = CGSize(width: textFrame.width + 2*photoHorizontalOffset + photoSize.width, height: textFrame.height)
            
            photoFrame = CGRect(x: (frameSize.width - (photoSize.width + photoHorizontalOffset)), y: ((frameSize.height - photoSize.height) / 2), width: photoSize.width, height: photoSize.height)
            placeholderFrame = photoFrame
            bubbleFrame = CGRect(origin: CGPoint.zero, size: frameSize)
            size = frameSize
        }
    }
    
    private func textSizeThatFitsWidth(_ width: CGFloat) -> CGSize {
        let textContainer: NSTextContainer = {
            let size = CGSize(width: width, height: .greatestFiniteMagnitude)
            let container = NSTextContainer(size: size)
            container.lineFragmentPadding = 0
            return container
        }()
        
        let textStorage = self.replicateUITextViewNSTextStorage()
        let layoutManager: NSLayoutManager = {
            let layoutManager = NSLayoutManager()
            layoutManager.addTextContainer(textContainer)
            textStorage.addLayoutManager(layoutManager)
            return layoutManager
        }()
        
        let rect = layoutManager.usedRect(for: textContainer)
        return rect.size.bma_round()
    }
    
    private func replicateUITextViewNSTextStorage() -> NSTextStorage {
        // See https://github.com/badoo/Chatto/issues/129
        return NSTextStorage(string: self.layoutContext.text, attributes: [
            NSAttributedString.Key.font: self.layoutContext.font,
            NSAttributedString.Key(rawValue: "NSOriginalFont"): self.layoutContext.font
            ])
    }
}

/// UITextView with hacks to avoid selection, loupe, define...
private final class ChatMessageTextView: UITextView {
    
    override var canBecomeFirstResponder: Bool {
        return false
    }
    
    // See https://github.com/badoo/Chatto/issues/363
    override var gestureRecognizers: [UIGestureRecognizer]? {
        set {
            super.gestureRecognizers = newValue
        }
        get {
            return super.gestureRecognizers?.filter({ (gestureRecognizer) -> Bool in
                return type(of: gestureRecognizer) == UILongPressGestureRecognizer.self && gestureRecognizer.delaysTouchesEnded
            })
        }
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
    
    override var selectedRange: NSRange {
        get {
            return NSRange(location: 0, length: 0)
        }
        set {
            // Part of the heaviest stack trace when scrolling (when updating text)
            // See https://github.com/badoo/Chatto/pull/144
        }
    }
    
    override var contentOffset: CGPoint {
        get {
            return .zero
        }
        set {
            // Part of the heaviest stack trace when scrolling (when bounds are set)
            // See https://github.com/badoo/Chatto/pull/144
        }
    }
}

