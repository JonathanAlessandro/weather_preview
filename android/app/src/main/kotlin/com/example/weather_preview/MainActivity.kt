package com.example.weather_preview

import android.Manifest
import android.content.pm.PackageManager
import android.location.Geocoder
import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Locale

class MainActivity : FlutterActivity() {
    private val handler = Handler(Looper.getMainLooper())
    private val permissionRequest = 401
    private var pending: MethodChannel.Result? = null
    private var listener: LocationListener? = null
    private var timeout: Runnable? = null
    private val manager get() = getSystemService(LOCATION_SERVICE) as LocationManager

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "weather_preview/location")
            .setMethodCallHandler { call, result ->
                if (call.method != "current") {
                    result.notImplemented()
                } else if (pending != null) {
                    result.error("busy", "Consulta já em andamento", null)
                } else {
                    pending = result
                    if (hasPermission()) locate()
                    else requestPermissions(arrayOf(Manifest.permission.ACCESS_FINE_LOCATION,
                        Manifest.permission.ACCESS_COARSE_LOCATION), permissionRequest)
                }
            }
    }

    private fun hasPermission() = checkSelfPermission(Manifest.permission.ACCESS_COARSE_LOCATION) ==
        PackageManager.PERMISSION_GRANTED

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>,
        grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == permissionRequest && pending != null) {
            if (hasPermission()) locate() else fail("permission_denied")
        }
    }

    @Suppress("DEPRECATION")
    private fun locate() {
        val request = pending ?: return
        val precise = checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION) ==
            PackageManager.PERMISSION_GRANTED
        val providers = manager.getProviders(true).filter {
            it == LocationManager.NETWORK_PROVIDER || it == "fused" ||
                (precise && it == LocationManager.GPS_PROVIDER)
        }
        if (providers.isEmpty()) {
            fail("disabled")
            return
        }
        val updates = object : LocationListener {
            override fun onLocationChanged(location: Location) {
                if (pending !== request || listener == null) return
                stopUpdates()
                val fallback = "Localização atual (%.2f, %.2f)".format(Locale.US,
                    location.latitude, location.longitude)
                fun respond(label: String) {
                    if (pending !== request) return
                    pending = null
                    timeout?.let { handler.removeCallbacks(it) }
                    timeout = null
                    request.success(mapOf("latitude" to location.latitude,
                        "longitude" to location.longitude, "label" to label))
                }
                // O nome da cidade não bloqueia a consulta se o Geocoder estiver offline.
                timeout = Runnable { respond(fallback) }
                handler.postDelayed(timeout!!, 3000)
                Thread {
                    val label = try {
                        val address = Geocoder(this@MainActivity, Locale.getDefault())
                            .getFromLocation(location.latitude, location.longitude, 1)?.firstOrNull()
                        val city = address?.locality ?: address?.subAdminArea
                        val region = address?.adminArea
                        if (city.isNullOrBlank()) fallback
                        else listOfNotNull(city, region).distinct().joinToString(", ")
                    } catch (_: Exception) { fallback }
                    handler.post { respond(label) }
                }.start()
            }
            override fun onProviderDisabled(provider: String) {}
            override fun onProviderEnabled(provider: String) {}
            override fun onStatusChanged(provider: String?, status: Int, extras: Bundle?) {}
        }
        listener = updates
        timeout = Runnable { if (pending === request) fail("timeout") }
        handler.postDelayed(timeout!!, 20000)
        var registered = false
        for (provider in providers) {
            try {
                manager.requestLocationUpdates(provider, 0L, 0f, updates, Looper.getMainLooper())
                registered = true
            } catch (_: SecurityException) {
                // A permissão aproximada pode limitar os provedores disponíveis.
            } catch (_: IllegalArgumentException) {
                // Um provedor pode ter sido desligado durante a consulta.
            }
        }
        if (!registered) fail("unavailable")
    }

    private fun stopUpdates() {
        listener?.let { updates ->
            try { manager.removeUpdates(updates) } catch (_: SecurityException) {}
        }
        listener = null
        timeout?.let { handler.removeCallbacks(it) }
        timeout = null
    }

    private fun fail(code: String) {
        val result = pending
        pending = null
        stopUpdates()
        result?.error(code, "Localização indisponível", null)
    }

    override fun onStop() {
        if (listener != null) fail("cancelled")
        super.onStop()
    }

    override fun onDestroy() {
        fail("cancelled")
        super.onDestroy()
    }
}
