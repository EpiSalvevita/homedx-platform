package com.example.hdx_mobile

import android.app.Application
import android.util.Log
import android.os.Handler
import android.os.Looper
import androidx.lifecycle.Observer
import de.chembio.cubelib.CubeViewModel
import de.chembio.cubelib.DeviceInterface
import de.chembio.cubelib.command.helper.EState
import de.chembio.cubelib.command.helper.MessageData
import de.chembio.cubelib.command.helper.MessageData.EMessageType
import de.chembio.cubelib.database.tables.MeasurementData
import de.chembio.cubelib.database.tables.ResultData
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import android.net.Uri
import java.io.File
import java.io.FileInputStream
import java.io.InputStream

/** Unified tag for logcat: `adb logcat -s HDX_CUBE:D` */
private fun cubeTrace(msg: String) {
    Log.i("HDX_CUBE", msg)
}

class CubeBridge(
    private val application: Application,
    flutterEngine: FlutterEngine,
) {
    companion object {
        const val METHOD_CHANNEL = "com.homedx.cube/analysis"
        const val EVENT_CHANNEL = "com.homedx.cube/events"
        /** Default asset path: place your test config blob here (see README / docs). */
        private const val DEFAULT_CUBE_CONFIG_ASSET = "cube_test_config.bin"
        /**
         * Seconds of inactivity after which the SDK closes the BLE link.
         * Mirrors the vendor sample's preference default (300 s) — without
         * this the SDK keeps the connection open until the process is
         * killed, which drains battery and leaves the device unavailable
         * to other apps.
         */
        private const val AUTO_DISCONNECT_SECONDS = 300L
    }

    private val mainHandler = Handler(Looper.getMainLooper())
    private val viewModel = CubeViewModel(application)
    private var eventSink: EventChannel.EventSink? = null
    /** Prevents duplicate `observeForever` if EventChannel reconnects quickly. */
    private var liveDataObserversAttached = false

    private val stateObserver = Observer<EState> { state ->
        emitState(state)
    }

    private val messageObserver = Observer<MessageData> { msg ->
        emitMessage(msg)
    }

    private val devicesObserver = Observer<List<DeviceInterface.DeviceInfo>> { devices ->
        cubeTrace("LiveData devices count=${devices.size} ${devices.mapIndexed { i, d -> "#$i:${d.name}[${d.commType}]" }}")
        Log.i("CubeBridge", "devices count=${devices.size} names=${devices.joinToString { it.name }}")
        eventSink?.success(
            mapOf(
                "type" to "devices",
                "devices" to devices.mapIndexed { idx, d ->
                    mapOf(
                        "name" to d.name,
                        "commType" to d.commType.name,
                        "index" to idx,
                    )
                },
            )
        )
    }

    private val measurementsObserver = Observer<List<MeasurementData>> { measurements ->
        cubeTrace("LiveData measurements count=${measurements.size} uids=${measurements.map { it.uid }}")
        Log.i("CubeBridge", "measurements count=${measurements.size}")
        eventSink?.success(
            mapOf(
                "type" to "measurements",
                "count" to measurements.size,
            )
        )
    }

    private val resultsObserver = Observer<List<ResultData>> { results ->
        cubeTrace(
            "LiveData measurementResults count=${results.size} " +
                results.joinToString { "${it.name}=${it.resultValueFormatted}" }
        )
        Log.i(
            "CubeBridge",
            "results count=${results.size} summary=${results.joinToString { "${it.name}=${it.resultValueFormatted}${it.unit}/${it.resultClass}" }}",
        )
        eventSink?.success(
            mapOf(
                "type" to "results",
                "results" to results.map { r ->
                    mapOf(
                        "name" to r.name,
                        "value" to r.resultValueFormatted,
                        "unit" to r.unit,
                        "class" to r.resultClass,
                        "validity" to r.validity,
                    )
                },
            )
        )
    }

    init {
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            METHOD_CHANNEL,
        ).setMethodCallHandler { call, result -> handleMethod(call, result) }

        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            EVENT_CHANNEL,
        ).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                cubeTrace("EventChannel onListen (Flutter subscribed)")
                Log.i("CubeBridge", "EventChannel onListen (Flutter subscribed to cube/events)")
                eventSink = events
                observeOnMainThread()
            }

            override fun onCancel(arguments: Any?) {
                cubeTrace("EventChannel onCancel (Flutter unsubscribed) — native observers removed")
                Log.i("CubeBridge", "EventChannel onCancel (Flutter unsubscribed)")
                removeObservers()
                eventSink = null
            }
        })

        cubeTrace("CubeBridge init: loading license + autoDisconnect=${AUTO_DISCONNECT_SECONDS}s")
        loadBundledLicense()
        viewModel.setAutoDisconnectTime(AUTO_DISCONNECT_SECONDS)
    }

    /**
     * Tear-down hook for the owning Activity / engine. Removes any active
     * `observeForever` subscriptions, drops the `EventSink`, and asks the
     * SDK to release the BLE connection so it doesn't leak past the
     * Flutter engine's lifetime.
     */
    fun dispose() {
        cubeTrace("dispose() — tear down bridge and optional disconnect")
        removeObservers()
        eventSink = null
        try {
            if (viewModel.isConnected()) {
                viewModel.disconnectDevice(/* finishCurrentOperation = */ true, /* shutDown = */ false)
            }
        } catch (e: Exception) {
            Log.w("CubeBridge", "dispose: disconnectDevice failed", e)
        }
    }

    private fun observeOnMainThread() {
        fun doAttach() {
            if (liveDataObserversAttached) return
            cubeTrace("observeForever: state, lastMessage, devices, measurements, measurementResults")
            Log.i("CubeBridge", "Attaching LiveData observers to EventChannel sink")
            viewModel.state.observeForever(stateObserver)
            viewModel.lastMessage.observeForever(messageObserver)
            viewModel.devices.observeForever(devicesObserver)
            viewModel.measurements.observeForever(measurementsObserver)
            viewModel.measurementResults.observeForever(resultsObserver)
            liveDataObserversAttached = true
        }
        // Avoid a one-frame gap where BLE/SDK events fire before `observeForever`
        // runs (was: always `mainHandler.post { ... }`).
        if (Looper.myLooper() == Looper.getMainLooper()) {
            doAttach()
        } else {
            mainHandler.post { doAttach() }
        }
    }

    private fun removeObservers() {
        fun doDetach() {
            if (!liveDataObserversAttached) return
            viewModel.state.removeObserver(stateObserver)
            viewModel.lastMessage.removeObserver(messageObserver)
            viewModel.devices.removeObserver(devicesObserver)
            viewModel.measurements.removeObserver(measurementsObserver)
            viewModel.measurementResults.removeObserver(resultsObserver)
            liveDataObserversAttached = false
        }
        if (Looper.myLooper() == Looper.getMainLooper()) {
            doDetach()
        } else {
            mainHandler.post { doDetach() }
        }
    }

    private fun emitState(state: EState) {
        cubeTrace("emit state → ${state.name}")
        Log.i("CubeBridge", "state -> ${state.name}")
        eventSink?.success(
            mapOf("type" to "state", "state" to state.name),
        )
    }

    private fun emitMessage(msg: MessageData) {
        cubeTrace(
            "emit message type=${msg.msgType.name} code=0x${msg.msgCode.toString(16)} (${msg.msgCode}) data=${msg.msgData} " +
                "info=${runCatching { msg.getInfoMessage().name }.getOrNull()}"
        )
        Log.i(
            "CubeBridge",
            "message msgType=${msg.msgType.name} msgCode=0x${msg.msgCode.toString(16)} (${msg.msgCode}) msgData=${msg.msgData} info=${runCatching { msg.getInfoMessage().name }.getOrNull()}",
        )
        val payload = mutableMapOf<String, Any>(
            "type" to "message",
            "msgType" to msg.msgType.name,
            "msgCode" to msg.msgCode,
            "msgData" to msg.msgData,
        )
        runCatching {
            when (msg.msgType) {
                EMessageType.MT_INFO, EMessageType.MT_PROGRESS -> {
                    val n = msg.getInfoMessage().name
                    if (n.isNotEmpty() && n != "IM_NO_INFO_MESSAGE") {
                        payload["infoMessage"] = n
                    }
                }
                else -> {}
            }
        }.onFailure { e -> Log.w("CubeBridge", "infoMessage attach failed", e) }
        eventSink?.success(payload)
    }

    private fun loadBundledLicense() {
        try {
            val stream: InputStream = application.assets.open("cube_license.dat")
            val valid = viewModel.setLicense(stream)
            stream.close()
            if (!valid) {
                cubeTrace("WARNING: bundled cube_license.dat rejected by SDK (invalid or expired)")
                android.util.Log.w("CubeBridge", "Bundled Cube license is invalid or expired")
            } else {
                cubeTrace("cube_license.dat loaded OK")
            }
        } catch (e: Exception) {
            cubeTrace("ERROR loading cube_license.dat: ${e.message}")
            android.util.Log.e("CubeBridge", "Failed to load bundled Cube license", e)
        }
    }

    private fun handleMethod(call: MethodCall, result: MethodChannel.Result) {
        cubeTrace("MethodCall ← ${call.method} args=${call.arguments}")
        when (call.method) {
            "getVersion" -> {
                val v = viewModel.getVersion()
                cubeTrace("getVersion → $v")
                result.success(v)
            }
            "licenseValid" -> {
                val lv = viewModel.licenseValid()
                cubeTrace("licenseValid → $lv")
                result.success(lv)
            }

            "startScan" -> {
                val timeoutMs = (call.argument<Number>("timeoutMs")?.toLong()) ?: 5000L
                val ok = viewModel.startScan(timeoutMs)
                cubeTrace("startScan timeoutMs=$timeoutMs → $ok")
                result.success(ok)
            }
            "stopScan" -> {
                cubeTrace("stopScan")
                viewModel.stopScan()
                result.success(null)
            }

            "connectDevice" -> {
                val index = call.argument<Number>("index")?.toInt()
                if (index == null) {
                    cubeTrace("connectDevice ERROR: missing index")
                    return result.error("invalid_args", "index is required", null)
                }
                val disableButton = call.argument<Boolean>("disableButton") ?: false
                val devices = viewModel.devices.value
                if (devices == null || index < 0 || index >= devices.size) {
                    cubeTrace("connectDevice ERROR: index=$index devices=${devices?.size}")
                    return result.error("invalid_args", "Device index out of range", null)
                }
                val d = devices[index]
                cubeTrace("connectDevice index=$index name=${d.name} comm=${d.commType} disableButton=$disableButton")
                viewModel.connectDevice(d, disableButton)
                result.success(true)
            }

            "disconnectDevice" -> {
                val shutDown = call.argument<Boolean>("shutDown") ?: false
                cubeTrace("disconnectDevice shutDown=$shutDown")
                viewModel.disconnectDevice(finishCurrentOperation = true, shutDown)
                result.success(null)
            }

            "isConnected" -> {
                val c = viewModel.isConnected()
                cubeTrace("isConnected → $c")
                result.success(c)
            }

            "startEvaluation" -> {
                val useTimer = call.argument<Boolean>("useTimer") ?: false
                val configUriStr = call.argument<String>("configUri")?.trim()?.takeIf { it.isNotEmpty() }
                val configAbsolutePathStr =
                    call.argument<String>("configAbsolutePath")?.trim()?.takeIf { it.isNotEmpty() }
                val explicitAssetName = call.argument<String>("configAssetName")?.trim()?.takeIf { it.isNotEmpty() }
                val requireAsset = call.argument<Boolean>("requireBundledConfig") ?: false

                /**
                 * Resolution matches the vendor sample: `OpenDocument`/`contentResolver`
                 * or assets, else `null` stream for RFID-loaded cassette calibration.
                 * Priority: content/file Uri → filesystem path → APK asset → RFID.
                 */
                var stream: InputStream? = null
                var sourceLabel = "RFID"

                when {
                    !configUriStr.isNullOrEmpty() -> {
                        try {
                            val uri = Uri.parse(configUriStr)
                            val s = application.contentResolver.openInputStream(uri)
                            if (s == null) {
                                cubeTrace("startEvaluation ERROR open_failed uri=$configUriStr")
                                result.error(
                                    "open_failed",
                                    "Cube config Uri could not be opened: $configUriStr",
                                    null,
                                )
                                return
                            }
                            stream = s
                            sourceLabel = "uri:${uri.scheme}"
                        } catch (e: Exception) {
                            cubeTrace("startEvaluation ERROR uri: ${e.message}")
                            Log.e("CubeBridge", "open Cube config Uri failed", e)
                            result.error(
                                "open_failed",
                                e.message ?: e.toString(),
                                null,
                            )
                            return
                        }
                    }
                    !configAbsolutePathStr.isNullOrEmpty() -> {
                        try {
                            val f = File(configAbsolutePathStr)
                            if (!f.isFile || !f.canRead()) {
                                cubeTrace("startEvaluation ERROR unreadable path=$configAbsolutePathStr")
                                result.error(
                                    "open_failed",
                                    "Cube config path missing or unreadable: $configAbsolutePathStr",
                                    null,
                                )
                                return
                            }
                            cubeTrace("startEvaluation path file=${f.name} sizeBytes=${f.length()}")
                            stream = FileInputStream(f)
                            sourceLabel = "path:${f.name}"
                        } catch (e: Exception) {
                            cubeTrace("startEvaluation ERROR path: ${e.message}")
                            Log.e("CubeBridge", "open Cube config path failed", e)
                            result.error(
                                "open_failed",
                                e.message ?: e.toString(),
                                null,
                            )
                            return
                        }
                    }
                    explicitAssetName != null || requireAsset -> {
                        val assetName = explicitAssetName ?: DEFAULT_CUBE_CONFIG_ASSET
                        try {
                            // Compressed APK assets cannot use openFd(); open() works for Cube config blobs.
                            runCatching {
                                val afd = application.assets.openFd(assetName)
                                cubeTrace(
                                    "startEvaluation asset openFd name=$assetName declaredLength=${afd.length} startOffset=${afd.startOffset}",
                                )
                                afd.close()
                            }.onFailure { fdErr ->
                                cubeTrace(
                                    "startEvaluation asset openFd skipped (likely compressed): ${fdErr.message}",
                                )
                            }
                            stream = application.assets.open(assetName)
                            sourceLabel = "asset:$assetName"
                        } catch (e: Exception) {
                            cubeTrace("startEvaluation ERROR missing asset $assetName: ${e.message}")
                            Log.w("CubeBridge", "Failed to open Cube config asset '$assetName'", e)
                            result.error(
                                "missing_asset",
                                "Cube config asset not found: $assetName",
                                null,
                            )
                            return
                        }
                    }
                    else -> {
                        // RFID/on-cassette config (vendor default when no InputStream).
                    }
                }

                cubeTrace("startEvaluation useTimer=$useTimer configSource=$sourceLabel stream=${stream != null}")
                Log.i(
                    "CubeBridge",
                    "startEvaluation: viewModel.startEvaluation(useTimer=$useTimer, source=$sourceLabel)",
                )
                viewModel.startEvaluation(useTimer, stream)
                cubeTrace("startEvaluation returned to bridge (async Cube SDK work continues)")
                Log.i(
                    "CubeBridge",
                    "startEvaluation returned (Cube SDK continues asynchronously)",
                )
                result.success(true)
            }

            "readDeviceDatabase" -> {
                cubeTrace("readDeviceDatabase → startReadDeviceDatabase()")
                viewModel.startReadDeviceDatabase()
                result.success(true)
            }

            "selectMeasurement" -> {
                val index = call.argument<Number>("index")?.toInt()
                if (index == null) {
                    cubeTrace("selectMeasurement ERROR: missing index")
                    return result.error("invalid_args", "index is required", null)
                }
                val measurements = viewModel.measurements.value
                if (measurements == null || index < 0 || index >= measurements.size) {
                    cubeTrace("selectMeasurement ERROR: index=$index size=${measurements?.size}")
                    return result.error("invalid_args", "Measurement index out of range", null)
                }
                val m = measurements[index]
                cubeTrace("selectMeasurement index=$index uid=${m.uid} cfg=${m.cfgName}")
                viewModel.selectMeasurement(m)
                result.success(true)
            }

            "getMeasurements" -> {
                val measurements = viewModel.measurements.value ?: emptyList()
                cubeTrace("getMeasurements → ${measurements.size} row(s)")
                result.success(measurements.mapIndexed { idx, m ->
                    mapOf(
                        "index" to idx,
                        "uid" to m.uid,
                        "deviceSerial" to m.deviceSerialNumber,
                        "dateTime" to m.deviceDateTime.toString(),
                        "temperature" to m.temperature,
                        "cfgName" to m.cfgName,
                        "cfgLotNr" to m.cfgLotNr,
                    )
                })
            }

            "getResults" -> {
                val results = viewModel.measurementResults.value ?: emptyList()
                cubeTrace("getResults → ${results.size} row(s)")
                result.success(results.map { r ->
                    mapOf(
                        "name" to r.name,
                        "value" to r.resultValueFormatted,
                        "unit" to r.unit,
                        "class" to r.resultClass,
                        "validity" to r.validity,
                    )
                })
            }

            "getState" -> {
                val s = viewModel.state.value?.name ?: "ST_DISCONNECTED"
                cubeTrace("getState → $s")
                result.success(s)
            }

            "clearLocalDatabase" -> {
                cubeTrace("clearLocalDatabase")
                viewModel.clearLocalDatabase()
                result.success(null)
            }

            else -> {
                cubeTrace("notImplemented method=${call.method}")
                result.notImplemented()
            }
        }
    }
}
