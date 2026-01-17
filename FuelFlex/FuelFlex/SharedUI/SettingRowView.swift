//
//  SettingRowView.swift
//  FuelFlex
//
//  Created by sagar on 21/09/25.
//

import SwiftUI

struct SettingRowView: View {
    var imageName: String
    var title: String
    var tintColor: Color
      
    var body: some View {
        HStack(spacing: 16) {
             Image(systemName: imageName)
                .imageScale(.small)
                .font(.title)
                .foregroundColor(tintColor)
                
            Text(title)
                .font(.subheadline)
                .foregroundColor(.black)
        }
    }
}

#Preview {
    SettingRowView(imageName: "gear", title: "Version", tintColor: Color(.systemGray))
}
