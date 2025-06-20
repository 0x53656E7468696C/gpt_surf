package FOSS.timepass.gptsurf

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
  private val CHANNEL = "com.gptWrapped/processText"


override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
  super.configureFlutterEngine(flutterEngine)
  MethodChannel(
    flutterEngine.dartExecutor.binaryMessenger,
    CHANNEL
  ).setMethodCallHandler { call, result ->
    if (call.method == "getProcessedText") {
      val action = intent?.action
      val text = if (action == Intent.ACTION_PROCESS_TEXT) {
        intent.getCharSequenceExtra(Intent.EXTRA_PROCESS_TEXT)?.toString() ?: ""
      } else {
        ""  // not launched via PROCESS_TEXT
      }
      result.success(text)
    } else {
      result.notImplemented()
    }
  }
}


  override fun onNewIntent(intent: Intent) {
    super.onNewIntent(intent)
    setIntent(intent)
  }
}
