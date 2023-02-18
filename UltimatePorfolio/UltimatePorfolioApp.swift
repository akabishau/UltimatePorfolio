//
//  UltimatePorfolioApp.swift
//  UltimatePorfolio
//
//  Created by Aleksey on 2/18/23.
//

import SwiftUI

@main
struct UltimatePorfolioApp: App {
	
	@State var dataController = DataController()
	
    var body: some Scene {
        WindowGroup {
			ContentView()
				.environment(\.managedObjectContext, dataController.container.viewContext)
				.environmentObject(dataController)
        }
    }
}
