//
//  NetworkManager.swift
//  Rentacar
//
//  Created by Mikk Pavelson on 11/04/2019.
//  Copyright © 2019 Mikk Pavelson. All rights reserved.
//

import UIKit

class NetworkManager {
    class func startVeriffSession(firstName: String, lastName: String, completion: @escaping ((VeriffSession?, Error?) -> ())) {
        let url = URL(string: veriffAPIURL + "/sessions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        let dateString = formatter.string(from: Date())
        
        let json: [String: Any] = ["verification":
            ["person": ["firstName": firstName, "lastName": lastName],
             "features": ["selfid"],
             "timestamp": dateString]
        ]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        request.httpBody = jsonData
        request.setValue(veriffAPIKey, forHTTPHeaderField: "X-AUTH-CLIENT")
        request.setValue("application/json", forHTTPHeaderField: "CONTENT-TYPE")
        
        let jsonDataString = String(data: jsonData!, encoding: .utf8)! + veriffAPISecret
        let signedString = jsonDataString.sha256()
        print("field - X-SIGNATURE : \(signedString)")
        request.setValue(signedString, forHTTPHeaderField: "X-SIGNATURE")
        
        
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            
            print(String(describing: response))
            print(String(describing: error))
            
            if let error = error {
                completion(nil, error)
            } else if let data = data {
                print(String(data: data, encoding: .utf8)!)
                
                var session: VeriffSession?
                let decoder = JSONDecoder()
                do {
                    session = try decoder.decode(VeriffSession.self, from: data)
                } catch {
                    print("JSON decode error: \(error)")
                }
                
                if let session = session {
                    DispatchQueue.main.async() {
                        completion(session, nil)
                    }
                }
            }
        }
        
        task.resume()
    }
    
    class func downloadImageAt(url: URL, completion: @escaping ((_ image: UIImage?, _ error: Error?) -> ())) {
        let session = URLSession(configuration: .default)
        
        let downloadImageTask = session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(nil, error)
                print("Error downloading cat picture: \(error)")
            } else {
                if let _ = response as? HTTPURLResponse {
                    if let imageData = data {
                        let image = UIImage(data: imageData)
                        completion(image, nil)
                    }
                }
            }
        }
        
        downloadImageTask.resume()
    }
}
