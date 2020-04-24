//
//  Review.swift
//  Snacktacular
//
//  Created by Brad Ehrlich on 4/22/20.
//  Copyright © 2020 John Gallaugher. All rights reserved.
//

import Foundation
import Firebase

class Review {
    var title: String
    var text: String
    var rating: Int
    var reviewUserID: String
    var date: Date
    var documentID: String
    
    
    var dictionary: [String: Any] {
        let timeIntervalDate = date.timeIntervalSince1970
        return ["title": title, "text": text, "rating": rating, "reviewUserID": reviewUserID, "date": timeIntervalDate, "documentID": documentID]
    }
    
    init(title: String, text: String, rating: Int, reviewUserID: String, date: Date, documentID: String) {
        self.title = title
        self.text = text
        self.rating = rating
        self.reviewUserID = reviewUserID
        self.date = date
        self.documentID = documentID
    }
    
    convenience init(dictionary: [String: Any]) {
        let title = dictionary["title"] as! String? ?? ""
        let text = dictionary["text"] as! String? ?? ""
        let rating = dictionary["rating"] as! Int? ?? 0
        let reviewUserID = dictionary["reviewUserID"] as! String
        // let date = dictionary["date"] as! Date? ?? Date()
        let timeIntervalDate = dictionary["date"] as! TimeInterval? ?? TimeInterval()
        let date = Date(timeIntervalSince1970: timeIntervalDate)
        self.init(title: title, text: text, rating: rating, reviewUserID: reviewUserID, date: date, documentID: "")
    }
    
    convenience init(){
        let currentUserID = Auth.auth().currentUser?.email ?? "Unknown User"
        
        self.init(title: "", text: "", rating: 0, reviewUserID: currentUserID, date: Date(), documentID: "")
    }
    
    
    func saveData(spot: Spot, completed: @escaping (Bool)-> ()) {
        let db = Firestore.firestore()
        
        let dataToSave = self.dictionary
        if self.documentID != ""{
            let ref = db.collection("spots").document(spot.documentID).collection("reviews").document(self.documentID)
            ref.setData(dataToSave){ (error) in
                if let error = error{
                    print("Error in \(error.localizedDescription)")
                    completed(false)
                } else {
                    completed(true)
                }
                
            }
        } else {
            var ref: DocumentReference? = nil
            ref = db.collection("spots").document(spot.documentID).collection("reviews").addDocument(data: dataToSave){ error in
                if let error = error{
                    print("Error in \(error.localizedDescription)")
                    completed(false)
                } else {
                    print("New Document created w/ ref \(ref?.documentID ?? "unknown")")
                    completed(true)
                }
                
            }
        }
        
        
    }
}
