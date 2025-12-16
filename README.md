# Petualangan Awan (Cloud Adventure) ☁️🎈

![Swift Version](https://img.shields.io/badge/Swift-5.0-orange.svg)
![Platform](https://img.shields.io/badge/Platform-iOS-lightgrey.svg)
![Framework](https://img.shields.io/badge/Framework-SpriteKit-blue.svg)

**Petualangan Awan** is an interactive educational iOS game designed to help children learn English spelling through visual Emoji cues and engaging gameplay. 

Built natively using **Swift** and **SpriteKit**, this project demonstrates game physics, particle effects, and logic-based educational mechanics.

<p align="center">
  <img src="path/to/your/screenshot.png" alt="Gameplay Screenshot" width="300"/>
</p>

*(Note: Replace `path/to/your/screenshot.png` with your actual image path)*

## 🎮 How to Play

1.  **Observe the Emoji:** A large Emoji will appear in the sky (e.g., 🍎 or 🦁).
2.  **Find the Letters:** Balloons containing various letters will float up from the bottom of the screen.
3.  **Spell the Word:** Tap the balloons in the correct order to spell the word associated with the Emoji (e.g., A → P → P → L → E).
4.  **Avoid Distractors:** Be careful! If you tap the wrong balloon, it will wiggle but won't pop.

## ✨ Key Features

* **Emoji-Based Asset System:** Utilizes the system's `AppleColorEmoji` font to generate dynamic game content, eliminating the need for heavy image assets.
* **Smart Distractor Logic:** Implements an algorithm ensuring "Wrong" balloons never contain letters present in the target word to avoid user confusion.
* **Physics-Like Animations:** Balloons feature custom `SKAction` sequences for floating and wiggling effects.
* **Endless Gameplay Loop:** The game automatically fetches new words from the database upon level completion.
* **Particle Effects:** satisfying explosion effects (`BalloonPop.sks`) when a correct balloon is tapped.

## 🛠 Tech Stack

* **Language:** Swift 5
* **Frameworks:** SpriteKit, GameplayKit
* **Tools:** Xcode 15+
* **Architecture:** MVC (Model-View-Controller)

## 🧠 Code Highlight

One of the key technical features is the **Smart Distractor Algorithm**. It ensures that the random letters generated for wrong balloons do not accidentally match any letter in the answer key.

```swift
// Logic inside createBalloon()
// Ensures the distractor (wrongBalloon) does not contain 
// any letters found in the current target word.

let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
var randomChar = letters.randomElement()!

// Keep regenerating the random character if it exists in the target word
while currentTargetWord.contains(randomChar) {
    randomChar = letters.randomElement()!
}

textToShow = String(randomChar)
balloonNode.name = "wrongBalloon"
