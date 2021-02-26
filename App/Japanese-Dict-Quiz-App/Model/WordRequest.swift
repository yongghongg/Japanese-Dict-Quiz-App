//
//  Word Request.swift
//  Japanese Dict Quiz App
//
//  Created by Tan Yong Hong.
//

import Foundation
import UIKit

enum WordRequestError: Error {
    case noDataAvailable
    case cannotProcessData
}

struct WordRequest {
    
    let url: URL
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    init(searchedWord: String) {
        var components = URLComponents(string: "https://jisho.org/api/v1/search/words?")!
        components.queryItems = [URLQueryItem(name: "keyword", value: searchedWord)]
        self.url = components.url!
    }
    
    func fetchWord (completion: @escaping(Result<[String], WordRequestError>) -> Void ) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print(error.localizedDescription)
            }
            guard let jsonData = data else {
                completion(.failure(.noDataAvailable))
                return
            }
            do {
                let decoder = JSONDecoder()
                let wordResponse = try decoder.decode(WordData.self, from: jsonData)
                if wordResponse.data.isEmpty {
                    completion(.failure(.noDataAvailable))
                    return
                }
                let wordResult = [wordResponse.data[0].slug,
                                  wordResponse.data[0].senses[0].english_definitions.joined(separator: ", "),
                                  wordResponse.data[0].japanese[0].reading!]
                completion(.success(wordResult))
            } catch {
                completion(.failure(.cannotProcessData))
                print(error)
            }
        }
        task.resume()
    }

}
