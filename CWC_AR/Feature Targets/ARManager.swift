//
//  ARManager.swift
//  CWC_AR
//
//  Created by Hansen Yudistira on 24/04/24.
//

import Combine

class ARManager {
    static let shared = ARManager()
    private init() { }
    
    var actionStream = PassthroughSubject<ARAction, Never>()
}
