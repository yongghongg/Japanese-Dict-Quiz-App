//
//  QuizViewController.swift
//  Japanese Dict Quiz App
//
//  Created by Tan Yong Hong.
//

import UIKit

class QuizViewController: UIViewController {

    var questionArray: [Word]?
    var question: Word?
    var randomWord: Word?
    var questionNumber = 0
    var correctAnswer = 0
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var choiceLabel1: UIButton!
    @IBOutlet weak var choiceLabel2: UIButton!
    @IBOutlet weak var progressBar: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    @IBAction func answerButtonPressed(_ sender: UIButton) {
        let userAnswer = sender.currentTitle!
        if userAnswer == question!.engDefinitions! {
            correctAnswer += 1
            sender.backgroundColor = UIColor.green
            sender.layer.borderColor = UIColor.green.cgColor
        } else {
            sender.backgroundColor = UIColor.red
            sender.layer.borderColor = UIColor.red.cgColor
        }
        if questionNumber + 1 < questionArray!.count {
            questionNumber += 1
        } else {
            let alert = UIAlertController(title: "Quiz Finished! Your score is \(correctAnswer) / \(questionArray!.count)", message: "Would you like to continue?", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Continue", style: UIAlertAction.Style.default, handler: nil))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: {_ in self.dismiss(animated: true, completion: nil)}))
            self.present(alert, animated: true, completion: nil)
            questionNumber = 0
            correctAnswer = 0
            questionArray!.shuffle()
        }
        Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(updateUI), userInfo: nil, repeats: false)
    }
    
    @IBAction func endQuizButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func updateUI() {
        
        question = questionArray![questionNumber]
        questionLabel.text = question!.name
        randomWord = questionArray!.filter({$0.name != question!.name}).randomElement()
        
        switch [1, 2].randomElement() {
        case 1:
            setupButton(button: choiceLabel1, choice: question!.engDefinitions!)
            setupButton(button: choiceLabel2, choice: randomWord!.engDefinitions!)
        case 2:
            setupButton(button: choiceLabel2, choice: question!.engDefinitions!)
            setupButton(button: choiceLabel1, choice: randomWord!.engDefinitions!)
        default:
            break
        }
        
        progressBar.progress = Float(questionNumber) / Float(questionArray!.count)
        choiceLabel1.backgroundColor = UIColor.clear
        choiceLabel2.backgroundColor = UIColor.clear
    }
    
    func setupButton(button: UIButton, choice: String) {
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.8
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1
        button.setTitleColor(UIColor.blue, for: .normal)
        button.layer.borderColor =  UIColor.blue.cgColor
        button.setTitle(choice, for: .normal)
    }
    
}
