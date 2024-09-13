//
//  View+Extension.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 13/9/24.
//

import SwiftUI

extension View {
    func applyTaskRowStyle() -> some View {
        self.modifier(TaskRowModifier())
    }
}
