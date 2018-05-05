//
//  TabView.swift
//  testPageViewController
//
//  Created by Shoichi Taguchi on 2018/05/03.
//  Copyright © 2018年 Shoichi Taguchi. All rights reserved.
//

import UIKit
import EasyPeasy

internal class TabView: UIView {
    
    var pageItemPressedBlock: ((_ index: Int, _ direction: UIPageViewControllerNavigationDirection) -> Void)?
    var pageTabItems: [String] = [] {
        didSet {
            pageTabItemsCount = pageTabItems.count
            beforeIndex = pageTabItems.count
        }
    }
    var layouted: Bool = false
    
    fileprivate var isInfinity: Bool = false
    fileprivate var option: TabPageOption = TabPageOption()
    fileprivate var beforeIndex: Int = 0
    fileprivate var currentIndex: Int = 0
    fileprivate var pageTabItemsCount: Int = 0
    fileprivate var shouldScrollToItem: Bool = false
    fileprivate var pageTabItemsWidth: CGFloat = 0
    fileprivate var collectionViewContentOffsetX: CGFloat = 0
    fileprivate var currentBarViewWidth: CGFloat = 0.0
    fileprivate var cellForSize: TabCollectionCell!
    fileprivate var cachedCellSizes: [IndexPath: CGSize] = [:]
    
    var contentView: UIView = UIView(frame: .zero)
    fileprivate var collectionView:UICollectionView
    fileprivate var currentBarView = UIView(frame: .zero)
    
