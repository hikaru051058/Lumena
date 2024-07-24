//
//  LoadingWebView.swift
//  WebViewProject
//
//  Created by Karin Prater on 15.05.23.
//

import SwiftUI

class LoadingWebViewController: UIViewController {
    private var hostingController: UIHostingController<LoadingWebView>?

    var url: URL
    
    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let browserView = LoadingWebView(url: url)
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

struct LoadingWebView: View {
    @State private var isLoading = true
    @State private var error: Error? = nil
    let url: URL?
    
    var body: some View {
        ZStack {
            if let error = error {
                Text(error.localizedDescription)
                    .foregroundColor(.pink)
            } else if let url = url {
                PlatformIndependentWebView(url: url,
                                           isLoading: $isLoading,
                                           error: $error)
                if isLoading {
                    ProgressView()
                        .scaleEffect(2)
                }
            } else {
                Text("Sorry, we could not load this url.")
            }
 
        }
    }
}

struct LoadingWebView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingWebView(url: URL(string: "https://www.swiftyplace.com"))
    }
}
