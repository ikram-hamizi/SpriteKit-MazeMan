//
//  GameOverScene.swift
//  IkramMazeMan
//
//  Created by Ikram Hamizi on 04/15/18.
//  Copyright © 2018 Ikram Hamiz. All rights reserved.
//


import UIKit
import SpriteKit
import GameplayKit

class GameOverScene: SKScene {
    
    var highestScores: [Int]?
    var score: Int?
    
    init(size: CGSize, won: Bool) {
        super.init(size: size)
        
        let gameOverLabel = SKLabelNode(fontNamed: "Chalkduster")
        gameOverLabel.text = (won ? "You Win!" : "Game Over")
        gameOverLabel.fontSize = 60
        
        gameOverLabel.position = CGPoint(x: size.width/2, y: size.height/2)
        self.addChild(gameOverLabel)
    }
    
    override func didMove(to view: SKView)
    {
        let currentScoreLabel = SKLabelNode(fontNamed: "AmericanTypewriter")
        currentScoreLabel.text = ("Your Score is: \(score!)")
        currentScoreLabel.fontSize = 35
        
        currentScoreLabel.position = CGPoint(x: size.width/2, y: size.height/2 - 50)
        self.addChild(currentScoreLabel)
        
        
        
        if let s = score
        {
            ScoreData.addNewScore(SCORE: s)
            highestScores = ScoreData.threeHighestScores

            for i in 0...highestScores!.count-1
            {
                let threeHighestScores = SKLabelNode(fontNamed: "Avenir-Light")
                threeHighestScores.text = ("Score \(i+1): \(highestScores![i])")
                threeHighestScores.fontSize = 25
                
                threeHighestScores.position = CGPoint(x: size.width/2, y: currentScoreLabel.position.y - 40 - CGFloat(30*i))
                self.addChild(threeHighestScores)
            }
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // transition to game over scene
        
        let doorTrans = SKTransition.doorway(withDuration: 1)
        let newScene = GameScene(size: self.size)
        newScene.scaleMode = .aspectFill
        self.view?.presentScene(newScene, transition: doorTrans)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