    init(isInfinity: Bool, option: TabPageOption) {
        collectionView: do {
            //            collectionView.collectionViewLayout = UICollectionViewFlowLayout()
            let flowLayout = UICollectionViewFlowLayout()
            flowLayout.scrollDirection = .vertical
            flowLayout.minimumInteritemSpacing = 5
            flowLayout.minimumLineSpacing = 5
            flowLayout.itemSize = CGSize(width: 100, height: 100)
            collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
            

        }
        super.init(frame: .zero)
        collectionView.delegate = self
        collectionView.dataSource = self
        self.option = option
        self.isInfinity = isInfinity
        addSubview(contentView)
        contentView.backgroundColor = option.tabBackgroundColor.withAlphaComponent(option.tabBarAlpha)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false

        layout: do {
            collectionView.easy.layout(
                Top(),
                Right(),
                Bottom(),
                Left()
            )
            contentView.easy.layout(
                Top(),
                Right(),
                Bottom(),
                Left()
            )
            currentBarView.easy.layout(
                CenterX(),
                Width(100),
                Bottom(),
                Height(option.currentBarHeight)
            )
            self.easy.layout(
                Bottom().to(contentView),
                Right().to(contentView)
            )
            collectionView.scrollsToTop = false
            currentBarView.backgroundColor = option.currentColor
            
            if !isInfinity {
                currentBarView.removeFromSuperview()
                collectionView.addSubview(currentBarView)
                currentBarView.translatesAutoresizingMaskIntoConstraints = false
                
                collectionView.easy.layout(
                    Top(),
                    Left()
                )
            }
            
        }
        
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK: - View

extension TabView {
    
    /**
     Called when you swipe in isInfinityTabPageViewController, moves the contentOffset of collectionView
     
     - parameter index: Next Index
     - parameter contentOffsetX: ContentOffset.x of scrollView of isInfinityTabPageViewController
     */
    func scrollCurrentBarView(_ index: Int, contentOffsetX: CGFloat) {
        var nextIndex = isInfinity ? index + pageTabItemsCount : index
        if isInfinity && index == 0 && (beforeIndex - pageTabItemsCount) == pageTabItemsCount - 1 {
            // Calculate the index at the time of transition to the first item from the last of pageTabItems
            nextIndex = pageTabItemsCount * 2
        } else if isInfinity && (index == pageTabItemsCount - 1) && (beforeIndex - pageTabItemsCount) == 0 {
            // Calculate the index at the time of transition from the first item of pageTabItems to the last item
            nextIndex = pageTabItemsCount - 1
        }
        
        if collectionViewContentOffsetX == 0.0 {
            collectionViewContentOffsetX = collectionView.contentOffset.x
        }
        
        let currentIndexPath = IndexPath(item: currentIndex, section: 0)
        let nextIndexPath = IndexPath(item: nextIndex, section: 0)
        if let currentCell = collectionView.cellForItem(at: currentIndexPath) as? TabCollectionCell, let nextCell = collectionView.cellForItem(at: nextIndexPath) as? TabCollectionCell {
            nextCell.hideCurrentBarView()
            currentCell.hideCurrentBarView()
            currentBarView.isHidden = false
            
            if currentBarViewWidth == 0.0 {
                currentBarViewWidth = currentCell.frame.width
            }
            
            let distance = (currentCell.frame.width / 2.0) + (nextCell.frame.width / 2.0)
            let scrollRate = contentOffsetX / frame.width
            
            if fabs(scrollRate) > 0.6 {
                nextCell.highlightTitle()
                currentCell.unHighlightTitle()
            } else {
                nextCell.unHighlightTitle()
                currentCell.highlightTitle()
            }
            
            let width = fabs(scrollRate) * (nextCell.frame.width - currentCell.frame.width)
            if isInfinity {
                let scroll = scrollRate * distance
                collectionView.contentOffset.x = collectionViewContentOffsetX + scroll
            } else {
                if scrollRate > 0 {
//                    currentBarViewLeftConstraint?.constant = currentCell.frame.minX + scrollRate * currentCell.frame.width
                } else {
//                    currentBarViewLeftConstraint?.constant = currentCell.frame.minX + nextCell.frame.width * scrollRate
                }
            }
            // currentBarViewWidthConstraint.constant = currentBarViewWidth + width
        }
    }
    
    /**
     Center the current cell after page swipe
     */
    func scrollToHorizontalCenter() {
        let indexPath = IndexPath(item: currentIndex, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        collectionViewContentOffsetX = collectionView.contentOffset.x
    }
    
    /**
     Called in after the transition is complete pages in isInfinityTabPageViewController in the process of updating the current
     
     - parameter index: Next Index
     */
    func updateCurrentIndex(_ index: Int, shouldScroll: Bool) {
        deselectVisibleCells()
        
        currentIndex = isInfinity ? index + pageTabItemsCount : index
        
        let indexPath = IndexPath(item: currentIndex, section: 0)
        moveCurrentBarView(indexPath, animated: !isInfinity, shouldScroll: shouldScroll)
    }
    
    /**
     Make the tapped cell the current if isInfinity is true
     
     - parameter index: Next IndexPath√
     */
    fileprivate func updateCurrentIndexForTap(_ index: Int) {
        deselectVisibleCells()
        
        if isInfinity && (index < pageTabItemsCount) || (index >= pageTabItemsCount * 2) {
            currentIndex = (index < pageTabItemsCount) ? index + pageTabItemsCount : index - pageTabItemsCount
            shouldScrollToItem = true
        } else {
            currentIndex = index
        }
        let indexPath = IndexPath(item: index, section: 0)
        moveCurrentBarView(indexPath, animated: true, shouldScroll: true)
    }
    
    /**
     Move the collectionView to IndexPath of Current
     
     - parameter indexPath: Next IndexPath
     - parameter animated: true when you tap to move the isInfinityTabCollectionCell
     - parameter shouldScroll:
     */
    fileprivate func moveCurrentBarView(_ indexPath: IndexPath, animated: Bool, shouldScroll: Bool) {
        if shouldScroll {
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
            layoutIfNeeded()
            collectionViewContentOffsetX = 0.0
            currentBarViewWidth = 0.0
        }
        if let cell = collectionView.cellForItem(at: indexPath) as? TabCollectionCell {
            currentBarView.isHidden = false
            if animated && shouldScroll {
                cell.isCurrent = true
            }
            cell.hideCurrentBarView()
//            currentBarViewWidthConstraint.constant = cell.frame.width
            if !isInfinity {
//                currentBarViewLeftConstraint?.constant = cell.frame.origin.x
            }
            UIView.animate(withDuration: 0.2, animations: {
                self.layoutIfNeeded()
            }, completion: { _ in
                if !animated && shouldScroll {
                    cell.isCurrent = true
                }
                
                self.updateCollectionViewUserInteractionEnabled(true)
            })
        }
        beforeIndex = currentIndex
    }
    
    /**
     Touch event control of collectionView
     
     - parameter userInteractionEnabled: collectionViewに渡すuserInteractionEnabled
     */
    func updateCollectionViewUserInteractionEnabled(_ userInteractionEnabled: Bool) {
        collectionView.isUserInteractionEnabled = userInteractionEnabled
    }
    
    /**
     Update all of the cells in the display to the unselected state
     */
    fileprivate func deselectVisibleCells() {
        collectionView
            .visibleCells
            .flatMap { $0 as? TabCollectionCell }
            .forEach { $0.isCurrent = false }
    }
    
}


// MARK: - UICollectionViewDataSource

extension TabView: UICollectionViewDataSource {
    
    internal func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isInfinity ? pageTabItemsCount * 3 : pageTabItemsCount
    }
    
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TabCollectionCell.cellIdentifier(), for: indexPath) as! TabCollectionCell
        configureCell(cell, indexPath: indexPath)
        return cell
    }
    
