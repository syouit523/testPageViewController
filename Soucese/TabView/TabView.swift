//
//  TabView.swift
//  testPageViewController
//
//  Created by Shoichi Taguchi on 2018/05/03.
//  Copyright © 2018年 Shoichi Taguchi. All rights reserved.
//

import UIKit

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
    
}
