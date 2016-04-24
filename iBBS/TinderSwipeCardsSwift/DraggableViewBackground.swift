//
//  DraggableViewBackground.swift
//  TinderSwipeCardsSwift
//
//  Created by Gao Chao on 4/30/15.
//  Copyright (c) 2015 gcweb. All rights reserved.
//

import Foundation
import UIKit



class DraggableViewBackground: UIVisualEffectView, DraggableViewDelegate {
    var exampleCardLabels: [String]!
    var allCards: [DraggableView]!

    let MAX_BUFFER_SIZE = 1

    var cardsLoadedIndex: Int!
    var loadedCards: [DraggableView]!
    var menuButton: UIButton!
    var messageButton: UIButton!
    var checkButton: UIButton!
    var xButton: UIButton!
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(effect: UIVisualEffect?) {
        super.init(effect: effect)
        setupView()
        exampleCardLabels = ["first"]
        allCards = []
        loadedCards = []
        cardsLoadedIndex = 0
        loadCards()
    }

    func setupView() {
        
//        xButton = UIButton(frame: CGRectMake((self.frame.size.width - CARD_WIDTH)/2 + 35, self.frame.size.height/2 + CARD_HEIGHT/2 + 10, 59, 59))
//        xButton.setImage(UIImage(named: "xButton"), forState: UIControlState.Normal)
//        xButton.addTarget(self, action: "swipeLeft", forControlEvents: UIControlEvents.TouchUpInside)
//
//        checkButton = UIButton(frame: CGRectMake(self.frame.size.width/2 + CARD_WIDTH/2 - 85, self.frame.size.height/2 + CARD_HEIGHT/2 + 10, 59, 59))
//        checkButton.setImage(UIImage(named: "checkButton"), forState: UIControlState.Normal)
//        checkButton.addTarget(self, action: "swipeRight", forControlEvents: UIControlEvents.TouchUpInside)
//
//        if !isIphone3_5Inch {
//            self.addSubview(xButton)
//            self.addSubview(checkButton)
//        }
        
    }

    func createDraggableViewWithDataAtIndex(index: NSInteger) -> DraggableView {
        let draggableView = DraggableView()
        draggableView.delegate = self
        return draggableView
    }

    func loadCards() {
        
        if exampleCardLabels.count > 0 {
            
            let numLoadedCardsCap = min(exampleCardLabels.count, MAX_BUFFER_SIZE)
            
            for i in 0 ..< exampleCardLabels.count {
                let newCard: DraggableView = self.createDraggableViewWithDataAtIndex(i)
                allCards.append(newCard)
                if i < numLoadedCardsCap {
                    loadedCards.append(newCard)
                }
            }
            
            for i in 0 ..< loadedCards.count {
                if i > 0 {
                    insertSubview(loadedCards[i], belowSubview: loadedCards[i - 1])
                } else {
                    addSubview(loadedCards[i])
                }
                
                loadedCards[i].snp_makeConstraints(closure: { (make) in
                    make.edges.equalTo(UIEdgeInsetsMake(40, 12, -16, -12))
                })
                
                cardsLoadedIndex = cardsLoadedIndex + 1
            }
        }
    }

    func cardSwipedLeft(card: UIView) {
        loadedCards.removeAtIndex(0)

        if cardsLoadedIndex < allCards.count {
            loadedCards.append(allCards[cardsLoadedIndex])
            cardsLoadedIndex = cardsLoadedIndex + 1
            self.insertSubview(loadedCards[MAX_BUFFER_SIZE - 1], belowSubview: loadedCards[MAX_BUFFER_SIZE - 2])
        }
    }
    
    func cardSwipedRight(card: UIView) {
        loadedCards.removeAtIndex(0)
        
        if cardsLoadedIndex < allCards.count {
            loadedCards.append(allCards[cardsLoadedIndex])
            cardsLoadedIndex = cardsLoadedIndex + 1
            self.insertSubview(loadedCards[MAX_BUFFER_SIZE - 1], belowSubview: loadedCards[MAX_BUFFER_SIZE - 2])
        }
    }

}