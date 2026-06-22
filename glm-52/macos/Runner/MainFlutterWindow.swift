import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = CGRect(
      x: 0,
      y: 0,
      width: 420,
      height: 880
    )
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    // Zentriert das Fenster auf dem Hauptbildschirm.
    self.center()

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
