//
//  BrowserView.swift
//  WebViewProject
//
//  Created by Karin Prater on 16.05.23.
//

import SwiftUI

class BrowserViewController: UIViewController {
    private var hostingController: UIHostingController<BrowserView>?
    private var browserViewModel: BrowserViewModel

    init(url: URL) {
        self.browserViewModel = BrowserViewModel()
        self.browserViewModel.urlString = url.absoluteString
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let browserView = BrowserView(browserViewModel: browserViewModel)
        hostingController = UIHostingController(rootView: browserView)
        
        if let hostingController = hostingController {
            addChild(hostingController)
            hostingController.view.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(hostingController.view)
            
            NSLayoutConstraint.activate([
                hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
                hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
            
            hostingController.didMove(toParent: self)
        }
    }
}

struct BrowserView: View {
    @StateObject var browserViewModel: BrowserViewModel

    init(browserViewModel: BrowserViewModel = BrowserViewModel()) {
        _browserViewModel = StateObject(wrappedValue: browserViewModel)
    }

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    browserViewModel.goBack()
                }) {
                    Image(systemName: "chevron.backward")
                }
                .disabled(!browserViewModel.canGoBack)
                
                Button(action: {
                    browserViewModel.goForward()
                }) {
                    Image(systemName: "chevron.forward")
                }
                .disabled(!browserViewModel.canGoForward)
  
                .padding(.trailing, 5)
                
                TextField("URL", text: $browserViewModel.urlString, onCommit: {
                     browserViewModel.loadURLString()
                 })
                 .textFieldStyle(RoundedBorderTextFieldStyle())
                
                
                Button(action: {
                    browserViewModel.reload()
                }) {
                    Image(systemName: "arrow.clockwise")
                }
            }
            .padding([.top,.horizontal])
            
            if let url =  URL(string: browserViewModel.urlString) {
                BrowserWebView(url: url,
                               viewModel: browserViewModel)
                .edgesIgnoringSafeArea(.all)
            } else {
                Text("Please, enter a url.")
            }
        }
    }
}


struct BrowserView_Previews: PreviewProvider {
    static var previews: some View {
        BrowserView()
    }
}
