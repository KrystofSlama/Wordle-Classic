//
//  FireStoreViewModel.swift
//  Wordle
//
//  Created by Kryštof Sláma on 08.04.2025.
//

import FirebaseFirestore
import Foundation

final class FireStoreViewModel: ObservableObject {
    
    
    func suggestWord(word: String, language: String) {
        let db = Firestore.firestore()
        let ref = db.collection("Feedback").document("Suggested")

        ref.updateData([
            language: FieldValue.arrayUnion([word.uppercased()])
        ]) { error in
            if let error = error {
                print("❌ Error adding suggestion: \(error.localizedDescription)")
            } else {
                print("✅ Word suggested successfully")
            }
        }
    }
    
    func reportWord(word: String, language: String) {
        let db = Firestore.firestore()
        let ref = db.collection("Feedback").document("Reported")

        ref.updateData([
            language: FieldValue.arrayUnion([word.uppercased()])
        ]) { error in
            if let error = error {
                print("❌ Error adding suggestion: \(error.localizedDescription)")
            } else {
                print("✅ Word suggested successfully")
            }
        }
    }
    
    func reportBug(word: String, language: String) {
        let db = Firestore.firestore()
        let ref = db.collection("Feedback").document("Bug")

        ref.updateData([
            language: FieldValue.arrayUnion([word.uppercased()])
        ]) { error in
            if let error = error {
                print("❌ Error adding suggestion: \(error.localizedDescription)")
            } else {
                print("✅ Word suggested successfully")
            }
        }
    }
    
    func uploadHelpData(name: String, email: String, experience: String) {
        let db = Firestore.firestore()
        
        // Prepare one user entry
        let helpEntry: [String: Any] = [
            "Name": name,
            "email": email,
            "experiance": experience  // typo kept for consistency with your database
        ]
        
        let data: [String: Any] = [
            "Help": [helpEntry]  // array with one object
        ]
        
        // Upload to "Help" collection, document "Help"
        db.collection("Feedback").document("Help").setData(data) { error in
            if let error = error {
                print("❌ Error writing document: \(error)")
            } else {
                print("✅ Document successfully written!")
            }
        }
    }
}
