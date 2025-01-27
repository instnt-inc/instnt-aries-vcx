package com.example.myuniffiandroid

import android.os.Bundle
import android.util.Log
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import com.example.myuniffiandroid.ui.theme.MyUniffiAndroidTheme
//import org.custom.reverse.sayHello

/*
import org.hyperledger.ariesframeworkvcx.ArgonLevel
import org.hyperledger.ariesframeworkvcx.AskarKdfMethod
import org.hyperledger.ariesframeworkvcx.AskarWalletConfig
import org.hyperledger.ariesframeworkvcx.ConnectionServiceConfig
import org.hyperledger.ariesframeworkvcx.FrameworkConfig
import org.hyperledger.ariesframeworkvcx.KeyMethod
import org.hyperledger.ariesframeworkvcx.initialize

 */

class MainActivity : ComponentActivity() {


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            MyUniffiAndroidTheme {
                // A surface container using the 'background' color from the theme
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {

                    Log.d("Pankaj", "Hello I am here")
                    Greeting("Android")
                }
            }
        }
    }
}

@Composable
fun Greeting(name: String, modifier: Modifier = Modifier) {
    Text(
        text = "Hello $name!",
        modifier = modifier
    )
/*
    val host = "localhost"
    val port = 8000
    val agentEndpoint = "http://$host:$port"
    val customConfig = ConnectionServiceConfig(
        autoCompleteRequests = false,
        autoRespondToRequests = true,
        autoHandleRequests = false
    )


    val DEFAULT_ASKAR_KEY_METHOD: KeyMethod = KeyMethod.DeriveKey(
        inner = AskarKdfMethod.Argon2i(
            inner = ArgonLevel.INTERACTIVE
        )
    )

     val frameworkConfig = FrameworkConfig(
        walletConfig = AskarWalletConfig(
            dbUrl = "sqlite://:memory:",
            keyMethod = DEFAULT_ASKAR_KEY_METHOD,
            passKey = "sample_pass_key",
            profile = "aries_framework_vcx_default"
        ),
        connectionServiceConfig = customConfig, // Replace with default initialization
        agentEndpoint = agentEndpoint,
        agentLabel = "Sample Aries Framework VCX Agent" ,
     )

 */
    System.loadLibrary("uniffi_aries_framework_vcx_new")
    //val result = sayHello("Pankaj");
    val result = uniffi.aries_framework_vcx_new.reverseString("Pankaj");
    //val result = MyRustLib().initialize(frameworkConfig);
    //val result = uniffi.math.add(1u, 3u);
    //val result = .intialize()
    //val result = org.hyperledger.ariesframeworkvcx.AriesFrameworkVcxInterface()
    //val reverseStringResult = uniffi.reverse.reverseString("Hello")
    //Log.d("Debug ariesFrameworkVCX","Aries Log ${reverseStringResult}");
    //val result: AriesFrameworkVcx = NativeLib.initialize(frameworkConfig)
    Log.d("Debug ariesFrameworkVCX","Aries Log ${result}");
}

@Preview(showBackground = true)
@Composable
fun GreetingPreview() {
    MyUniffiAndroidTheme {
        Greeting("Android")
    }
}
