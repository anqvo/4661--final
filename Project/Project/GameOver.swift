import SpriteKit

class GameOver: SKScene {
	
	var playButton: SKSpriteNode!
	var gameOverLabel: SKLabelNode!
	var replayLabel: SKLabelNode!
	var homeLabel: SKLabelNode!
	
	override func didMoveToView(view: SKView) {
		/*	Setup your scene here */
		self.backgroundColor = UIColor.whiteColor()
		
		initAllInterface()
	}
	
	func initAllInterface() {
		gameOverLabel = SKLabelNode(fontNamed: "Microsoft Sans Serif")
		gameOverLabel.text = "GAME OVER"
		gameOverLabel.fontColor = UIColor.redColor()
		gameOverLabel.fontSize = 60
		gameOverLabel.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
		addChild(gameOverLabel)
		
		replayLabel = SKLabelNode(fontNamed: "Microsoft Sans Serif")
		replayLabel.text = "REPLAY"
		replayLabel.fontColor = UIColor.blackColor()
		replayLabel.fontSize = 15
		replayLabel.position = CGPoint(x: CGRectGetMidX(frame), y: 150)
		addChild(replayLabel)
		
		playButton = SKSpriteNode(imageNamed: "Play")
		playButton.size = CGSize(width: 35, height: 35)
		playButton.position = CGPoint(x: CGRectGetMidX(frame), y: 100)	// 175, 60
		playButton.zPosition = 50
		addChild(playButton)
	}
	
	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		/*	Called when a touch begins */
		for touch in (touches) {
			let location = touch.locationInNode(self)
			if playButton.containsPoint(location) {
				let transition = SKTransition.fadeWithDuration(1.0)
				
				// Let transition = SKTransition.revealWithDirection(.Down, duration: 0.5)
				let nextScene = GameScene(size: scene!.size)
				nextScene.scaleMode = .AspectFill
				
				scene?.view?.presentScene(nextScene, transition: transition)
			}
		}
	}
	
	override func update(currentTime: CFTimeInterval) {
		/*	Called before each frame is rendered */
	}
}