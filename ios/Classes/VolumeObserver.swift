//
//  VolumeObserver.swift
//  volume_controller
//
//  Created by Kurenai on 30/01/2021.
//

import Foundation
import AVFoundation
import MediaPlayer
import Flutter
import UIKit


public class VolumeObserver {
    let volumeView = MPVolumeView()
    
    public func getVolume() -> Float? {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(true)
            return audioSession.outputVolume
        } catch {
            return nil
        }
    }
    
    public func setVolume(volume:Float, showSystemUI: Bool) -> Void {
        if let view = volumeView.subviews.first as? UISlider {
            view.setValue(volume, animated: false)
        }
    }
}

public class VolumeListener: NSObject, FlutterStreamHandler {
    private let audioSession = AVAudioSession.sharedInstance()
    private let notification = NotificationCenter.default
    private var eventSink: FlutterEventSink?
    private var isObserving: Bool = false
    private let volumeKey = "outputVolume"


    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        registerVolumeObserver()
        eventSink?(audioSession.outputVolume)
        
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        removeVolumeObserver()
        
        return nil
    }
    
    private func registerVolumeObserver() {
        audioSessionObserver()
        notification.addObserver(
            self,
            selector: #selector(audioSessionObserver),
            name: UIApplication.didBecomeActiveNotification,
            object: nil)
    }
    
    @objc func audioSessionObserver(){
        do {
            try audioSession.setCategory(AVAudioSession.Category.ambient)
            try audioSession.setActive(true)
            if !isObserving {
                audioSession.addObserver(self,
                                         forKeyPath: volumeKey,
                                         options: .new,
                                         context: nil)
                isObserving = true
            }
        } catch {
            print("error")
        }
    }
    
    private func removeVolumeObserver() {
        audioSession.removeObserver(self,
                                    forKeyPath: volumeKey)
        notification.removeObserver(self,
                                    name: UIApplication.didBecomeActiveNotification,
                                    object: nil)
        isObserving = false
    }

    
    override public func observeValue(forKeyPath keyPath: String?,
                                      of object: Any?,
                                      change: [NSKeyValueChangeKey: Any]?,
                                      context: UnsafeMutableRawPointer?) {
        if keyPath == "outputVolume" {
            eventSink?(audioSession.outputVolume)
        }
    }
}
