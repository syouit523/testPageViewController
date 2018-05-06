//
//  TabCollectionCell.swift
//  testPageViewController
//
//  Created by Shoichi Taguchi on 2018/05/03.
//  Copyright © 2018年 Shoichi Taguchi. All rights reserved.
//

import UIKit
import EasyPeasy

class TabCollectionCell: UICollectionViewCell {
    
    // MARK: - Propaties
    fileprivate var itemLabel: UILabel = UILabel(frame: .zero)
    fileprivate var currentBarView: UIView = UIView(frame: .zero)
    
    
    
    var tabItemButtonPressedBlock: (() -> Void)?
    var option: TabPageOption = TabPageOption() {
        didSet {
            // currentBarViewHeightConstraint.constant = option.currentBarHeight
            currentBarView.easy.layout(Height(option.currentBarHeight))
        }
    }
    var item: String = "" {
        didSet {
            itemLabel.text = item
            itemLabel.invalidateIntrinsicContentSize()
            invalidateIntrinsicContentSize()
        }
    }
    var isCurrent: Bool = false {
        didSet {
            currentBarView.isHidden = !isCurrent
            if isCurrent {
                highlightTitle()
            } else {
                unHighlightTitle()
            }
            currentBarView.backgroundColor = option.currentColor
            layoutIfNeeded()
        }
    }
    
    // MARK: - Initializer
    init() {
        super.init(frame: .zero)
        currentBarView.isHidden = true
        backgroundColor = .white
        addSubview(itemLabel)
        currentBarView.backgroundColor = .blue
        addSubview(currentBarView)
        layout: do {
            itemLabel.easy.layout(CenterX(),CenterY())
            currentBarView.easy.layout(Left(),Right(),Height(2),Bottom())
        }
    }
    
    override convenience init(frame: CGRect) {
        self.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        if item.count == 0 {
            return .zero
        }
        return intrinsicContentSize
    }
    
    class func cellIdentifier() -> String {
        return "TabCollectionCell"
    }
}

// MARK: - View

extension TabCollectionCell {
    override var intrinsicContentSize: CGSize {
        let width: CGFloat
        if let tabWidth = option.tabWidth, tabWidth > 0.0 {
            width = tabWidth
        } else {
            width = itemLabel.intrinsicContentSize.width + option.tabMargin * 2
        }
        
        let size = CGSize(width: width, height: option.tabHeight)
        return size
    }
    
    func hideCurrentBarView() {
        currentBarView.isHidden = true
    }
    
    func showCurrentBarView() {
        currentBarView.isHidden = false
    }
    
    func highlightTitle() {
        itemLabel.textColor = option.currentColor
        itemLabel.font = UIFont.boldSystemFont(ofSize: option.fontSize)
    }
    
    func unHighlightTitle() {
        itemLabel.textColor = option.defaultColor
        itemLabel.font = UIFont.systemFont(ofSize: option.fontSize)
    }
}
