import WebKit

class WebViewController: UIViewController {
    
    private let webView: WKWebView = .init()
    
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneAction))
    }
    
    @objc private func doneAction() {
        navigationController?.dismiss(animated: true)
    }
    
}
