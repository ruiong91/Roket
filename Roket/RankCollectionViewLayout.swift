
//
//  RankCollectionViewLayout.swift
//  Roket
//
//  Created by Rui Ong on 04/04/2017.
//  Copyright © 2017 Rui Ong. All rights reserved.
//

import UIKit

class RankCollectionViewLayout: UICollectionViewLayout {
    
    var cellHeight : Double?
    var cellWidth : Double?
    var xPos : Double?
    var yPos : Double?
    
    var cellAttrDictionary = Dictionary<IndexPath, UICollectionViewLayoutAttributes>()
    var contentSize = CGSize.zero
    var contentSizeSection0 = CGSize.zero
    var contentSizeSection1 = CGSize.zero
    
    override func prepare() {
        
        
        if let validSectionCount = collectionView?.numberOfSections {
            if validSectionCount > 0 {
                for section in 0..<validSectionCount{
                    if section == 0 {
                        cellHeight = 50
                        cellWidth = Double(UIScreen.main.bounds.size.width)/2
                        yPos = 0.0
                    } else {
                        cellHeight = Double(UIScreen.main.bounds.size.height - 50)
                        cellWidth = Double(UIScreen.main.bounds.size.width)/2
                        yPos = 50
                    }
                    
                    if let validItemCount = collectionView?.numberOfItems(inSection: section){
                        if validItemCount > 0 {
                            for item in 0..<validItemCount {
                                
                                let cellIndexPath = IndexPath(item: item, section: section)
                                
                                xPos = Double(item) * cellWidth!
                                
                                
                                var cellAttributes = UICollectionViewLayoutAttributes(forCellWith: cellIndexPath)
                                cellAttributes.frame = CGRect(x: xPos!, y: Double(yPos!), width: cellWidth!, height: cellHeight!)
                                cellAttributes.zIndex = 1
                                
                                cellAttrDictionary[cellIndexPath] = cellAttributes
                                
                                if section == 0 {
                                    contentSizeSection0 = CGSize(width: cellAttributes.frame.maxX, height: UIScreen.main.bounds.size.height)
                                } else {
                                    contentSizeSection1 = CGSize(width: cellAttributes.frame.maxX, height: UIScreen.main.bounds.size.height)
                                }
                                
                                
                                                                
                            }
                        }
                    }
                }
            }
        }
    }
    
    override var collectionViewContentSize: CGSize {
        
        if contentSizeSection0.width > contentSizeSection1.width {
            contentSize = contentSizeSection0
        } else {
            contentSize = contentSizeSection1
        }
        
        return contentSize
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var attributes = [UICollectionViewLayoutAttributes]()
        if self.cellAttrDictionary.count > 0 {
            for (_, value) in self.cellAttrDictionary {
                
                if rect.contains(value.frame) {
                    attributes.append(value)
                }
            }
        }
        
        return attributes
        
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return self.cellAttrDictionary[indexPath]
        
    }
    
}
