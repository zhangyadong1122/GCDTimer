//
//  GCDTimer.swift
//  gcdtime
//
//  Created by 22点的夜生活 on 2018/8/20.
//  Copyright © 2018年 22点的夜生活. All rights reserved.
//

import UIKit

enum GCDTimerState {
    case normal, suspend, running, cancel
}

class GCDTimer: NSObject {

    static var timers = [String: DispatchSourceTimer]() // 定时器
    static var timersState = [String: GCDTimerState]()  // 定时器状态
    static let semphore = DispatchSemaphore(value: 1)   // 锁
    static var durations = [String: TimeInterval]()     // 持续时间
    static var fireTimes = [String: TimeInterval]()     // resume的时间点

    /**
     * startTime: 开始时间, 默认立即开始
     * interval: 间隔时间, 默认1s
     * isRepeats: 是否重复执行, 默认true
     * isAsync: 是否异步, 默认false
     * task: 执行任务
     */
    class func execTask(startTime: TimeInterval = 0, interval: TimeInterval = 1, isRepeats: Bool = true, isAsync: Bool = false, task: @escaping ((_ duration: Int) -> Void)) -> String? {

        if (interval <= 0 && isRepeats) || startTime < 0 {
            return nil
        }

        let queue = isAsync ? DispatchQueue(label: "GCDTimer") : DispatchQueue.main
        let timer = DispatchSource.makeTimerSource(flags: [], queue: queue)
        timer.schedule(deadline: .now() + startTime, repeating: 1.0, leeway: .milliseconds(0))

        semphore.wait()
        let name = "\(GCDTimer.timers.count)"
        timers[name] = timer
        timersState[name] = GCDTimerState.running
        durations[name] = 0
        fireTimes[name] = Date().timeIntervalSince1970
        semphore.signal()

        timer.setEventHandler {
            var lastTotalTime = durations[name] ?? 0
            let fireTime = fireTimes[name] ?? 0
            lastTotalTime = lastTotalTime + Date().timeIntervalSince1970 - fireTime
            task(lround(lastTotalTime))
            if !isRepeats {
                self.cancelTask(task: name)
            }
        }
        timer.activate()
        return name
    }
    // MARK: - 取消
    class func cancelTask(task: String?) {
        guard let _task = task else {
            return
        }
        semphore.wait()
        if timersState[_task] == .suspend {
            resumeTask(task: _task)
        }
        getTimer(task: _task)?.cancel()

        if let state = timersState.removeValue(forKey: _task) {
            print("The value \(state) was removed.")
        }

        if let timer = timers.removeValue(forKey: _task) {
            print("The value \(timer) was removed.")
        }

        if let fireTime = fireTimes.removeValue(forKey: _task) {
            print("The value \(fireTime) was removed.")
        }

        if let duration = durations.removeValue(forKey: _task) {
            print("The value \(duration) was removed.")
        }

        semphore.signal()
    }

    // MARK: - 暂停
    class func suspendTask(task: String?) {
        guard let _task = task else {
            return
        }

        if timersState.keys.contains(_task) {
            timersState[_task] = .suspend
            getTimer(task: _task)?.suspend()

            var lastTotalTime = durations[_task] ?? 0
            let fireTime = fireTimes[_task] ?? 0
            lastTotalTime = lastTotalTime + Date().timeIntervalSince1970 - fireTime
            durations[_task] = lastTotalTime
        }
    }

    class func resumeTask(task: String?) {
        guard let _task = task else {
            return
        }

        if timersState.keys.contains(_task) && timersState[_task] != .running {
            fireTimes[_task] = Date().timeIntervalSince1970
            getTimer(task: task)?.resume()
            timersState[_task] = .running
        }
    }

    fileprivate class func getTimer(task: String?) -> DispatchSourceTimer? {
        guard let taskS = task else {
            return nil
        }
        if taskS.count == 0 {
            return nil
        }
        guard let timer = GCDTimer.timers[taskS] else {
            return nil
        }
        return timer
    }
}
