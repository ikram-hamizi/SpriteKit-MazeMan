//  VCU - SPRING 2018 - Dr. Eyuphan Bulut
//  GameScene.swift
//  IkramMazeMan
//
//  Created by Ikram Hamizi on 4/9/18.
//  Copyright © 2018 Ikram Hamizi. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation

//- GAME Specifications:

// IPad Pro 12.9-inch (1024/1366)
// Grids for game: 16 * 9 (-top and bottom blocks)

class GameScene: SKScene, SKPhysicsContactDelegate, UIGestureRecognizerDelegate{
    
    //SK Sprite Nodes
    private var block: SKSpriteNode!
    private var caveman: SKSpriteNode!
    
    private var star: SKSpriteNode!
    private var food: SKSpriteNode!
    
    private var dino1: SKSpriteNode!
    private var dino2: SKSpriteNode!
    private var dino3: SKSpriteNode!
    private var dino4: SKSpriteNode!
    
    private var ipad_edge_left: SKSpriteNode!
    private var ipad_edge_right: SKSpriteNode!
    
    private var panel: SKSpriteNode!
    private var label: SKLabelNode!
    
    private var STAR_PIC: SKSpriteNode!
    private var ROCK_PIC: SKSpriteNode!
    private var HEART_PIC: SKSpriteNode!
    private var ENERGY_PIC: SKSpriteNode!
    
    private var STAR_LBL: SKLabelNode!
    private var ROCK_LBL: SKLabelNode!
    private var HEART_LBL: SKLabelNode!
    private var ENERGY_LBL: SKLabelNode!
    
    //Gesture Recognizers
    private let swipeLeftRecog = UISwipeGestureRecognizer()
    private let swipeRightRecog = UISwipeGestureRecognizer()
    private let swipeUpRecog = UISwipeGestureRecognizer()
    private let swipeDownRecog = UISwipeGestureRecognizer()
        
    //Vars
    private var maxBlockCount = 15
    private var grids: [[CGFloat]]! //Size
    private var energyIsZero = false
    private var threeHighestScores: [Int]!
    
    private var SCORE = 0 //COUNT OF STARS
    private var ENERGY = 300
    private var HEARTS = 3.0
    private var ROCKS = 20
    
    //Time vars
    private var rand_gravity_time_in_range = 60
    private var timer_BlocksAppear = Timer()
    private var earnNewRocksTimeCounter = 0
    private var gravityTimeCounter = 0
    private var initialTime: TimeInterval!
    private var initialTimeIsInitialized = false
    
    //Sound vars
    private let enemyBiteSoundPATH = Bundle.main.path(forResource: "bite", ofType: "wav") //1. PATH of file
    private let eatFoodSoundPATH = Bundle.main.path(forResource: "eatfood", ofType: "mp3")
    private let deathSoundPATH = Bundle.main.path(forResource: "death", ofType: "wav")
    private let eatStarSoundPATH = Bundle.main.path(forResource: "eatstar", ofType: "mp3")
    private let throwRockSoundPATH = Bundle.main.path(forResource: "rock", ofType: "mp3")
    private let waterSoundPATH = Bundle.main.path(forResource: "water", ofType: "mp3")
    private let fireSoundPATH = Bundle.main.path(forResource: "fire", ofType: "mp3")
    
    private var soundURL: URL!//2. Make it into a URL form
    private var AUDIOPLAYER: AVAudioPlayer! //3. Create and Audio Player
    
