import XCTest
@testable import WalleyCheckout

final class ExtensionTests: XCTestCase {
    
    func testParentViewController() throws {
        // GIVEN
        let vc = UIViewController()
        let subView1 = UIView()
        let subView2 = UIView()
        
        // WHEN
        vc.view.addSubview(subView1)
        subView1.addSubview(subView2)
        
        // THEN
        XCTAssert(subView1.parentViewController == vc)
        XCTAssert(subView2.parentViewController == vc)
    }
    
    func testNotParentViewController() throws {
        // GIVEN
        let vc = UIViewController()
        let subView1 = UIView()
        let subView2 = UIView()
        
        // WHEN
        subView1.addSubview(subView2)
        
        // THEN
        XCTAssertFalse(subView1.parentViewController == vc)
        XCTAssertFalse(subView2.parentViewController == vc)
    }
    
}
