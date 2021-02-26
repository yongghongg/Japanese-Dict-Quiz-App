//
//  ViewController.swift
//  Japanese Dict Quiz App
//
//  Created by Tan Yong Hong.
//

import UIKit
import CoreData

class DictionaryViewController: UITableViewController, UISearchBarDelegate {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var wordArray = [Word](){ // initialize array of Word (core data)
        didSet {
            DispatchQueue.main.async {
                self.saveWords()
                self.removeSpinner()
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        loadWords()
    }
    
    //MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wordArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WordCell") as! WordCell
        cell.setWord(word: wordArray[indexPath.row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            context.delete(wordArray[indexPath.row])
            wordArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    //MARK: - Search Bar Methods
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        showSpinner() // show activity indicator
        
        // call WordRequest model to fetch word
        let wordRequest = WordRequest(searchedWord: searchBar.text!.lowercased())
        wordRequest.fetchWord {[weak self] result in
            switch result {
            case .failure(let error):
                print(error)
                self!.showAlert(title: "Something is wrong.", message: "Could not find word.")
            case .success(let wordResult):
                let filteredArray = self!.wordArray.filter({$0.name == wordResult[0]})
                if filteredArray.isEmpty {
                    let newWord = Word(context: self!.context)
                    newWord.name = wordResult[0]
                    newWord.engDefinitions = wordResult[1]
                    newWord.japReading = wordResult[2]
                    self!.wordArray.insert(newWord, at: 0)
                } else {
                    self!.showAlert(title: "Word existed.", message: "Word is already on the list.")
                }
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadWords()
        } else {
            // to fetch words that are already in the list
            let request : NSFetchRequest<Word> = Word.fetchRequest()
            let namePredicate = NSPredicate(format:"name CONTAINS[cd] %@", searchBar.text!.lowercased())
            let englishPredicate = NSPredicate(format:"engDefinitions CONTAINS[cd] %@", searchBar.text!.lowercased())
            let japanesePredicate = NSPredicate(format:"japReading CONTAINS[cd] %@", searchBar.text!.lowercased())
            request.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [namePredicate, englishPredicate, japanesePredicate])
            request.sortDescriptors = [NSSortDescriptor(key:"name", ascending: false)]
            loadWords(with: request)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.showsCancelButton = false
        searchBar.endEditing(true)
        loadWords()
    }
    
    //MARK: - Model Manipulation Methods
    
    func saveWords() {
        do {
          try context.save()
        } catch {
           print("Error saving context \(error)")
        }
        self.tableView.reloadData()
    }
    
    func loadWords(with request: NSFetchRequest<Word> = Word.fetchRequest()) {
        // load all items if no request is passed in
        do {
            wordArray = try context.fetch(request).reversed()
        } catch {
            print("error fetching data from context \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    //MARK:- Activity Indicator Methods
    var aView : UIView?
    func showSpinner() {
        aView = UIView(frame: self.view.bounds)
        let ai = UIActivityIndicatorView(style: .large)
        ai.center = aView!.center
        ai.startAnimating()
        aView!.addSubview(ai)
        self.view.addSubview(aView!)
    }
    
    func removeSpinner() {
        DispatchQueue.main.async {
            self.aView?.removeFromSuperview()
            self.aView = nil
        }
    }
    
    func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
            self.removeSpinner()
        }
    }
    
    //MARK:- Quiz Mode Methods
    @IBAction func startQuizButtonPressed(_ sender: UIButton) {
        if wordArray.count > 2 {
            self.performSegue(withIdentifier: "goToQuiz", sender: self)
        } else {
            showAlert(title: "No enough word on the list.", message: "Start searching for more words.")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToQuiz" {
            let destinationVC = segue.destination as! QuizViewController
            destinationVC.questionArray = wordArray.shuffled() // pass a shuffled array to QuizVC
        }
    }
}

//MARK:- Table View Cell Methods

class WordCell: UITableViewCell {
    @IBOutlet weak var wordNameLabel: UILabel!
    @IBOutlet weak var wordJapaneseLabel: UILabel!
    @IBOutlet weak var wordEnglishLabel: UILabel!
    
    func setWord(word: Word) {
        wordNameLabel.text = word.name
        if word.name == word.japReading {
            wordJapaneseLabel.text = ""
        } else {
            wordJapaneseLabel.text = word.japReading
        }
        wordEnglishLabel.text = word.engDefinitions
    }
}

