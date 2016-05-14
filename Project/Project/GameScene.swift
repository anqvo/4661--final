//
//  GameScene.swift
//  Project
//
//  Created by An Vo on 4/12/16.
//  Copyright (c) 2016 UNO. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {	// added SKPhysicsContactDelegate
	
	/* Game Interface */
	var background: SKNode!
	var background_speed = 260.0
	var instructions: SKSpriteNode!
	//var playButton: SKSpriteNode!
	var pauseButton: SKSpriteNode!
	var coinIcon: SKSpriteNode!
	var coinsCollected = 0
	var label_coins: SKLabelNode!
	var label_time: SKLabelNode!
	var gameOverLabel: SKLabelNode!
	var pausedLabel: SKLabelNode!
	
	/* Game Sprites */
	var player: SKSpriteNode!
	var egg1: SKSpriteNode!
	var egg2: SKSpriteNode!
	var egg3: SKSpriteNode!
	var egg4: SKSpriteNode!
	var egg5: SKSpriteNode!
	var spawnEgg = NSTimer()
	var coin1: SKSpriteNode!
	var coin2: SKSpriteNode!
	var coin3: SKSpriteNode!
	var spawnCoin = NSTimer()

	
	/* Important Game Values */
	let floor_distance: CGFloat = 72.0
	var delta = NSTimeInterval(0)
	var last_update_time = NSTimeInterval(0)
	var isRunningRight: Bool = false
	var isRunningLeft: Bool = false
	var isPaused: Bool!
	var pickedUp1: Bool!
	var pickedUp2: Bool!
	var pickedUp3: Bool!
	
	
	/* Physics Categories for Collision */
	let PBoundaryCategory: UInt32 = 1 << 0
	let PPlayerCategory: UInt32 = 1 << 1
	let PEgg1Category: UInt32 = 1 << 2
	let PEgg2Category: UInt32 = 1 << 3
	let PEgg3Category: UInt32 = 1 << 4
	let PEgg4Category: UInt32 = 1 << 5
	let PEgg5Category: UInt32 = 1 << 6
	let PCoin1Category: UInt32 = 1 << 7
	let PCoin2Category: UInt32 = 1 << 8
	let PCoin3Category: UInt32 = 1 << 9
	
	/* Game States */
	enum PGameState: Int {
		case PGameStateStarting
		case PGameStatePlaying
		case PGameStateEnded
	}
	
	
	/* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ */
	
	
	/* Initial Game State */
	var state: PGameState = .PGameStateStarting
	
	/* SKScene initialization */
	override func didMoveToView(view: SKView) {
		self.backgroundColor = UIColor.whiteColor()
		initWorld()
		initBackground()
		initHUD()
		initPlayer()
	}
	
	
	/* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ */
	
	
	/* Add Physics to the World */
	func initWorld() {
		physicsWorld.contactDelegate = self
		physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)
		physicsBody = SKPhysicsBody(edgeLoopFromRect: CGRect(x: 0.0, y: floor_distance, width: size.width, height: size.height - floor_distance))
		physicsBody?.categoryBitMask = PBoundaryCategory
		physicsBody?.contactTestBitMask = PPlayerCategory	| PEgg1Category | PEgg2Category | PEgg3Category | PEgg4Category | PEgg5Category | PCoin1Category | PCoin2Category | PCoin3Category
		physicsBody?.collisionBitMask = PPlayerCategory
	}
	
	
	/* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ */
	
	
	/* Create the Background */
	func initBackground() {
		background = SKNode()
		for i in 0...2 {
			let bg = SKSpriteNode(imageNamed: "Background")
			bg.name = "Background"
			bg.size = CGSize(width: 800, height: 500)
			bg.position = CGPoint(x: CGFloat(i) * 800.0, y: 0.0)
			bg.zPosition = 50
			bg.anchorPoint = CGPointZero
			background.addChild(bg)
		}
		addChild(background)
	}
	
	/* Move the Background as Player runs Right */
	func moveBackgroundRight() {
		let posX = -background_speed * delta
		background.position = CGPoint(x: background.position.x + CGFloat(posX), y: 0.0)
		
		background.enumerateChildNodesWithName("Background") { (node, stop) in
			let background_screen_position = self.background.convertPoint(node.position, toNode: self)
			
			if background_screen_position.x <= -node.frame.size.width {
				node.position = CGPoint(x: node.position.x + (node.frame.size.width * 3), y: node.position.y)
			}
		}
	}
	
	/* Move the Background as Player runs Left */
	func moveBackgroundLeft() {
		let posX = background_speed * delta
		background.position = CGPoint(x: background.position.x + CGFloat(posX), y: 0.0)
		
		background.enumerateChildNodesWithName("Background") { (node, stop) in
			let background_screen_position = self.background.convertPoint(node.position, toNode: self)
			
			if background_screen_position.x >= node.frame.size.width {
				node.position = CGPoint(x: node.position.x - (node.frame.size.width * 3), y: node.position.y)
			}
		}
	}
	
	
	/* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ */
	
	
	/* Create the Heads-Up Display for the Game Interface */
	func initHUD() {
		instructions = SKSpriteNode(imageNamed: "Tap")
		instructions.size = CGSize(width: 350, height: 50)
		instructions.position = CGPoint(x: CGRectGetMidX(frame), y: CGRectGetMidY(frame)-5)
		instructions.zPosition = 50
		addChild(instructions)

		/*
		playButton = SKSpriteNode(imageNamed: "Play")
		playButton.size = CGSize(width: 35, height: 35)
		playButton.position = CGPoint(x: 640, y: 385)
		playButton.zPosition = 50
		addChild(playButton)
		*/
		
		pauseButton = SKSpriteNode(imageNamed: "Pause")
		pauseButton.size = CGSize(width: 35, height: 35)
		pauseButton.position = CGPoint(x: 690, y: 385)
		pauseButton.zPosition = 50
		addChild(pauseButton)
		
		coinIcon = SKSpriteNode(imageNamed: "Coin Icon")
		coinIcon.size = CGSize(width: 15, height: 15)
		coinIcon.position = CGPoint(x: 40, y: 385)
		coinIcon.zPosition = 50
		addChild(coinIcon)
		
		label_coins = SKLabelNode(fontNamed: "Microsoft Sans Serif")
		label_coins.fontSize = 14
		label_coins.fontColor = UIColor.blackColor()
		label_coins.position = CGPoint(x: 66, y: 379)
		label_coins.zPosition = 50
		label_coins.text = "0"
		addChild(label_coins)
		
		label_time = SKLabelNode(fontNamed: "Microsoft Sans Serif")
		label_time.fontSize = 22
		label_time.position = CGPoint(x: CGRectGetMidX(self.frame), y: 30)
		label_time.zPosition = 50
		label_time.fontColor = UIColor.blackColor()
		label_time.text = "00:00:00"
		addChild(label_time)
		
		pausedLabel = SKLabelNode(fontNamed: "Microsoft Sans Serif")
		pausedLabel.fontSize = 27
		pausedLabel.fontColor = UIColor.blackColor()
		pausedLabel.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
		pausedLabel.zPosition = 50
		pausedLabel.text = "PAUSED"
		addChild(pausedLabel)
	}
	
	
	/* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ */
	
	
	/* Create the Player */
	func initPlayer() {
		player = SKSpriteNode()
		player.size = CGSize(width: 45, height: 37.5)
		player.position = CGPoint(x: CGRectGetMidX(frame), y: 90)
		player.zPosition = 50
		
		player.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 25, height: 33))
		player.physicsBody?.categoryBitMask = PPlayerCategory
		player.physicsBody?.contactTestBitMask = PBoundaryCategory | PEgg1Category | PEgg2Category | PEgg4Category | PEgg5Category | PCoin1Category | PCoin2Category | PCoin3Category
		player.physicsBody?.collisionBitMask = PBoundaryCategory
		
		player.physicsBody?.affectedByGravity = false
		player.physicsBody?.allowsRotation = false
		player.physicsBody?.restitution = 0.0
		
		playerIdleRight()	// initial starting position
		addChild(player)
	}
	
	/* Player animates running Left */
	func playerRunLeft() {
		var texture = Array<SKTexture>()
		
		for i in 1...4 {
			texture.append(SKTexture(imageNamed: "Player Run L\(i)"))
		}
		player.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(texture, timePerFrame: 0.1)))
	}
	
	/* Player animates running Right */
	func playerRunRight() {
		var texture = Array<SKTexture>()
		
		for i in 1...4 {
			texture.append(SKTexture(imageNamed: "Player Run R\(i)"))
		}
		player.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(texture, timePerFrame: 0.1)))
	}
	
	/* Player stands idle facing Left */
	func playerIdleLeft() {
		var texture = Array<SKTexture>()
		
		texture.append(SKTexture(imageNamed: "Player Idle L"))
		player.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(texture, timePerFrame: 1)))
	}
	
	/* Player stands idle facing Right */
	func playerIdleRight() {
		var texture = Array<SKTexture>()
		
		texture.append(SKTexture(imageNamed: "Player Idle R"))
		player.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(texture, timePerFrame: 1)))
	}
	
	
	/* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ */
	
	
	/* Randomly generate X coordinates (used to assist with randomizing the spawn locations of eggs for initEgg1..4() */
	func randomBetweenNumbers(firstNum: CGFloat, secondNum: CGFloat) -> CGFloat {
		return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
	}
	
	/* Create the egg1 */
	func initEgg1() {
		let xPos = randomBetweenNumbers(0, secondNum: frame.width)
		egg1 = SKSpriteNode()
		egg1.position = convertPoint(CGPointMake(CGFloat(xPos), 415), toNode: background)
		
		egg1.size = CGSize(width: 20, height: 25)
		egg1.zPosition = 50
		
		egg1.physicsBody = SKPhysicsBody(circleOfRadius: egg1.size.width/3)
		egg1.physicsBody?.categoryBitMask = PEgg1Category
		egg1.physicsBody?.contactTestBitMask = PPlayerCategory | PBoundaryCategory
		egg1.physicsBody?.collisionBitMask = PPlayerCategory
		egg1.physicsBody?.affectedByGravity = false
		egg1.physicsBody?.allowsRotation = false
		egg1.physicsBody?.restitution = 0.0
		
		animateEgg1Texture()
		background.addChild(egg1)
	}
	
	/* Egg1 default animation while dropping */
	func animateEgg1Texture() {
		let drop1 = SKAction.moveToY(78, duration: 1.6)
		let finishDrop = SKAction.removeFromParent()
		
		var egg1Texture = Array<SKTexture>()
		for i in 1...3 {
			egg1Texture.append(SKTexture(imageNamed: "Egg 1 Face\(i)"))
		}
		
		egg1.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(egg1Texture, timePerFrame: 0.14)))
		egg1.runAction(SKAction.sequence([drop1, finishDrop]))
	}
	
	/* Create the egg2 */
	func initEgg2() {
		let xPos = randomBetweenNumbers(0, secondNum: frame.width)
		egg2 = SKSpriteNode()
		egg2.position = convertPoint(CGPointMake(CGFloat(xPos), 415), toNode: background)
		
		egg2.size = CGSize(width: 20, height: 25)
		egg2.zPosition = 50
		
		egg2.physicsBody = SKPhysicsBody(circleOfRadius: egg2.size.width/3)
		egg2.physicsBody?.categoryBitMask = PEgg2Category
		egg2.physicsBody?.contactTestBitMask = PPlayerCategory | PBoundaryCategory
		egg2.physicsBody?.collisionBitMask = PPlayerCategory
		egg2.physicsBody?.affectedByGravity = false
		egg2.physicsBody?.allowsRotation = false
		egg2.physicsBody?.restitution = 0.0
		
		animateEgg2Texture()
		background.addChild(egg2)
	}
	
	/* Egg2 default animation while dropping */
	func animateEgg2Texture() {
		let drop2 = SKAction.moveToY(78, duration: 1.6)
		let finishDrop = SKAction.removeFromParent()
		
		var egg2Texture = Array<SKTexture>()
		for i in 1...3 {
			egg2Texture.append(SKTexture(imageNamed: "Egg 2 Face\(i)"))
		}
		
		egg2.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(egg2Texture, timePerFrame: 0.14)))
		egg2.runAction(SKAction.sequence([drop2, finishDrop]))
	}
	
	/* Create the egg3 */
	func initEgg3() {
		let xPos = randomBetweenNumbers(0, secondNum: frame.width)
		egg3 = SKSpriteNode()
		egg3.position = convertPoint(CGPointMake(CGFloat(xPos), 415), toNode: background)
		
		egg3.size = CGSize(width: 20, height: 25)
		egg3.zPosition = 50
		
		egg3.physicsBody = SKPhysicsBody(circleOfRadius: egg3.size.width/3)
		egg3.physicsBody?.categoryBitMask = PEgg3Category
		egg3.physicsBody?.contactTestBitMask = PPlayerCategory | PBoundaryCategory
		egg3.physicsBody?.collisionBitMask = PPlayerCategory
		egg3.physicsBody?.affectedByGravity = false
		egg3.physicsBody?.allowsRotation = false
		egg3.physicsBody?.restitution = 0.0
		
		animateEgg3Texture()
		background.addChild(egg3)
	}
	
	/* Egg3 default animation while dropping */
	func animateEgg3Texture() {
		let drop3 = SKAction.moveToY(78, duration: 1.6)
		let finishDrop = SKAction.removeFromParent()
		
		var egg3Texture = Array<SKTexture>()
		for i in 1...3 {
			egg3Texture.append(SKTexture(imageNamed: "Egg 3 Face\(i)"))
		}
		
		egg3.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(egg3Texture, timePerFrame: 0.14)))
		egg3.runAction(SKAction.sequence([drop3, finishDrop]))
	}
	
	/* Create the egg4 */
	func initEgg4() {
		let xPos = randomBetweenNumbers(0, secondNum: frame.width)
		egg4 = SKSpriteNode()
		egg4.position = convertPoint(CGPointMake(CGFloat(xPos), 415), toNode: background)
		egg4.size = CGSize(width: 20, height: 25)
		egg4.zPosition = 50
		
		egg4.physicsBody = SKPhysicsBody(circleOfRadius: egg4.size.width/3)
		egg4.physicsBody?.categoryBitMask = PEgg4Category
		egg4.physicsBody?.contactTestBitMask = PPlayerCategory | PBoundaryCategory
		egg4.physicsBody?.collisionBitMask = PPlayerCategory
		egg4.physicsBody?.affectedByGravity = false
		egg4.physicsBody?.allowsRotation = false
		egg4.physicsBody?.restitution = 0.0
		
		animateEgg4Texture()
		background.addChild(egg4)
	}
	
	/* Egg4 default animation while dropping */
	func animateEgg4Texture() {
		let drop4 = SKAction.moveToY(78, duration: 1.6)
		let finishDrop = SKAction.removeFromParent()
		
		var egg4Texture = Array<SKTexture>()
		for i in 1...3 {
			egg4Texture.append(SKTexture(imageNamed: "Egg 4 Face\(i)"))
		}
		
		egg4.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(egg4Texture, timePerFrame: 0.14)))
		egg4.runAction(SKAction.sequence([drop4, finishDrop]))
	}
	
	
	/* Create the egg5 */
	func initEgg5() {
		let xPos = randomBetweenNumbers(0, secondNum: frame.width)
		egg5 = SKSpriteNode()
		egg5.position = convertPoint(CGPointMake(CGFloat(xPos), 415), toNode: background)
		egg5.size = CGSize(width: 20, height: 25)
		egg5.zPosition = 50
		
		egg5.physicsBody = SKPhysicsBody(circleOfRadius: egg5.size.width/3)
		egg5.physicsBody?.categoryBitMask = PEgg5Category
		egg5.physicsBody?.contactTestBitMask = PPlayerCategory | PBoundaryCategory
		egg5.physicsBody?.collisionBitMask = PPlayerCategory
		egg5.physicsBody?.affectedByGravity = false
		egg5.physicsBody?.allowsRotation = false
		egg5.physicsBody?.restitution = 0.0
		
		animateEgg5Texture()
		background.addChild(egg5)
	}
	
	/* Egg5 default animation while dropping */
	func animateEgg5Texture() {
		let drop5 = SKAction.moveToY(78, duration: 1.6)
		let finishDrop = SKAction.removeFromParent()
		
		var egg5Texture = Array<SKTexture>()
		for i in 1...3 {
			egg5Texture.append(SKTexture(imageNamed: "Egg 5 Face\(i)"))
		}
		
		egg5.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(egg5Texture, timePerFrame: 0.14)))
		egg5.runAction(SKAction.sequence([drop5, finishDrop]))
		
	}
	
	/* Egg Spawner */
	func spawnEggs() {
		let wait = SKAction.waitForDuration(0.2, withRange: 0.2)	// Random wait time with total possible wait time = 0.4 seconds
		let spawn1 = SKAction.runBlock {self.initEgg1()}
		let spawn2 = SKAction.runBlock {self.initEgg2()}
		let spawn3 = SKAction.runBlock {self.initEgg3()}
		let spawn4 = SKAction.runBlock {self.initEgg4()}
		let spawn5 = SKAction.runBlock {self.initEgg5()}
		
		let sequence1 = SKAction.sequence([wait, spawn1])
		let sequence2 = SKAction.sequence([wait, spawn2])
		let sequence3 = SKAction.sequence([wait, spawn3])
		let sequence4 = SKAction.sequence([wait, spawn4])
		let sequence5 = SKAction.sequence([wait, spawn5])
		
		self.runAction(sequence1)
		self.runAction(sequence2)
		self.runAction(sequence3)
		self.runAction(sequence4)
		self.runAction(sequence5)
	}
	
	/* Repeatedly spawn Eggs from spawnEggs() over a scheduled time interval */
	func spawnTimer() {
		spawnEgg = NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector: #selector(GameScene.spawnEggs), userInfo: nil, repeats: true)
	}
	func spawnCoinTimer() {
		spawnCoin = NSTimer.scheduledTimerWithTimeInterval(0.0001, target: self, selector: #selector(GameScene.spawnCoins), userInfo: nil, repeats: false)
	}
	
	
	/* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ */
	
	
	func initCoin1() {
		let xPos = randomBetweenNumbers(0, secondNum: frame.width)
		coin1 = SKSpriteNode()
		coin1.position = convertPoint(CGPointMake(CGFloat(xPos), 76), toNode: background)
		coin1.size = CGSize(width: 18, height: 18)
		coin1.zPosition = 50
		coin1.physicsBody = SKPhysicsBody(circleOfRadius: coin1.size.width/6)
		coin1.physicsBody?.categoryBitMask = PCoin1Category
		coin1.physicsBody?.contactTestBitMask = PPlayerCategory | PBoundaryCategory
		coin1.physicsBody?.collisionBitMask = PBoundaryCategory
		coin1.physicsBody?.affectedByGravity = false
		coin1.physicsBody?.allowsRotation = false
		coin1.physicsBody?.restitution = 0.0
		animateCoin1()
		background.addChild(coin1)
	}
	
	func initCoin2() {
		let xPos = randomBetweenNumbers(0, secondNum: frame.width)
		coin2 = SKSpriteNode()
		coin2.position = convertPoint(CGPointMake(CGFloat(xPos), 76), toNode: background)
		coin2.size = CGSize(width: 18, height: 18)
		coin2.zPosition = 50
		coin2.physicsBody = SKPhysicsBody(circleOfRadius: coin2.size.width/6)
		coin2.physicsBody?.categoryBitMask = PCoin2Category
		coin2.physicsBody?.contactTestBitMask = PPlayerCategory | PBoundaryCategory
		coin2.physicsBody?.collisionBitMask = PBoundaryCategory
		coin2.physicsBody?.affectedByGravity = false
		coin2.physicsBody?.allowsRotation = false
		coin2.physicsBody?.restitution = 0.0
		animateCoin2()
		background.addChild(coin2)
	}
	
	func initCoin3() {
		let xPos = randomBetweenNumbers(0, secondNum: frame.width)
		coin3 = SKSpriteNode()
		coin3.position = convertPoint(CGPointMake(CGFloat(xPos), 76), toNode: background)
		coin3.size = CGSize(width: 18, height: 18)
		coin3.zPosition = 50
		coin3.physicsBody = SKPhysicsBody(circleOfRadius: coin3.size.width/6)
		coin3.physicsBody?.categoryBitMask = PCoin3Category
		coin3.physicsBody?.contactTestBitMask = PPlayerCategory | PBoundaryCategory
		coin3.physicsBody?.collisionBitMask = PBoundaryCategory
		coin3.physicsBody?.affectedByGravity = false
		coin3.physicsBody?.allowsRotation = false
		coin3.physicsBody?.restitution = 0.0
		animateCoin3()
		background.addChild(coin3)
	}
	
	func animateCoin1() {
		var texture = Array<SKTexture>()
		for i in 1...4 {
			texture.append(SKTexture(imageNamed: "Coin\(i)"))
		}
		coin1.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(texture, timePerFrame: 0.1)))
	}
	
	func animateCoin2() {
		var texture = Array<SKTexture>()
		for i in 1...4 {
			texture.append(SKTexture(imageNamed: "Coin\(i)"))
		}
		coin2.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(texture, timePerFrame: 0.1)))
	}
	
	func animateCoin3() {
		var texture = Array<SKTexture>()
		for i in 1...4 {
			texture.append(SKTexture(imageNamed: "Coin\(i)"))
		}
		coin3.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(texture, timePerFrame: 0.1)))
	}
	
	func spawnCoins() {
		let wait = SKAction.waitForDuration(0.7, withRange: 0.6)
		let spawn1 = SKAction.runBlock {self.initCoin1()}
		let spawn2 = SKAction.runBlock {self.initCoin2()}
		let spawn3 = SKAction.runBlock {self.initCoin3()}
		
		let sequence1 = SKAction.sequence([wait, spawn1])
		let sequence2 = SKAction.sequence([wait, spawn2])
		let sequence3 = SKAction.sequence([wait, spawn3])
		
		self.runAction(sequence1)
		self.runAction(sequence2)
		self.runAction(sequence3)
		
		pickedUp1 = false
		pickedUp2 = false
		pickedUp3 = false
	}
	
	
	/* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ */
	
	
	/* Function to detect collision between Player and Eggs */
	func didBeginContact(contact: SKPhysicsContact) {
		let collision: UInt32 = (contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask)
		
		if collision == (PPlayerCategory | PEgg1Category) {
			gameOver()
		}
		if collision == (PPlayerCategory | PEgg2Category) {
			gameOver()
		}
		if collision == (PPlayerCategory | PEgg3Category) {
			gameOver()
		}
		if collision == (PPlayerCategory | PEgg4Category) {
			gameOver()
		}
		if collision == (PPlayerCategory | PEgg5Category) {
			gameOver()
		}
		
		if collision == (PPlayerCategory | PCoin1Category) {
			pickedUp1 = true
			coin1.removeFromParent()
			coinsCollected += 1
			label_coins.text = "\(coinsCollected)"
			if pickedUp1 == true && pickedUp2 == true && pickedUp3 == true {
				spawnCoinTimer()
			}
		}
		if collision == (PPlayerCategory | PCoin2Category) {
			pickedUp2 = true
			coin2.removeFromParent()
			coinsCollected += 1
			label_coins.text = "\(coinsCollected)"
			if pickedUp1 == true && pickedUp2 == true && pickedUp3 == true {
				spawnCoinTimer()
			}
		}
		if collision == (PPlayerCategory | PCoin3Category) {
			pickedUp3 = true
			coin3.removeFromParent()
			coinsCollected += 1
			label_coins.text = "\(coinsCollected)"
			if pickedUp1 == true && pickedUp2 == true && pickedUp3 == true {
				spawnCoinTimer()
			}
		}
	}
	
	/* Function to end the Game */
	func gameOver() {
		state = .PGameStateEnded
		//playButton.hidden = true
		pauseButton.hidden = true
		background.removeAllChildren()
		background.removeFromParent()
		player.removeAllActions()
		timer.invalidate()
		
		gameOverLabel = SKLabelNode(fontNamed: "Microsoft Sans Serif")
		gameOverLabel.text = "GAME OVER"
		gameOverLabel.fontColor = UIColor.redColor()
		
		gameOverLabel.fontSize = 60
		gameOverLabel.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
		addChild(gameOverLabel)
	}
	
	
	/* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ */
	
	
	/*	One touch detection */
	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		if state == .PGameStateStarting {
			state = .PGameStatePlaying
			
			instructions.hidden = true
			isPaused = false
			//playButton.hidden = false
			pauseButton.hidden = false
			label_time.hidden = false
			coinIcon.hidden = false
			label_coins.hidden = false
			
			spawnTimer()
			spawnCoinTimer()
			timeStart()
		}
		if state == .PGameStatePlaying && isPaused == true {
			for touch in (touches) {
				let location = touch.locationInNode(self)
				
				if pauseButton.containsPoint(location) == false {
					timeStart()
					spawnTimer()
					if pickedUp1 == true && pickedUp2 == true && pickedUp3 == true {
						spawnCoinTimer()
					}
					self.scene!.view?.paused = false
					isPaused = false;
				}
			}
		}
		if state == .PGameStateEnded {
			let transition = SKTransition.fadeWithDuration(0)
			
			// Let transition = SKTransition.revealWithDirection(.Down, duration: 0.5)
			let nextScene = GameOver(size: scene!.size)
			nextScene.scaleMode = .AspectFill
			
			scene?.view?.presentScene(nextScene, transition: transition)
		}
	}
	
	/* One touch dragged detection */
	override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
		if state == .PGameStatePlaying {
			for touch in (touches) {
				let location = touch.locationInNode(self)
				
				if location.x < self.size.width/2 && isRunningLeft == false {
					playerRunLeft()
					isRunningLeft = true
					isRunningRight = false
				}
				if location.x > self.size.width/2 && isRunningRight == false {
					playerRunRight()
					isRunningLeft = false
					isRunningRight = true
				}
			}
		}
	}
	
	/* Touch no longer on screen */
	override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
		if state == .PGameStatePlaying {
			for touch in (touches) {
				let location = touch.locationInNode(self)

				if location.x < self.size.width/2 {
					playerIdleLeft()
					isRunningLeft = false
					isRunningRight = false
				}
				if location.x > self.size.width/2 {
					playerIdleRight()
					isRunningLeft = false
					isRunningRight = false
				}
	
				if pauseButton.containsPoint(location) && isPaused == false {
					background.removeAllActions()
					player.removeAllActions()
					spawnEgg.invalidate()
					spawnCoin.invalidate()
					timeStop()
					self.scene!.view?.paused = true
					isPaused = true;
				}
			}
		}
	
	}
	
	
	/* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ */
	
	
	var startTime = NSTimeInterval()
	var timer = NSTimer()
	var elapsedTime = NSTimeInterval()
	var pauseTime = NSTimeInterval()
	
	func updateTime() {
		let currentTime: NSTimeInterval = NSDate.timeIntervalSinceReferenceDate()
		elapsedTime = currentTime - startTime
		
		let minutes = UInt8(elapsedTime / 60.0)
		elapsedTime -= (NSTimeInterval(minutes) * 60)
		
		let seconds = UInt8(elapsedTime)
		elapsedTime -= NSTimeInterval(seconds)
		
		let fraction = UInt8(elapsedTime * 100)
		
		let strMinutes = String(format: "%02d", minutes)
		let strSeconds = String(format: "%02d", seconds)
		let strFraction = String(format: "%02d", fraction)
		
		label_time.text = "\(strMinutes):\(strSeconds):\(strFraction)"
	}
	
	func timeStart() {
		if !timer.valid {
			timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: #selector(GameScene.updateTime), userInfo: nil, repeats: true)
			startTime += NSDate.timeIntervalSinceReferenceDate() - pauseTime
			timer.valid
		}
	}
	
	func timeStop() {
		pauseTime = NSDate.timeIntervalSinceReferenceDate()
		timer.invalidate()
	}
	
	
	/* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ */
	
	
	override func update(currentTime: CFTimeInterval) {
		/* Called before each frame is rendered */
		delta = (last_update_time == 0.0) ? 0.0 : currentTime - last_update_time
		last_update_time = currentTime
		if state == .PGameStateStarting {
			pausedLabel.hidden = true
		}
		if state == .PGameStatePlaying && isRunningLeft == true && isRunningRight == false {	// Player is running left
			moveBackgroundLeft()
		}
		if state == .PGameStatePlaying && isRunningLeft == false && isRunningRight == true {
			moveBackgroundRight()
		}
		if state == .PGameStatePlaying && isRunningLeft == false && isRunningRight == false {
		}
		if state == .PGameStatePlaying && isPaused == true {
			pausedLabel.hidden = false
		}
	}
}