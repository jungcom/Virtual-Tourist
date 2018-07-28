//
//  GCDBlackBox.swift
//  Virtual Tourist
//
//  Created by Anthony Lee on 7/28/18.
//  Copyright © 2018 anthony. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