    fileprivate func configureCell(_ cell: TabCollectionCell, indexPath: IndexPath) {
        let fixedIndex = isInfinity ? indexPath.item % pageTabItemsCount : indexPath.item
        cell.item = pageTabItems[fixedIndex]
        cell.option = option
        cell.isCurrent = fixedIndex == (currentIndex % pageTabItemsCount)
        cell.tabItemButtonPressedBlock = { [weak self, weak cell] in
            var direction: UIPageViewControllerNavigationDirection = .forward
            if let pageTabItemsCount = self?.pageTabItemsCount, let currentIndex = self?.currentIndex {
                if self?.isInfinity == true {
                    if (indexPath.item < pageTabItemsCount) || (indexPath.item < currentIndex) {
                        direction = .reverse
                    }
                } else {
                    if indexPath.item < currentIndex {
                        direction = .reverse
                    }
                }
            }
            self?.pageItemPressedBlock?(fixedIndex, direction)
            
            if cell?.isCurrent == false {
                // Not accept touch events to scroll the animation is finished
                self?.updateCollectionViewUserInteractionEnabled(false)
            }
            self?.updateCurrentIndexForTap(indexPath.item)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // FIXME: Tabs are not displayed when processing is performed during introduction display
        if let cell = cell as? TabCollectionCell, layouted {
            let fixedIndex = isInfinity ? indexPath.item % pageTabItemsCount : indexPath.item
            cell.isCurrent = fixedIndex == (currentIndex % pageTabItemsCount)
        }
    }
}


// MARK: - UIScrollViewDelegate

extension TabView: UICollectionViewDelegate {
    
    internal func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isDragging {
            currentBarView.isHidden = true
            let indexPath = IndexPath(item: currentIndex, section: 0)
            if let cell = collectionView.cellForItem(at: indexPath) as? TabCollectionCell {
                cell.showCurrentBarView()
            }
        }
        
        guard isInfinity else {
            return
        }
        
        if pageTabItemsWidth == 0.0 {
            pageTabItemsWidth = floor(scrollView.contentSize.width / 3.0)
        }
        
        if (scrollView.contentOffset.x <= 0.0) || (scrollView.contentOffset.x > pageTabItemsWidth * 2.0) {
            scrollView.contentOffset.x = pageTabItemsWidth
        }
        
    }
    
    internal func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        // Accept the touch event because animation is complete
        updateCollectionViewUserInteractionEnabled(true)
        
        guard isInfinity else {
            return
        }
        
        let indexPath = IndexPath(item: currentIndex, section: 0)
        if shouldScrollToItem {
            // After the moved so as not to sense of incongruity, to adjust the contentOffset at the currentIndex
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
            shouldScrollToItem = false
        }
    }
}


// MARK: - UICollectionViewDelegateFlowLayout

extension TabView: UICollectionViewDelegateFlowLayout {
    
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if let size = cachedCellSizes[indexPath] {
            return size
        }
        
        configureCell(cellForSize, indexPath: indexPath)
        
        let size = cellForSize.sizeThatFits(CGSize(width: collectionView.bounds.width, height: option.tabHeight))
        cachedCellSizes[indexPath] = size
        
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
}
