//
//  ScoreData.swift
//  IkramMazeMan
//
//  Created by cstech on 4/18/18.
//  Copyright © 2018 cstech. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit
import GameplayKit

class ScoreData
{
    static var threeHighestScores = [Int]()
    
    init()
    {
        
    }
    
    static func addNewScore(SCORE: Int)
    {
        var added = false
        if(threeHighestScores.count == 0)
        {
            threeHighestScores.append(SCORE)
        }
        else
        {
            for i in stride(from: 0, to: threeHighestScores.count, by: 1)
            {
                if SCORE > threeHighestScores[i]
                {
                    threeHighestScores.insert(SCORE, at: i) //insert and shift the rest of the scores (O(n))
                    added = true
                }
            }
            if(threeHighestScores.count < 3 && added == false)
            {
                threeHighestScores.append(SCORE)
                added = true
            }
        }
    }
}
