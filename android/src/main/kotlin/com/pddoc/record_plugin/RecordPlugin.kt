package com.pddoc.record_plugin

import android.Manifest
import android.content.pm.PackageManager
import android.media.AudioFormat
import android.media.MediaPlayer
import android.os.Build
import android.os.Environment
import android.os.Handler
import android.widget.Toast
import com.zlw.main.recorderlib.recorder.RecordConfig
import com.zlw.main.recorderlib.recorder.RecordHelper
import com.zlw.main.recorderlib.recorder.listener.RecordFftDataListener
import com.zlw.main.recorderlib.recorder.listener.RecordResultListener
import com.zlw.main.recorderlib.recorder.listener.RecordSoundSizeListener
import com.zlw.main.recorderlib.recorder.listener.RecordStateListener
import com.zlw.main.recorderlib.utils.FileUtils
import com.zlw.main.recorderlib.utils.Logger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.io.File
import java.text.SimpleDateFormat
import java.util.*

class RecordPlugin : MethodCallHandler {
    companion object {
        private lateinit var reg: Registrar
        private lateinit var channel: MethodChannel
        /**
         * 录音配置
         */
        private var currentConfig = RecordConfig()


        private var isStart = false
        private var isPause = false

        @JvmStatic
        fun registerWith(registrar: Registrar) {
            this.channel = MethodChannel(registrar.messenger(), "record_plugin")
            channel.setMethodCallHandler(RecordPlugin())
            reg = registrar

            val recordDir = String.format(Locale.getDefault(), "%s/Record/pddoc/",
                    Environment.getExternalStorageDirectory().absolutePath)
            //设置格式为MP3
            currentConfig.format = RecordConfig.RecordFormat.MP3
            currentConfig.sampleRate = 16000
            currentConfig.encodingConfig = AudioFormat.ENCODING_PCM_16BIT
            currentConfig.recordDir = recordDir
            initRecordEvent()
        }

        /**
         * 初始化录音监听事件
         * */
        private fun initRecordEvent() {
            RecordHelper.getInstance().setRecordStateListener(object : RecordStateListener {
                override fun onStateChange(state: RecordHelper.RecordState) {
                    when (state) {
                        RecordHelper.RecordState.PAUSE -> channel.invokeMethod("PAUSE", "PAUSE")
                        RecordHelper.RecordState.IDLE -> channel.invokeMethod("IDLE", "IDLE")
                        RecordHelper.RecordState.RECORDING -> channel.invokeMethod("RECORDING", "RECORDING")
                        RecordHelper.RecordState.STOP -> channel.invokeMethod("STOP", "STOP")
                        RecordHelper.RecordState.FINISH -> {
                            channel.invokeMethod("FINISH", "FINISH")
                        }
                        else -> {
                        }
                    }
                }

                override fun onError(error: String) {
                    channel.invokeMethod("RecordState", error)
                }
            })

            RecordHelper.getInstance().setRecordSoundSizeListener { soundSize ->
                channel.invokeMethod("RecordSoundSize", soundSize)
            }
            /**
             * 完成录音回调
             * */
            RecordHelper.getInstance().setRecordResultListener { result ->
                channel.invokeMethod("RecordResult", result.absolutePath)

                Toast.makeText(reg.context(), result.absolutePath, Toast.LENGTH_SHORT).show()
            }
            // RecordHelper.getInstance().setRecordFftDataListener(RecordFftDataListener { data -> audioView.setWaveData(data) })
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {

        val path = call.argument<String>("path")



        when (call.method) {
            "startRecord" -> {
                startRecord(result)

            }
            "pauseRecord" -> {
                pauseRecord()
                result.success("pauseRecord")
            }
            "resumeRecord" -> {
                resumeRecord()
                result.success("resumeRecord")
            }
            "stopRecord" -> {
                stopRecord()
                result.success(getFilePath())
            }

            "startPlay" -> {
                startPlay(path + "")
                result.success("startPlay")
            }

            "pausePlay" -> {
                pausePlay()
                result.success("pausePlay")
            }

            "resumePlay" -> {
                resumePlay()
                result.success("resumePlay")
            }
            else -> result.notImplemented()
        }

    }


    fun startRecord(result: Result) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (reg.activity().checkSelfPermission(Manifest.permission.RECORD_AUDIO) !== PackageManager.PERMISSION_GRANTED || reg.activity().checkSelfPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE) !== PackageManager.PERMISSION_GRANTED) {
                reg.activity().requestPermissions(arrayOf(Manifest.permission.RECORD_AUDIO, Manifest.permission.WRITE_EXTERNAL_STORAGE), 0)
                result.success("error")
                return
            }
        }

        RecordHelper.getInstance().start(getFilePath(), currentConfig)
        result.success("startRecord")
    }

    fun pauseRecord() {
        RecordHelper.getInstance().pause()
    }

    fun resumeRecord() {
        RecordHelper.getInstance().resume()
    }

    fun stopRecord() {
        RecordHelper.getInstance().stop()
    }

    fun startPlay(path: String) {
        MediaManager.playSound(path) {
            //播放完成的监听事件
            MediaManager.release()
            channel.invokeMethod("audioPlayerDidFinishPlaying", "")
        }
    }

    fun pausePlay() {
        MediaManager.pause()
    }

    fun resumePlay() {
        MediaManager.resume()
    }

    /**
     * 根据当前的时间生成相应的文件名
     * 实例 record_20160101_13_15_12
     */
    private fun getFilePath(): String? {

        val fileDir = currentConfig.recordDir
        if (!FileUtils.createOrExistsDir(fileDir)) {
            Logger.w("record", "文件夹创建失败：%s", fileDir)
            return null
        }
        val fileName = "pddoctor_record"
        //val fileName = String.format(Locale.getDefault(), "record_%s", FileUtils.getNowString(SimpleDateFormat("yyyyMMdd_HH_mm_ss", Locale.SIMPLIFIED_CHINESE)))
        return String.format(Locale.getDefault(), "%s%s%s", fileDir, fileName, currentConfig.format.extension)
    }
}
