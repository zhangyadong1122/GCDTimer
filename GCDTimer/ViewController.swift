//
//  ViewController.swift
//  GCDTimer
//
//  Created by 22点的夜生活 on 2018/9/4.
//  Copyright © 2018年 22点的夜生活. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var task: String?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func startTimer(_ sender: Any) {
//        task = GCDTimer.execTask(task: { (totalTimer) in
//            print("定时器持续的时间: \(totalTimer)")
//        })

        task = GCDTimer.execTask(startTime: 1, interval: 2, isRepeats: true, isAsync: false) { (_ ) in
            print("1s后开始, 定时器间隔2s, 允许重复执行, 不开启子线程")
        }
    }

    @IBAction func pauseTimer(_ sender: Any) {
        GCDTimer.suspendTask(task: task)
    }

    @IBAction func cancelTimer(_ sender: Any) {
        GCDTimer.cancelTask(task: task)
    }

    @IBAction func reusemTimer(_ sender: Any) {
        GCDTimer.resumeTask(task: task)
    }
    




}