    override func didMove(to view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        
        //INITIALIZATION
        grids = [[CGFloat]]()
        
        //1 - set up background
        let backgroundIMG = SKSpriteNode(imageNamed: "bg")
        backgroundIMG.position = CGPoint(x: frame.size.width/2, y:frame.size.height/2)
        backgroundIMG.size = view.frame.size
        addChild(backgroundIMG)
        backgroundIMG.zPosition = -100
        
        
        //2 - set up initial bottom and top blocks
        if initialBlocks()
        {
            //3- Put all the instances of enemy-types
            if INIT()
            {
                //4- Put random blocks on screen
                timer_BlocksAppear = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(blockAppearStart), userInfo: nil, repeats: true)
                //>> Timer.scheduledTimer - API that adds the timer implicitly to the runloop:
            }
        }
    }
    
    //1- Set up initial bottom and top blocks
    private func initialBlocks() -> Bool
    {
        block = SKSpriteNode(imageNamed: "block")
        block.size = CGSize(width: 85.375, height: 85.375)
        var i = CGFloat(0)
        var count = 0
        
        var imageName = "block"
        while (i <= CGFloat(1366 - block.frame.width))
        {
            //Bottom Blocks (1 row)
            if(i == 5*CGFloat(block.frame.width) || i == 11*CGFloat(block.frame.width))
            {
                imageName = "water"
            }
            else
            {
                imageName = "block"
            }
            
            let blockI = SKSpriteNode(imageNamed: imageName)
            blockI.size = CGSize(width: 85.375, height: 85.375)
            blockI.position = CGPoint(x: block.frame.width/2 + i, y:block.frame.width/2)
            blockI.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 83, height: 83))
            blockI.physicsBody?.affectedByGravity = false
            blockI.zPosition = 700
            blockI.physicsBody?.isDynamic = false
            
            if(i == 5*block.frame.width || i == block.frame.width*11)
            {
                blockI.name = "water"
                blockI.physicsBody?.categoryBitMask = PhysicsCategoryStruct.water
            }
            else
            {
                blockI.name = "block"
                blockI.physicsBody?.categoryBitMask = PhysicsCategoryStruct.block
            }
            blockI.physicsBody?.contactTestBitMask = PhysicsCategoryStruct.caveman | PhysicsCategoryStruct.dino3collider
            blockI.physicsBody?.collisionBitMask = PhysicsCategoryStruct.caveman | PhysicsCategoryStruct.dino3collider
            addChild(blockI)
            
            //ADD SCORE + PANELS
            switch(count)
            {
            case 0:
                count += 1 //Start
                STAR_PIC = SKSpriteNode(imageNamed: "star")
                STAR_PIC.size = CGSize(width: 85.375, height: 85.375)
                STAR_PIC.zPosition = 701
                blockI.addChild(STAR_PIC)
                
                STAR_LBL = SKLabelNode(fontNamed: "Chalkduster") //INIT
                STAR_LBL.color = SKColor.white
                STAR_LBL.text = "\(SCORE)"
                STAR_LBL.fontSize = 42
                STAR_LBL.zPosition = 702
                STAR_LBL.position = CGPoint(x: STAR_PIC.frame.midX, y: STAR_PIC.frame.midY-3)
                STAR_PIC.addChild(STAR_LBL)
                
            case 1:
                ROCK_PIC = SKSpriteNode(imageNamed: "rock")
                ROCK_PIC.size = CGSize(width: 85.375, height: 85.375)
                ROCK_PIC.zPosition = 701
                blockI.addChild(ROCK_PIC)
                
                ROCK_LBL = SKLabelNode(fontNamed: "Chalkduster") //INIT
                ROCK_LBL.color = SKColor.white
                ROCK_LBL.text = "\(ROCKS)"
                ROCK_LBL.zPosition = 702
                ROCK_LBL.fontSize = 42
                ROCK_LBL.position = CGPoint(x: ROCK_PIC.frame.midX, y: ROCK_PIC.frame.midY-3)
                ROCK_PIC.addChild(ROCK_LBL)
                
                count += 1
            case 2:
                HEART_PIC = SKSpriteNode(imageNamed: "heart")
                HEART_PIC.size = CGSize(width: 85.375, height: 85.375)
                HEART_PIC.zPosition = 701
                blockI.addChild(HEART_PIC)
                
                HEART_LBL = SKLabelNode(fontNamed: "Chalkduster") //INIT
                HEART_LBL.color = SKColor.white
                HEART_LBL.text = "\(Int(HEARTS.rounded(.up)))"
                HEART_LBL.fontSize = 42
                HEART_LBL.zPosition = 702
                HEART_LBL.position = CGPoint(x: HEART_PIC.frame.midX, y: HEART_PIC.frame.midY-3)
                HEART_PIC.addChild(HEART_LBL)
                
                count += 1
            case 3:
                ENERGY_PIC = SKSpriteNode(imageNamed: "battery")
                ENERGY_PIC.size = CGSize(width: 100, height: 140)
                ENERGY_PIC.zPosition = 701
                blockI.addChild(ENERGY_PIC)
                
                ENERGY_LBL = SKLabelNode(fontNamed: "Chalkduster") //INIT
                ENERGY_LBL.color = SKColor.white
                ENERGY_LBL.text = "\(ENERGY)"
                ENERGY_LBL.zPosition = 702
                ENERGY_LBL.position = CGPoint(x: ENERGY_PIC.frame.midX + 2, y: ENERGY_PIC.frame.midY-7)
                ENERGY_LBL.fontSize = 35
                ENERGY_PIC.addChild(ENERGY_LBL)
                
                count += 1
            default:
                break
            }
            
            //Top Blocks (2 rows)
            let blockII = SKSpriteNode(imageNamed: "block")
            blockII.size = CGSize(width: 85.375, height: 85.375)
            blockII.position = CGPoint(x: block.frame.width/2 + i, y:1024-block.frame.width/2)
            blockII.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 83, height: 83))
            blockII.physicsBody?.affectedByGravity = false
            blockII.physicsBody?.isDynamic = false
            blockII.physicsBody?.categoryBitMask = PhysicsCategoryStruct.block
            blockII.physicsBody?.contactTestBitMask = PhysicsCategoryStruct.caveman
            blockII.physicsBody?.collisionBitMask = PhysicsCategoryStruct.caveman
            blockII.name = "block"
            blockII.zPosition = 700
            addChild(blockII)
            
            let blockIII = SKSpriteNode(imageNamed: "block")
            blockIII.size = CGSize(width: 85.375, height: 85.375)
            blockIII.position = CGPoint(x: block.frame.width/2 + i, y:1024-3*(block.frame.width)/2)
            blockIII.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 83, height: 83))
            blockIII.physicsBody?.affectedByGravity = false
            blockIII.physicsBody?.isDynamic = false
            blockIII.physicsBody?.categoryBitMask = PhysicsCategoryStruct.block
            blockIII.physicsBody?.contactTestBitMask = PhysicsCategoryStruct.caveman
            blockIII.physicsBody?.collisionBitMask = PhysicsCategoryStruct.caveman
            blockIII.name = "block"
            blockIII.zPosition = 700
            addChild(blockIII)
            
            i += block.frame.width
        }
        return true
    }
    
    //2- ADDING SPRITE NODES + INIT
    private func INIT() -> Bool
    {
        //1. One instance of each enemy type (5 types) is added to the game at the beginning, a new one of the same type each time on is killed after [1-5] seconds
        
        addCaveMan()
        
        addDino1()
        addDino2()
        addDino3()
        addDino4()
        
        //- Enemies can go through blocks (contact)
        //- They are killed by rocks thrown by player
        //- Move slightly faster than player
        
        addIPadScreenEdgeWalls()
        
        //2. Initial Star + Food
        star = addStar()
        addChild(star)
        food = addFood()
        addChild(food)
        
        //3. Gesture Recognizers for Caveman
        addGestureRecognizerCaveman()
        
        //4- Add Game Status Panel
        addGreenGameStatusPanel()
        
        //5- Timer: (decrement energy)
        startEnergyDecrementingTimer()
        return true
    }
    
    private func startEnergyDecrementingTimer()
    {
        let wait = SKAction.wait(forDuration: 1)
        let energy_decrementer = SKAction.run {
            self.ENERGY -= 1
            self.ENERGY_LBL.text = "\(self.ENERGY)"
        }
        let checkEnergyGameOver = SKAction.run {
            if self.ENERGY == 0
            {
                self.gameOver(won: false)
            }
        }
        run(SKAction.repeatForever(SKAction.sequence([energy_decrementer, wait, checkEnergyGameOver])))
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        if(initialTimeIsInitialized == false) //Once
        {
            initialTime = currentTime
            initialTimeIsInitialized = true
        }
        
        if(Int(currentTime - initialTime) == 1)
        {
            initialTime = currentTime
            earnNewRocksTimeCounter += 1
            if (earnNewRocksTimeCounter == 30)
            {
                earnNewRocksTimeCounter = 0 //RESET
                if (ROCKS < 10) { ROCKS = 10 } else { ROCKS = 20 } //Earn 10 rocks every 30 seconds
            }
            
            gravityTimeCounter += 1
            //print ("Gravity time = \(gravityTimeCounter)") //Debug
            if(gravityTimeCounter == 40)
            {
                rand_gravity_time_in_range = Int(arc4random_uniform(21) + 40) //(B - A  + 1) + A -> [A - B]
                
                updateGreenGameStatusPanel(message: "WARNING: Gravity will be enabled in \(rand_gravity_time_in_range - gravityTimeCounter) seconds...", color: .red)
                //print ("! -> = Gravity will be enabled at time = \(rand_gravity_time_in_range)") //Debug
            }
            
            //Gravity enabled for 1 second after every random time in range [40-60]
            if (Int(rand_gravity_time_in_range) == gravityTimeCounter)
            {
                updateGreenGameStatusPanel(message: "ALERT: GRAVITY ENABLED", color: .red)
                enableGravityCavemanForOneSecond()
            }
            if (gravityTimeCounter == rand_gravity_time_in_range + 1)
            {
                updateGreenGameStatusPanel(message: "GRAVITY DISABELED", color: .white)
                //print ("GRAVITY DISABELED") //Debug
                disableGravityCaveman()
                gravityTimeCounter = 0 //RESET
            }
        }
        
        if (ENERGY == 0 && energyIsZero == false)
        {
            energyIsZero = true
            updateGreenGameStatusPanel(message: "One (♡) heart lost", color: .magenta)
            HEARTS -= 1
            HEART_LBL.text = "\(Int(HEARTS.rounded(.up)))"
        }
        
        if HEARTS == 0
        {
            HEART_LBL.text = "\(0)"
            caveman.removeFromParent()
            gameOver(won: false)
        }
    }

    private func enableGravityCavemanForOneSecond()
    {
        caveman.physicsBody?.affectedByGravity = true
    }
    private func disableGravityCaveman()
    {
        caveman.physicsBody?.affectedByGravity = false
    }
    
    private func checkEnergyValueUpdateHeart()
    {
        let a = SKAction.scale(by: 1.4, duration: 0.7)
        let b = SKAction.scale(by: 1/1.4, duration: 0.7)
        
        if (ENERGY % 300 == 0)
        {
            HEART_LBL.text = "\(Int(HEARTS.rounded(.up)))"
        }
        else if (ENERGY % 200 == 0 || ENERGY % 200 < 100)
        {
            HEART_PIC.alpha = 0.8
            HEART_PIC.run(SKAction.sequence([a, b]))
            HEART_LBL.text = "\(Int(HEARTS.rounded(.up)))"
        }
        else if (ENERGY % 100 == 0)
        {
            HEART_PIC.alpha = 0.6
            HEART_PIC.run(SKAction.sequence([a, b]))
            HEART_LBL.text = "\(Int(HEARTS.rounded(.up)))"
        }
        else if (ENERGY <= 0 && energyIsZero == false)
        {
            energyIsZero = true
            HEARTS -= 1
        }
        else if (HEARTS <= 0)
        {
            HEART_LBL.text = "\(0)"
            print("GAMEU OVER") //DEBUG
            caveman.removeFromParent()
            gameOver(won: false)
        }
    }
   
    
    private func addGreenGameStatusPanel()
    {
        //1- Add green Panel
        panel = SKSpriteNode(imageNamed: "game-status-panel")
        panel.size = CGSize(width: 966, height: 95)
        panel.position = CGPoint(x: 683, y:1024-block.frame.width+6)
        panel.name = "panel"
        panel.zPosition = 710
        addChild(panel)
        
        //2 - hello, label
        
        label = SKLabelNode(text: "HELLO, WELCOME TO MAZEMAN")
        label.fontName = "AmericanTypewriter"
        label.fontSize = 30
        label.zPosition = 720
        label.fontColor = SKColor.white
        
        panel.addChild(label)
    }
    
    private func updateGreenGameStatusPanel(message: String, color: SKColor)
    {
        label.text = message
        label.fontColor = color
    }
    
    private func addGestureRecognizerCaveman()
    {
        swipeLeftRecog.addTarget(self, action: #selector(cavemanSwipedLeft))
        swipeLeftRecog.direction = .left
        swipeLeftRecog.delaysTouchesBegan = true
        swipeLeftRecog.delegate = self
        self.view?.addGestureRecognizer(swipeLeftRecog)

        swipeRightRecog.addTarget(self, action: #selector(cavemanSwipedRight))
        swipeRightRecog.direction = .right
        swipeRightRecog.delaysTouchesBegan = true
        swipeRightRecog.delegate = self
        self.view?.addGestureRecognizer(swipeRightRecog)

        swipeUpRecog.addTarget(self, action: #selector(cavemanSwipedUp))
        swipeUpRecog.direction = .up
        swipeUpRecog.delegate = self
        swipeUpRecog.delaysTouchesBegan = true
        self.view?.addGestureRecognizer(swipeUpRecog)

        swipeDownRecog.addTarget(self, action: #selector(cavemanSwipedDown))
        swipeDownRecog.direction = .down
        swipeDownRecog.delegate = self
        swipeDownRecog.delaysTouchesBegan = true
        self.view?.addGestureRecognizer(swipeDownRecog)
 
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let location_touch = touches.first?.location(in: self.view) //To be converted
        {
            //print("UIView touch: \(location_touch)") //DEBUG
            let location_touch_converted_SK = CGPoint(x: location_touch.x, y: 1024-location_touch.y)
            //print ("SKView touch: SHOOOOOOT THERE ---> \(location_touch_converted_SK)") //DEBUG
            //LOCATION IS IN UIKIT (0,0) Upper corner coordinates
            
            let throwrock = SKAction.run
            {
                self.cavemanThrowRock(towards: location_touch_converted_SK)
            }
            let seq = SKAction.sequence([throwrock, SKAction.wait(forDuration: 0.2)]) //cannot shoot within duration
            run(seq)
        }
    }

    @objc private func cavemanSwipedUp()
    {
        let move_up = SKAction.moveBy(x: 0, y: 135, duration: 1)
        caveman.run(SKAction.repeatForever(move_up) , withKey: "moving")
    }
    
    @objc private func cavemanSwipedDown()
    {
        let move_down = SKAction.moveBy(x: 0, y: -135, duration: 1)
        caveman.run(SKAction.repeatForever(move_down), withKey: "moving")
    }
    
    @objc private func cavemanSwipedLeft()
    {
        var xscale = CGFloat(0)
        if (caveman.xScale == 1 || caveman.xScale == 0) { xscale = -1 } else { xscale = caveman.xScale }
        let mirrorx = SKAction.scaleX(to: CGFloat(xscale), duration: 0)
        let move_left = SKAction.moveBy(x: -135, y: 0, duration: 1)
        
        caveman.run(SKAction.sequence([mirrorx]), withKey: "moving")
        caveman.run(SKAction.repeatForever(move_left))
    }

    @objc private func cavemanSwipedRight()
    {
        var xscale = CGFloat(0)
        if (caveman.xScale == 0 || caveman.xScale == -1) { xscale = 1 } else { xscale = caveman.xScale }

        let mirrorx = SKAction.scaleX(to: xscale, duration: 0)
        let move_right = SKAction.moveBy(x: 135, y: 0, duration: 1)
        caveman.run(SKAction.sequence([mirrorx]), withKey: "moving")
        caveman.run(SKAction.repeatForever(move_right))
    }

    
    
    private func addIPadScreenEdgeWalls()
    {
        ipad_edge_left = SKSpriteNode()
        ipad_edge_left.position = CGPoint(x: 0, y: 0)
        ipad_edge_left.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 10, height:self.frame.height * 2))
        ipad_edge_left.physicsBody?.isDynamic = false
        ipad_edge_left.physicsBody?.categoryBitMask = PhysicsCategoryStruct.ipad_edge_left
       
        ipad_edge_left.name = "ipad_edge_left"
        addChild(ipad_edge_left)
        
        ipad_edge_right = SKSpriteNode()
        ipad_edge_right.position = CGPoint(x: 1366, y: 0)
        ipad_edge_right.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 10, height:self.frame.height * 2))
        ipad_edge_right.physicsBody?.isDynamic = false
        ipad_edge_right.physicsBody?.categoryBitMask = PhysicsCategoryStruct.ipad_edge_right
        
        ipad_edge_right.name = "ipad_edge_right"
        addChild(ipad_edge_right)
    }
    
    private func addCaveMan()
    {
        caveman = SKSpriteNode(imageNamed: "caveman")
        caveman.size = CGSize(width: 85.375, height: 85.375)
        caveman.position = CGPoint(x: block.frame.width + block.frame.width/2, y: block.frame.height+block.frame.height/2)
        
        grids.append([1,1])
        caveman.zPosition = 700
        caveman.physicsBody = SKPhysicsBody(circleOfRadius: (caveman.frame.width - 8)/2)
        caveman.physicsBody?.affectedByGravity = false
        caveman.physicsBody?.allowsRotation = false
        caveman.physicsBody?.isDynamic = true //True enabled collision (why?)
        
        caveman.physicsBody?.categoryBitMask = PhysicsCategoryStruct.caveman
        
        caveman.physicsBody?.contactTestBitMask = PhysicsCategoryStruct.block | PhysicsCategoryStruct.dino1 | PhysicsCategoryStruct.dino2 | PhysicsCategoryStruct.dino3collider | PhysicsCategoryStruct.food | PhysicsCategoryStruct.star | PhysicsCategoryStruct.fire | PhysicsCategoryStruct.ipad_edge_right | PhysicsCategoryStruct.ipad_edge_left | PhysicsCategoryStruct.water
        
        caveman.physicsBody?.collisionBitMask = PhysicsCategoryStruct.block | PhysicsCategoryStruct.dino1 | PhysicsCategoryStruct.dino2 | PhysicsCategoryStruct.dino3collider | PhysicsCategoryStruct.fire | PhysicsCategoryStruct.ipad_edge_right | PhysicsCategoryStruct.ipad_edge_left | PhysicsCategoryStruct.water
        
        caveman.name = "caveman"
        addChild(caveman)
    }
    
    private func cavemanRock() -> SKSpriteNode
    {
        var rock: SKSpriteNode!
        rock = SKSpriteNode(imageNamed: "rock")
        rock.size = CGSize(width: 65, height: 65)
        rock.position = CGPoint(x: caveman.position.x, y: caveman.position.y)
        rock.zPosition = 700
        rock.physicsBody = SKPhysicsBody(circleOfRadius: (rock.frame.width+6)/2)
        rock.physicsBody?.affectedByGravity = false
        rock.physicsBody?.isDynamic = true
        
        rock.physicsBody?.categoryBitMask = PhysicsCategoryStruct.rock
        rock.physicsBody?.contactTestBitMask = PhysicsCategoryStruct.dino1 | PhysicsCategoryStruct.dino2 | PhysicsCategoryStruct.dino3collider
        rock.physicsBody?.collisionBitMask = 0
        
        rock.name = "rock"
        return rock
    }

    private func cavemanThrowRock(towards: CGPoint)
    {
        if ROCKS > 0
        {
            let rock = cavemanRock() //Call function
            addChild(rock)
            
            //Pythagorean Thm
            var Vec_dx = CGFloat(towards.x - caveman.position.x)
            var Vec_dy = CGFloat(towards.y - caveman.position.y)
            let VecMagnitude = sqrt(Vec_dx*Vec_dx + Vec_dy*Vec_dy)
            
            Vec_dx = Vec_dx/VecMagnitude
            Vec_dy = Vec_dy/VecMagnitude
            
            let vector = CGVector(dx: 70.0 * Vec_dx, dy: 70.0 * Vec_dy)
            
            rock.physicsBody?.applyImpulse(vector)
            ROCKS -= 1
            ROCK_LBL.text = "\(ROCKS)"
            
            soundURL = URL(fileURLWithPath: self.throwRockSoundPATH!) //Make it a URL
            AUDIOPLAYER = try? AVAudioPlayer(contentsOf: self.soundURL)
            AUDIOPLAYER.play()
            
        }
    }
    
    private func addDino1()
    {
        //1- Entry point (water block)
        dino1 = SKSpriteNode(imageNamed: "dino1")
        dino1.size = CGSize(width: block.frame.width, height: block.frame.height)
        
        //[A, B] ->     (B - A + 1) + A
        //[0, N - 1] -> (N)
        
        let randWater = arc4random_uniform(2) //either 5 or 11 blocks away from origin
        if randWater == 0
        {
            dino1.position = CGPoint(x: dino1.frame.width/2 + 5 * dino1.frame.width, y:dino1.frame.width/2)
        }
        else
        {
            dino1.position = CGPoint(x: dino1.frame.width/2 + 11 * dino1.frame.width, y:dino1.frame.width/2)
        }
        dino1.zPosition = 700
        dino1.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: dino1.frame.width-10, height: dino1.frame.height-10))
        dino1.physicsBody?.affectedByGravity = false
        dino1.physicsBody?.isDynamic = true
        
        dino1.physicsBody?.categoryBitMask = PhysicsCategoryStruct.dino1
        dino1.physicsBody?.contactTestBitMask = PhysicsCategoryStruct.food | PhysicsCategoryStruct.rock
        dino1.physicsBody?.collisionBitMask = PhysicsCategoryStruct.rock
        
        dino1.name = "dino1"
        addChild(dino1)
        
        //2- Behavior: move up and down, wait randomly [1-3] seconds
        let rand_waiting_time = arc4random_uniform(3) + 1 //[1-3]
        
        let move_up = SKAction.move(by: CGVector(dx: 0, dy: 765), duration: 9)
        move_up.timingMode = .easeIn
        let wait = SKAction.wait(forDuration: TimeInterval(rand_waiting_time))
        let move_down = SKAction.move(by: CGVector(dx: 0, dy: -765), duration: 10)
        let sequence = SKAction.sequence([move_up, wait, move_down, wait])
        let updown = SKAction.repeatForever(sequence)
        dino1.run(updown)
    }
    
    private func addDino2()
    {
        //1- Entry point (right of screen, any row)
        
        let rand_grid_y = arc4random_uniform(9) + 1
        
        dino2 = SKSpriteNode(imageNamed: "dino2")
        dino2.size = CGSize(width: block.frame.width, height: block.frame.height)
        dino2.position = CGPoint(x: dino2.frame.width/2 + 15*dino2.frame.width, y:dino2.frame.width/2 + CGFloat(rand_grid_y) * dino2.frame.width)
        dino2.zPosition = 700
        dino2.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: dino2.frame.width-15, height: dino2.frame.height-20))
        dino2.physicsBody?.affectedByGravity = false
        dino2.physicsBody?.isDynamic = true
        
        dino2.physicsBody?.categoryBitMask = PhysicsCategoryStruct.dino2
        dino2.physicsBody?.contactTestBitMask = PhysicsCategoryStruct.food | PhysicsCategoryStruct.rock
        dino2.physicsBody?.collisionBitMask = PhysicsCategoryStruct.rock
        dino2.name = "dino2"
        addChild(dino2)
        
        //2- Behavior: move right and left, wait randomly [1-3] seconds. Facing direction changes accordingly.
        let rand_waiting_time = arc4random_uniform(3) + 1 //[1-3]
        
        let move_left = SKAction.move(by: CGVector(dx: -1355, dy: 0), duration: 8)
        let wait = SKAction.wait(forDuration: TimeInterval(rand_waiting_time))
        let move_right = SKAction.move(by: CGVector(dx: 1355, dy: 0), duration: 10)
        
        let mirror = SKAction.scaleX(to: -1, duration: 0)
        let mirror2 = SKAction.scaleX(to: 1, duration: 0)
        let sequence = SKAction.sequence([move_left, wait, mirror, move_right, mirror2, wait])
        let rightleft = SKAction.repeatForever(sequence)
        dino2.run(rightleft)
    }
    
    private func addDino3()
    {
        //1- //Upper left corner, facing right
        dino3 = SKSpriteNode(imageNamed: "dino3")
        dino3.size = CGSize(width: 75, height: 75)
        dino3.position = CGPoint(x: dino3.frame.width/2, y:dino3.frame.width/2 + 9 * dino3.frame.width)
        dino3.zPosition = 700
        
        addChild(dino3)
        
        //2- Behavior: Can go all directions. Selects a random direction and continue till it hits another object (including blocks). Facing direction changes accordingly.
        
        //func here
      
        //--SET PHYSICS BODY AND COLLISION PROPERTIES. --------------
        dino3.physicsBody = SKPhysicsBody(circleOfRadius: (dino3.frame.width - 10)/2)
        dino3.physicsBody?.affectedByGravity = false
        dino3.physicsBody?.restitution = 1 //? bounce > 0
        
        //1. Assign bitmask
        dino3.physicsBody?.categoryBitMask = PhysicsCategoryStruct.dino3collider
        
        //2. Test if we collided with something
        dino3.physicsBody?.contactTestBitMask = PhysicsCategoryStruct.block | PhysicsCategoryStruct.dino1 | PhysicsCategoryStruct.dino2 | PhysicsCategoryStruct.food | PhysicsCategoryStruct.star | PhysicsCategoryStruct.ipad_edge_left | PhysicsCategoryStruct.ipad_edge_right | PhysicsCategoryStruct.rock | PhysicsCategoryStruct.caveman
        
        //3. >>>>> Calls didBegin(_ contact) if it collides with something, and test things accordingly (only call if they both connect).
        dino3.physicsBody?.collisionBitMask = PhysicsCategoryStruct.block | PhysicsCategoryStruct.dino1 | PhysicsCategoryStruct.dino2 | PhysicsCategoryStruct.food | PhysicsCategoryStruct.star | PhysicsCategoryStruct.ipad_edge_left | PhysicsCategoryStruct.ipad_edge_right | PhysicsCategoryStruct.rock | PhysicsCategoryStruct.caveman
        
        //4. Assign name to node
        dino3.name = "dino3"
        
        //--DONE SETTING PHYSICS BODY. -------------------------------
        dino3ChangeDirection()
    }
    
    //*******************************************************************************
    //3- Functions related to didBegin(_ contact) : Collide | Contact
    
    private struct PhysicsCategoryStruct
    {
        static let dino3collider: UInt32 = 0x1 << 1
        static let dino1: UInt32 = 0x1 << 2
        static let dino2: UInt32 = 0x1 << 3  //(dino4 does not touch dino3)
        static let block: UInt32 = 0x1 << 4
        static let star: UInt32 = 0x1 << 5
        static let food: UInt32 = 0x1 << 6
        
        static let ipad_edge_left: UInt32 = 0x1 << 7
        static let ipad_edge_right: UInt32 = 0x1 << 8
        
        static let caveman: UInt32 = 0x1 << 9
        static let rock: UInt32 = 0x1 << 10
        static let fire: UInt32 = 0x1 << 11
        static let water: UInt32 = 0x1 << 12
    }
    
    //Func from SKPhysicsContactDelegate: Called automatically (cannot be private)
    func didBegin(_ contact: SKPhysicsContact) {
        
        if let firstbody = contact.bodyA.node as? SKSpriteNode, let secondbody = contact.bodyB.node as? SKSpriteNode {
            
            //1~ If Dino3 collided with an object -> change direction
            if (((firstbody.name == "dino3") && (secondbody.name == "block" || secondbody.name == "dino1" || secondbody.name == "dino2" || secondbody.name == "star" || secondbody.name == "food" || secondbody.name == "ipad_edge_left" || secondbody.name == "ipad_edge_right" || secondbody.name == "caveman"))
                
                || ((secondbody.name == "dino3") && (firstbody.name == "block" || firstbody.name == "dino1" || firstbody.name == "dino2" || firstbody.name == "star" || firstbody.name == "food" || firstbody.name == "ipad_edge_left" || firstbody.name == "ipad_edge_right" || firstbody.name == "caveman")))
            {
                if let action = dino3.action(forKey: "moving")
                {
                    action.speed = 0 //STOP CURRENT ACTION (moving)
                }
                dino3ChangeDirection()  //If they collide, then dino3 (firstbody) changes direction (random)
            }
                
                //2~ Else if caveman collides with star -> (1) star disappears + (2) new one appears + (3) SCORE +=1 + (4) Panel Updated
            if (firstbody.name == "star" && secondbody.name == "caveman") || (firstbody.name == "caveman" && secondbody.name == "star")
            {
                updateGreenGameStatusPanel(message: "Bravo, 1 Star Plus!", color: .yellow)
                starContacted()
                
                soundURL = URL(fileURLWithPath: self.eatStarSoundPATH!) //Make it a URL
                AUDIOPLAYER = try? AVAudioPlayer(contentsOf: self.soundURL)
                AUDIOPLAYER.play()
            }
                
                //3~ Else if caveman collides with food -> (1) food disappears + (2) new one appears + (3) ENERGY += 50 + (4) Panel Updated
            if (firstbody.name == "food" && secondbody.name == "caveman") || (firstbody.name == "caveman" && secondbody.name == "food")
            {
                updateGreenGameStatusPanel(message: "You got 50+ Energy!", color: .white)
                secondbody.name == "caveman" ? foodContacted(eater: secondbody) : foodContacted(eater: firstbody)
                
                soundURL = URL(fileURLWithPath: self.eatFoodSoundPATH!) //Make it a URL
                AUDIOPLAYER = try? AVAudioPlayer(contentsOf: self.soundURL)
                AUDIOPLAYER.play()
            }
                
                //4~ Else if caveman collides with rock/edge -> stop
            if ((firstbody.name == "block" || firstbody.name == "ipad_edge_right" || firstbody.name == "water" || firstbody.name == "ipad_edge_left") && secondbody.name == "caveman") || (firstbody.name == "caveman" && (secondbody.name == "block" || secondbody.name == "ipad_edge_right" || secondbody.name == "ipad_edge_left" || secondbody.name == "water"))
            {
                if(secondbody.name == "water" || firstbody.name == "water")
                {
                    soundURL = URL(fileURLWithPath: self.waterSoundPATH!) //Make it a URL
                    AUDIOPLAYER = try? AVAudioPlayer(contentsOf: self.soundURL)
                    AUDIOPLAYER.play()
                    
                    gameOver(won: false)
                    updateGreenGameStatusPanel(message: "YOU DROWNED :( Gave Over", color: .red)
                }
                else
                {
                    caveman.removeAllActions() //Stop moving
                    updateGreenGameStatusPanel(message: "You cannot move forward.", color: .darkGray)
                    if let action = caveman.action(forKey: "moving")
                    {
                        action.speed = 0 //STOP CURRENT ACTION (moving)
                    }
                }
            }
                
                //5~ Else if ENEMY (1,2,3) collides with food -> (1) food disappears + (2) new one appears win 10 sec + (4) Panel Updated
            if (firstbody.name == "food" && (secondbody.name == "dino1" || secondbody.name == "dino2" || secondbody.name == "dino3"))
                || ((firstbody.name == "dino1" || firstbody.name == "dino2" || firstbody.name == "dino3") && secondbody.name == "food")
            {
                // print ("I AM ENEMY and i ATE YOUR $$ food $$ !") //DEBUG
                soundURL = URL(fileURLWithPath: self.eatFoodSoundPATH!) //Make it a URL
                AUDIOPLAYER = try? AVAudioPlayer(contentsOf: self.soundURL)
                AUDIOPLAYER.play()
                
                updateGreenGameStatusPanel(message: "Enemy ate your food", color: .white)
                secondbody.name == "food" ? foodContacted(eater: firstbody) : foodContacted(eater: secondbody)
            }
                
                //6~ Elsif Caveman throws rocks at enemy -> they die -> reappear
            if (firstbody.name == "rock" && (secondbody.name == "dino1" || secondbody.name == "dino2" || secondbody.name == "dino3"))
                || ((firstbody.name == "dino1" || firstbody.name == "dino2" || firstbody.name == "dino3") && secondbody.name == "rock")
            {
                if(secondbody.name == "rock")
                {
                    updateGreenGameStatusPanel(message: "Enemy '\(firstbody.name!)' down!", color: .white)
                    enemyKilled(enemy: firstbody)
                    secondbody.removeFromParent() //remove rock
                }
                else if(firstbody.name == "rock")
                {
                    updateGreenGameStatusPanel(message: "Enemy '\(secondbody.name!)' down!", color: .white)
                    enemyKilled(enemy: secondbody)
                    firstbody.removeFromParent() //remove rock
                }
            }
                //7~ Elsif Enemy collides with caveman -> energy-- or die.
            if (firstbody.name == "caveman" && (secondbody.name == "dino1" || secondbody.name == "dino2" || secondbody.name == "dino3" || secondbody.name == "fire"))
                || ((firstbody.name == "dino1" || firstbody.name == "dino2" || firstbody.name == "fire" || firstbody.name == "dino3") && secondbody.name == "caveman")
            {
                //Swift: == equality (equal value), === identity (reference/same variable or not)
                
                //print ("CAVEMAN x_x + life = \(HEARTS) + ENERGY = \(ENERGY)") //DEBUG
                if (firstbody.name != "fire" && secondbody.name != "fire") //if not fire, make enemy bite sound
                {
                    soundURL = URL(fileURLWithPath: self.enemyBiteSoundPATH!) //Make it a URL
                    AUDIOPLAYER = try? AVAudioPlayer(contentsOf: self.soundURL)
                    
                    AUDIOPLAYER.play()
                }
                else
                {
                    firstbody.name == "fire" ? firstbody.removeFromParent() : secondbody.removeFromParent()
                }
                secondbody.name == "caveman" ? enemyBitCaveman(enemy: firstbody) : enemyBitCaveman(enemy: secondbody)
            }
        }
    }
    
    private func enemyBitCaveman(enemy: SKSpriteNode)
    {
        if let enemyname = enemy.name
        {
            updateGreenGameStatusPanel(message: "Ouch x_x, be careful of '\(enemyname)'", color: .red)
            //print ("I BIT CAVEMAN: \(enemyname)")
            switch(enemyname) //3. Ennemy reappers
            {
                
            //HEARTCAVEMAN
            case "dino1":
                if (ENERGY >= 60) { ENERGY -= 60; HEARTS -= 0.6} else { ENERGY = 0 }
                ENERGY_LBL.text = "\(ENERGY)"
                
                HEART_LBL.text = "\(Int(HEARTS.rounded(.up)))"
                
                dino1.removeFromParent()
                addDino1()
                
                cavemanREAPPEAR()
                
            case "dino2":
                if (ENERGY >= 80) { ENERGY -= 80; HEARTS -= 0.8 } else { ENERGY = 0 }
                ENERGY_LBL.text = "\(ENERGY)"
                
                HEART_LBL.text = "\(Int(HEARTS.rounded(.up)))"
                
                dino2.removeFromParent()
                addDino2()
                cavemanREAPPEAR()
                
            //KILL CAVEMAN (dis/reappear) -> -1 (Heart)
            case "dino3":
                print ("I am dino3 - Killed Caveman")
                if (ENERGY >= 100) { ENERGY -= 100; HEARTS -= 1 } else { ENERGY = 0 }
                ENERGY_LBL.text = "\(ENERGY)"
                
                HEART_LBL.text = "\(Int(HEARTS.rounded(.up)))"
                
                dino3.removeFromParent()
                addDino3()
                
                cavemanREAPPEAR()
            case "fire":
                print ("I am fire - Killed Caveman")
                if (ENERGY >= 100) { ENERGY -= 100; HEARTS -= 1 } else { ENERGY = 0 }
                ENERGY_LBL.text = "\(ENERGY)"
                
                HEART_LBL.text = "\(Int(HEARTS.rounded(.up)))"
                
                cavemanREAPPEAR()
            default: break
            }
            checkEnergyValueUpdateHeart()
        }
    }
    
    private func cavemanREAPPEAR() //Wait for 1 second then reappear
    {
        caveman.removeFromParent()
        run(SKAction.wait(forDuration: 1.8))
        addCaveMan()
    }
    
    //If dino3 collides with object, it changes direction (random)
    private func dino3ChangeDirection()
    {
        dino3.removeAllActions()
        let rand_direction = arc4random_uniform(4) //[0-3]: 4 possibilities
        
        //let mirrorX = SKAction.scaleX(to: -1, duration: 0)
        let move_with_direction: SKAction
        var mirrorx: SKAction
        var scale = CGFloat(0)
        
        switch (rand_direction)
        {
        case 0: //Left
            if (dino3.xScale == 1 || dino3.xScale == 0) { scale = -1 } else { scale = dino3.xScale }
            mirrorx = SKAction.scaleX(to: CGFloat(scale), duration: 0)
            
            move_with_direction = SKAction.moveBy(x: 128, y: 0, duration: 1)
        case 1: //Right
            if (dino3.xScale == -1 || dino3.xScale == 0) { scale = 1 } else { scale = dino3.xScale }
            mirrorx = SKAction.scaleX(to: scale, duration: 0)
            
            move_with_direction = SKAction.moveBy(x: -128, y: 0, duration: 1)
        case 2: //up
            if (dino3.yScale == -1 || dino3.yScale == 0) { scale = 1 } else { scale = dino3.yScale }
            mirrorx = SKAction.scaleX(to: scale, duration: 0)
            
            move_with_direction = SKAction.moveBy(x: 0, y: 128, duration: 1)
        case 3: //down
            if (dino3.yScale == 1 || dino3.yScale == 0) { scale = -1 } else { scale = dino3.yScale }
            mirrorx = SKAction.scaleX(to: scale, duration: 0)
            
            move_with_direction = SKAction.moveBy(x: 0, y: -128, duration: 1)
        default:
            if (dino3.xScale == 1 || dino3.xScale == 0) { scale = -1 } else { scale = dino3.xScale }
            mirrorx = SKAction.scaleX(to: scale, duration: 0)
            move_with_direction = SKAction.moveBy(x: 128, y: 0, duration: 1)
        }
        dino3.run(mirrorx)
        dino3.run(SKAction.repeatForever(move_with_direction), withKey: "moving")
    }
    
    private func starContacted()
    {
        var gridX = ((star.position.x - block.frame.width/2)/block.frame.width)
        var gridY = ((star.position.y - block.frame.width/2)/block.frame.width)
        
        gridX = gridX.rounded(.up)
        gridY = gridY.rounded(.up)
        
        grids.remove(at: indexOfElementInGrids(x: UInt32(gridX), y: UInt32(gridY)))
        
        star.removeFromParent() //1. Remove old star
        
        let makestar = SKAction.run {
            self.star = self.addStar() //Chose a random unoccupied grid
            self.addChild(self.star)
        }
        run(makestar) //2. Create new star
        
        SCORE += 1 //3. Update score
        STAR_LBL.text = "\(SCORE)"
    }
    
    private func foodContacted(eater: SKSpriteNode)
    {
        var gridX = ((food.position.x - block.frame.width/2)/block.frame.width)
        var gridY = ((food.position.y - block.frame.width/2)/block.frame.width)
        
        gridX = gridX.rounded(.up)
        gridY = gridY.rounded(.up)
        
        grids.remove(at: indexOfElementInGrids(x: UInt32(gridX), y: UInt32(gridY)))
        
        food.removeFromParent() //1. Remove old star

        let makefood = SKAction.run {
            self.food = self.addFood() //Chose a random unoccupied grid
            self.addChild(self.food)
        }
        
        if eater.name == "caveman"
        {
            run(makefood) //2. Create new food
            if ENERGY >= 250
            {
                ENERGY = 300 //3. Update HEARTS (life) if ENERGY reaches 300
                ENERGY_LBL.text = "\(ENERGY)"
                if(HEARTS < 3) {HEARTS += 1}      //Only add a heart if it is less than 3
                HEART_LBL.text = "\(Int(HEARTS.rounded(.up)))" //Update label
            }
            else
            {
                ENERGY += 50
                ENERGY_LBL.text = "\(ENERGY)"
                if(HEARTS < 3) {HEARTS += 0.5}
            }
            checkEnergyValueUpdateHeart()
            energyIsZero = false
        }
        else //eater is dino(1,2 or 3)
        {
            run(SKAction.sequence([SKAction.wait(forDuration: 10), makefood]) ) //2. Create new food after 10 sec
        }
    }
    
    //*******************************************************************************
    private func addDino4()
    {
        //1- Entry point: Upper left corner, facing right
        dino4 = SKSpriteNode(imageNamed: "dino4")
        dino4.size = CGSize(width: 85.375, height: 85.375)
        dino4.position = CGPoint(x: dino4.frame.width/2 /*starting point*/, y: 1024 - (3*block.frame.height)/2)
        dino4.zPosition = 730
        dino4.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 85.375, height: 85.375))
        dino4.physicsBody?.affectedByGravity = false
        dino4.physicsBody?.isDynamic = false
        
        addChild(dino4)
        
        //2- Behavior: LEFT-RIGHT, fires each [5-10] sec.
        let wait = SKAction.wait(forDuration: TimeInterval(3))
        let move_left = SKAction.move(to: CGPoint(x: 0, y: 1024 - (3*block.frame.height)/2), duration: 8)
        let move_right = SKAction.move(to: CGPoint(x: 1330, y: 1024 - (3*block.frame.height)/2), duration: 8)
        
        let sequence_dino_move = SKAction.sequence([wait, move_right, wait, move_left])
        let rightleft = SKAction.repeatForever(sequence_dino_move)
        dino4.run(rightleft)
        
        let rand_fire_time = arc4random_uniform(6) + 5 // [5-10] : (B - A  + 1) + A -> [A - B]
        let waitfire = SKAction.wait(forDuration: TimeInterval(rand_fire_time))
        
        let firefire = SKAction.run {
            self.dino4Fire()
        }
        let seq = SKAction.sequence([firefire, waitfire])
        run(SKAction.repeatForever(seq))
    }
    
    private func dino4Fire()
    {
        let fire = addFire()
        addChild(fire)
        
        //Pythagorean Thm
        var Vec_dx = CGFloat(caveman.position.x - dino4.position.x)
        var Vec_dy = CGFloat(caveman.position.y - dino4.position.y)
        let VecMagnitude = sqrt(Vec_dx*Vec_dx + Vec_dy*Vec_dy)
        
        Vec_dx = Vec_dx/VecMagnitude
        Vec_dy = Vec_dy/VecMagnitude
        
        let vector = CGVector(dx: 50.0 * Vec_dx, dy: 50.0 * Vec_dy)
        fire.physicsBody?.applyImpulse(vector)
        
        soundURL = URL(fileURLWithPath: self.fireSoundPATH!) //Make it a URL
        AUDIOPLAYER = try? AVAudioPlayer(contentsOf: self.soundURL)
        AUDIOPLAYER.play()
    }
    
    private func addFire() -> SKSpriteNode
    {
        var fire: SKSpriteNode!
        fire = SKSpriteNode(imageNamed: "fire")
        fire.size = CGSize(width: 78, height: 78)
        fire.position = CGPoint(x: dino4.position.x, y: dino4.position.y - 50)
        fire.zPosition = 709
        fire.name = "fire"
        fire.physicsBody = SKPhysicsBody(circleOfRadius: (fire.frame.width - 6)/2)
        fire.physicsBody?.categoryBitMask = PhysicsCategoryStruct.fire
        fire.physicsBody?.contactTestBitMask = PhysicsCategoryStruct.caveman
        fire.physicsBody?.collisionBitMask = PhysicsCategoryStruct.caveman
        fire.physicsBody?.affectedByGravity = false
        fire.physicsBody?.isDynamic = true
        return fire
    }
    
    private func enemyKilled(enemy: SKSpriteNode) //return bool?
    {
        if let name = enemy.name
        {
            // print ("Rock killed: '\(name)'") //DEBUG
            enemy.removeFromParent() //1. Enemy Killed
            
            let wait_before_enemy_reappears = SKAction.wait(forDuration: TimeInterval(arc4random_uniform(6) + 1)) //2. Wait [1-5] seconds
            
            let enemy_reappears = SKAction.run {
                switch(name) //3. Ennemy reappers
                {
                case "dino1": self.addDino1()
                case "dino2": self.addDino2()
                case "dino3": self.addDino3()
                default: break
                }
            }
            run(SKAction.sequence([wait_before_enemy_reappears, enemy_reappears]))
        }
    }
    
    
    //4- OBJC FUNCTIONS WITH TIMER
    @objc private func blockAppearStart()
    {
        if(maxBlockCount == 0)
        {
            timer_BlocksAppear.invalidate()
        }
        
        var block = SKSpriteNode(imageNamed: "block")
        
        let rand_grid_x = arc4random_uniform(16) + 0 //[0-15]
        let rand_grid_y = arc4random_uniform(9) + 1
        
        if(indexOfElementInGrids(x: rand_grid_x, y: rand_grid_y) == -1)
        {
            grids.append([CGFloat(rand_grid_x), CGFloat(rand_grid_y)])
            
            block = SKSpriteNode(imageNamed: "block")
            block.size = CGSize(width: 85.375, height: 85.375)
            block.position = CGPoint(x: block.frame.width/2 + CGFloat(rand_grid_x)*block.frame.width, y:block.frame.width/2 + CGFloat(rand_grid_y) * block.frame.width)
            block.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 83, height: 83))
            block.physicsBody?.affectedByGravity = false
            block.physicsBody?.isDynamic = false
            block.name = "block"
            addChild(block)
            
            block.physicsBody?.categoryBitMask = PhysicsCategoryStruct.block
            block.physicsBody?.contactTestBitMask = PhysicsCategoryStruct.caveman
            block.physicsBody?.collisionBitMask = PhysicsCategoryStruct.caveman
            maxBlockCount -= 1
        }
    }
    
    private func addStar() -> SKSpriteNode
    {
        let star = SKSpriteNode(imageNamed: "star")
        
        var rand_grid_x: UInt32
        var rand_grid_y: UInt32
        
        repeat{
            rand_grid_x = arc4random_uniform(16) + 0
            rand_grid_y  = arc4random_uniform(9) + 1
        } while (indexOfElementInGrids(x: rand_grid_y, y: rand_grid_y) > -1)
        
        grids.append([CGFloat(rand_grid_x), CGFloat(rand_grid_y)])
        
        star.size = CGSize(width: 85.375, height: 85.375)
        //INFO: y = block.frame.width/2 + CGFloat(rand_grid_y) * block.frame.width (rand_grid_y numbers of blocks = grid)
        star.position = CGPoint(x: block.frame.width/2 + CGFloat(rand_grid_x)*block.frame.width, y: block.frame.width/2 + CGFloat(rand_grid_y) * block.frame.width)
        star.zPosition = 700
        star.physicsBody = SKPhysicsBody(circleOfRadius: star.frame.width/2)
        star.physicsBody?.affectedByGravity = false
        star.physicsBody?.isDynamic = false
        star.name = "star"
        star.physicsBody?.categoryBitMask = PhysicsCategoryStruct.star
        return star
    }
    
    private func addFood() -> SKSpriteNode
    {
        let food = SKSpriteNode(imageNamed: "food")
        
        var rand_grid_x: UInt32
        var rand_grid_y: UInt32
        
        repeat{
            rand_grid_x = arc4random_uniform(16) + 0
            rand_grid_y  = arc4random_uniform(9) + 1
        } while (indexOfElementInGrids(x: rand_grid_x, y: rand_grid_y) > -1)

        grids.append([CGFloat(rand_grid_x), CGFloat(rand_grid_y)]) //호랑수월가
        
        food.size = CGSize(width: 85.375, height: 85.375)
        food.position = CGPoint(x: block.frame.width/2 + CGFloat(rand_grid_x)*block.frame.width, y: block.frame.width/2 + CGFloat(rand_grid_y) * block.frame.width)
        
        food.zPosition = 780
        food.physicsBody = SKPhysicsBody(circleOfRadius: food.frame.width/2)
        food.physicsBody?.affectedByGravity = false
        food.physicsBody?.isDynamic = false
        food.name = "food"
        food.physicsBody?.categoryBitMask = PhysicsCategoryStruct.food
        food.physicsBody?.contactTestBitMask = PhysicsCategoryStruct.dino1 | PhysicsCategoryStruct.dino2 | PhysicsCategoryStruct.dino3collider | PhysicsCategoryStruct.caveman
        return food
    }
    
    //5- Helper: seach in array
    private func indexOfElementInGrids(x: UInt32, y: UInt32) -> Int
    {
        for i in stride(from: 0, to: grids.count, by: 1)
        {
            if CGFloat(x) == grids[i][0] && CGFloat(y) == grids[i][1]
            {
                return i
            }
        }
        return -1
    }
    
    //6- Game Over
    func gameOver(won: Bool){
        
        // -> play death sound
        soundURL = URL(fileURLWithPath: self.deathSoundPATH!) //Make it a URL
        AUDIOPLAYER = try? AVAudioPlayer(contentsOf: self.soundURL)
        AUDIOPLAYER.play()
        
        // -> Display on panel
        updateGreenGameStatusPanel(message: "GAMEU OVER X_X", color: .red)
        
        // -> game over scene
        let gameOverScene = GameOverScene(size: self.size, won: false)
        let transition = SKTransition.moveIn(with: .up, duration: 1.0)
        gameOverScene.scaleMode = .aspectFill
        
        gameOverScene.score = SCORE
        self.view?.presentScene(gameOverScene, transition: transition)
    }
}

//Sound effects: (mp3) https://www.zapsplat.com/
