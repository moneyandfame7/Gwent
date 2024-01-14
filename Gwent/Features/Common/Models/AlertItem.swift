//
//  AlertItem.swift
//  Gwent
//
//  Created by Davyd Darusenkov on 09.01.2024.
//

import Foundation


struct AlertItem {
    var title = ""
    
    var description = ""
    
    var cancelButton: Button
    
    var commonButton: Button?
    
    var confirmButton: Button
    
    typealias Button = (title: String, action: () -> Void)
}
