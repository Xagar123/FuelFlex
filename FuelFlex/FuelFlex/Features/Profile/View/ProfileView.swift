//
//  ProfileView.swift
//  FuelFlex
//
//  Created by sagar on 07/09/25.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        List {
            Section {
                HStack {
                    Text("S")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 80, height: 80)
                        .background(Color(.systemGray))
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading) {
                        Text("Sagar")
                            .font(.headline)
                            .padding(.top,4)
                        Text("sagar@gmail.com")
                            .font(.footnote)
                            .accentColor(.secondary)
                    }
                    .padding(.leading)
                }
            }
            
            Section("General") {
                
            }
            
            Section("Account"){
                
            }
        }
    }
}

#Preview {
    ProfileView()
}
