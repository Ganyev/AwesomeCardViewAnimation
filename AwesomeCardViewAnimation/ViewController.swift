//
//  ViewController.swift
//  AwesomeCardViewAnimation
//
//  Created by Baha Ganyev on 31.10.2018.
//  Copyright © 2018 Baha Ganyev. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

   enum CardState {
      case expanded, collapsed
   }
   
   var cardViewController: CardViewController!
   var visualEffectView: UIVisualEffectView!
   
   let cardHeight: CGFloat = 600
   let cardHandleAreaHeight: CGFloat = 40
   
   var cardVisible = false
   var nextState: CardState {
      return cardVisible ? .collapsed : .expanded
   }
   
   var runningAnimations = [UIViewPropertyAnimator]()
   var animationProgressWhenInterrupted: CGFloat = 0
   
   
   override func viewDidLoad() {
      super.viewDidLoad()
      setupCard()
   }

   func setupCard() {
      visualEffectView = UIVisualEffectView()
      visualEffectView.frame = self.view.frame
      self.view.addSubview(visualEffectView)
      
      cardViewController = CardViewController(nibName: "CardViewController", bundle: nil)
      self.addChildViewController(cardViewController)
      self.view.addSubview(cardViewController.view)
      
      cardViewController.view.frame = CGRect(x: 0, y: self.view.frame.height - cardHandleAreaHeight, width: self.view.bounds.width, height: cardHeight)
      
      cardViewController.view.clipsToBounds = true
      
      let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleCardPan(recognizer:)))
      let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleCardPan(recognizer:)))
      
      cardViewController.handleArea.addGestureRecognizer(tapGestureRecognizer)
      cardViewController.handleArea.addGestureRecognizer(panGestureRecognizer)
   }
   
   @objc
   func handleCardTap(recognizer: UITapGestureRecognizer) {
      
   }
   
   @objc
   func handleCardPan(recognizer: UIPanGestureRecognizer) {
      switch recognizer.state {
      case .began:
         startInteractiveTransition(state: nextState, duration: 0.9)
      case .changed:
         let transition = recognizer.translation(in: self.cardViewController.handleArea)
         var fractionComplete = transition.y / cardHeight
         fractionComplete = cardVisible ? fractionComplete : -fractionComplete
         updateInteractiveTransition(fractionCompleted: fractionComplete)
      case .ended:
         continueInteractionTransition()
      default:
         break
      }
   }
   
   func animateTransitionIfNeeded(state: CardState, duration: TimeInterval) {
      if runningAnimations.isEmpty {
         let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
            switch state {
            case .expanded:
               self.cardViewController.view.frame.origin.y = self.view.frame.height - self.cardHeight
            case .collapsed:
               self.cardViewController.view.frame.origin.y = self.view.frame.height - self.cardHandleAreaHeight
            }
         }
         
         frameAnimator.addCompletion { _ in
            self.cardVisible = !self.cardVisible
            self.runningAnimations.removeAll()
         }
         
         frameAnimator.startAnimation()
         runningAnimations.append(frameAnimator)
         
         
      }
   }
   
   func startInteractiveTransition(state: CardState, duration: TimeInterval) {
      if runningAnimations.isEmpty {
         animateTransitionIfNeeded(state: state, duration: duration)
      }
      for animator in runningAnimations {
         animator.pauseAnimation()
         animationProgressWhenInterrupted = animator.fractionComplete
      }
   }
   
   func updateInteractiveTransition(fractionCompleted: CGFloat) {
      for animator in runningAnimations {
         animator.fractionComplete = fractionCompleted + animationProgressWhenInterrupted
      }
   }
   
   func continueInteractionTransition() {
      for animator in runningAnimations {
         animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
      }
   }
}

