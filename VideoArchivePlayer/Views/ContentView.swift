//
//  ContentView.swift
//  VideoArchivePlayer
//
//  Created by dev on 3/27/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 4.0) {
                Text("Add a url to the json file containing a list of video files")
                    .multilineTextAlignment(.leading)
                TextField("Url to json file", text: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Value@*/.constant("")/*@END_MENU_TOKEN@*/)
                    .padding(.all)
                    .padding(.leading)
                    .padding(.trailing)
                NavigationLink(destination: VideoArchivePlayerView()) {
                    Text("Start player")
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
