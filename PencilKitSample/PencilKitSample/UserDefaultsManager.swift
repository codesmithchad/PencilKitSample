//
//  UserDataManager.swift
//  PencilKitSample
//
//  Created by Ajiaco on 2022/02/14.
//

import Foundation

final class UserDataManager {
    
    static var shared: UserDataManager = UserDataManager()
    
    func saveUserDefaults(_ annotation: Annotation) {
//    guard let writing = annotation.annotation else { return }
//    do {
//        let data = try NSKeyedArchiver.archivedData(withRootObject: writing, requiringSecureCoding: false)
//        UserDefaults.standard.set(data, forKey: valotilableWritingKey)
//    } catch let error {
//        print("archive error : \(error.localizedDescription)")
//    }
    }
    
    func retreiveUserDefaults() {
//    guard let data = UserDefaults.standard.object(forKey: valotilableWritingKey) as? Data else { return }
//    do {
//        if let writing = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [PDFAnnotation] {
//            addAnnotation(Annotation(title: "saved annotation", pageNo: 1, scribbleType: .note, annotation: writing))
//        }
//    } catch let error {
//        print("retreive error : \(error.localizedDescription)")
//    }
    }
}
