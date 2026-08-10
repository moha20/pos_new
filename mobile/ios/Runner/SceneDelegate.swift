import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)
    
    // Workaround for older plugins (like flutter_barcode_scanner) that access the window via AppDelegate.
    // In UIScene-based apps, AppDelegate.window is nil, which causes force-unwrap crashes.
    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
      appDelegate.window = self.window
    }
  }
}
