package com.example.hdx_mobile

import android.app.Application
import android.os.Handler
import android.os.Looper
import androidx.lifecycle.Observer
import de.chembio.cubelib.CubeViewModel
import de.chembio.cubelib.DeviceInterface
import de.chembio.cubelib.command.helper.EState
import de.chembio.cubelib.command.helper.MessageData
import de.chembio.cubelib.database.tables.MeasurementData
import de.chembio.cubelib.database.tables.ResultData
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.InputStream

class CubeBridge(
    private val application: Application,
    flutterEngine: FlutterEngine,
) {
    companion object {
        const val METHOD_CHANNEL = "com.homedx.cube/analysis"
        const val EVENT_CHANNEL = "com.homedx.cube/events"
    }

    private val mainHandler = Handler(Looper.getMainLooper())
    private val viewModel = CubeViewModel(application)
    private var eventSink: EventChannel.EventSink? = null

    private val stateObserver = Observer<EState> { state ->
        eventSink?.success(
            mapOf("type" to "state", "state" to state.name)
        )
    }

    private val messageObserver = Observer<MessageData> { msg ->
        eventSink?.success(
            mapOf(
                "type" to "message",
                "msgType" to msg.msgType.name,
                "msgCode" to msg.msgCode,
                "msgData" to msg.msgData,
            )
        )
    }

    private val devicesObserver = Observer<List<DeviceInterface.DeviceInfo>> { devices ->
        eventSink?.success(
            mapOf(
                "type" to "devices",
                "devices" to devices.map { d ->
                    mapOf("name" to d.toString(), "index" to devices.indexOf(d))
                },
            )
        )
    }

    private val measurementsObserver = Observer<List<MeasurementData>> { measurements ->
        eventSink?.success(
            mapOf(
                "type" to "measurements",
                "count" to measurements.size,
            )
        )
    }

    private val resultsObserver = Observer<List<ResultData>> { results ->
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
                eventSink = events
                observeOnMainThread()
            }

            override fun onCancel(arguments: Any?) {
                removeObservers()
                eventSink = null
            }
        })

        loadBundledLicense()
    }

    private fun observeOnMainThread() {
        mainHandler.post {
            viewModel.state.observeForever(stateObserver)
            viewModel.lastMessage.observeForever(messageObserver)
            viewModel.devices.observeForever(devicesObserver)
            viewModel.measurements.observeForever(measurementsObserver)
            viewModel.measurementResults.observeForever(resultsObserver)
        }
    }

    private fun removeObservers() {
        mainHandler.post {
            viewModel.state.removeObserver(stateObserver)
            viewModel.lastMessage.removeObserver(messageObserver)
            viewModel.devices.removeObserver(devicesObserver)
            viewModel.measurements.removeObserver(measurementsObserver)
            viewModel.measurementResults.removeObserver(resultsObserver)
        }
    }

    private fun loadBundledLicense() {
        try {
            val stream: InputStream = application.assets.open("cube_license.dat")
            val valid = viewModel.setLicense(stream)
            stream.close()
            if (!valid) {
                android.util.Log.w("CubeBridge", "Bundled Cube license is invalid or expired")
            }
        } catch (e: Exception) {
            android.util.Log.e("CubeBridge", "Failed to load bundled Cube license", e)
        }
    }

    private fun handleMethod(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getVersion" -> result.success(viewModel.getVersion())
            "licenseValid" -> result.success(viewModel.licenseValid())

            "startScan" -> {
                val timeoutMs = (call.argument<Number>("timeoutMs")?.toLong()) ?: 5000L
                result.success(viewModel.startScan(timeoutMs))
            }
            "stopScan" -> {
                viewModel.stopScan()
                result.success(null)
            }

            "connectDevice" -> {
                val index = call.argument<Number>("index")?.toInt()
                    ?: return result.error("invalid_args", "index is required", null)
                val disableButton = call.argument<Boolean>("disableButton") ?: false
                val devices = viewModel.devices.value
                if (devices == null || index < 0 || index >= devices.size) {
                    return result.error("invalid_args", "Device index out of range", null)
                }
                viewModel.connectDevice(devices[index], disableButton)
                result.success(true)
            }

            "disconnectDevice" -> {
                val shutDown = call.argument<Boolean>("shutDown") ?: false
                viewModel.disconnectDevice(finishCurrentOperation = true, shutDown)
                result.success(null)
            }

            "isConnected" -> result.success(viewModel.isConnected())

            "startEvaluation" -> {
                val useTimer = call.argument<Boolean>("useTimer") ?: false
                viewModel.startEvaluation(useTimer)
                result.success(true)
            }

            "readDeviceDatabase" -> {
                viewModel.startReadDeviceDatabase()
                result.success(true)
            }

            "selectMeasurement" -> {
                val index = call.argument<Number>("index")?.toInt()
                    ?: return result.error("invalid_args", "index is required", null)
                val measurements = viewModel.measurements.value
                if (measurements == null || index < 0 || index >= measurements.size) {
                    return result.error("invalid_args", "Measurement index out of range", null)
                }
                viewModel.selectMeasurement(measurements[index])
                result.success(true)
            }

            "getMeasurements" -> {
                val measurements = viewModel.measurements.value ?: emptyList()
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
                result.success(viewModel.state.value?.name ?: "ST_DISCONNECTED")
            }

            "clearLocalDatabase" -> {
                viewModel.clearLocalDatabase()
                result.success(null)
            }

            else -> result.notImplemented()
        }
    }
}
