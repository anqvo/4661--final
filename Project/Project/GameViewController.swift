//
//  GameViewController.swift
//  Project
//
//  Created by An Vo on 4/12/16.
//  Copyright (c) 2016 UNO. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
	
	
	@IBOutlet var skView: SKView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		skView.multipleTouchEnabled = false
		
		//skView.showsFPS = true
		//skView.showsNodeCount = true
		//skView.showsPhysics = true
		
		if skView.scene == nil {
			let scene = GameScene(size: skView.bounds.size)
			skView.presentScene(scene)
		}
	}
	
	override func shouldAutorotate() -> Bool {
		return true
	}
	
	override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
		/*
		if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
			return .AllButUpsideDown
		} else {
			return .All
		}
		*/
		return .AllButUpsideDown
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Release any cached data, images, etc that aren't in use.
	}
	
	override func prefersStatusBarHidden() -> Bool {
		return true
	}
}
