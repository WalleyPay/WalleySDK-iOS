import WebKit

class WebViewController: UIViewController {
    
    private let webView: WKWebView = .init()
    private let navigationBar: UINavigationBar = .init()
    
    private let navigationBarHeight: CGFloat = 44
    
    func loadUrl(_ url: URL) {
        let urlRequest = URLRequest(url: url)
        webView.load(urlRequest)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.leftAnchor.constraint(equalTo: view.leftAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        webView.scrollView.contentInset.top = navigationBarHeight
        
        view.addSubview(navigationBar)
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.topAnchor),
            navigationBar.leftAnchor.constraint(equalTo: view.leftAnchor),
            navigationBar.rightAnchor.constraint(equalTo: view.rightAnchor),
            navigationBar.heightAnchor.constraint(equalToConstant: navigationBarHeight)
        ])
    }
    
}
