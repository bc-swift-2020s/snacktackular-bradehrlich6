//
//  Spots.swift
//  Snacktacular
//
//  Created by Brad Ehrlich on 4/12/20.
//  Copyright © 2020 John Gallaugher. All rights reserved.
//

import Foundation
import Firebase


class Spots {
    var spotArray = [Spot]()
    var db: Firestore!
    
    init() {
        db = Firestore.firestore()
    }
    
    func loadData(completed: @escaping () -> ()){
        db.collection("spots").addSnapshotListener {(QuerySnapshot, Error) in
            guard Error == nil else {
                return completed()
            }
            self.spotArray = []
            for document in QuerySnapshot!.documents{
                let spot = Spot(dictionary: document.data())
                spot.documentID = document.documentID
                self.spotArray.append(spot)
            }
            completed()
    }
}
}
