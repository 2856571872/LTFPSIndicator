# LTFPSIndicator
FPS指示器是基于CADisplayLink实现的。
### CADisplayLink简介
CADisplayLink是CoreAnimation提供的另一个类似于NSTimer的类，它总是在屏幕完成一次更新之前启动，它的接口设计的和NSTimer很类似，所以它实际上就是一个内置实现的替代，但是和timeInterval以秒为单位不同，CADisplayLink有一个整型的frameInterval属性，指定了间隔多少帧之后才执行。默认值是1，意味着每次屏幕更新之前都会执行一次。但是如果动画的代码执行起来超过了六十分之一秒，你可以指定frameInterval为2，就是说动画每隔一帧执行一次（一秒钟30帧）或者3，也就是一秒钟20次，等等。CADisplayLink相比较于NSTimer，帧率足够连续，如果用在动画上会看起来更加平滑，但即使CADisplayLink也不能保证每一帧都按计划执行，一些失去控制的离散的任务或者事件（例如资源紧张的后台程序）可能会导致动画偶尔地丢帧。当使用NSTimer的时候，一旦有机会计时器就会开启，但是CADisplayLink却不一样：如果它丢失了帧，就会直接忽略它们，然后在下一次更新的时候接着运行。

### 使用方法
开启监听
```
#ifdef DEBUG
    [[LTFPSIndicatorMonitor sharedInstance] startMonitoring];
#endif
```

### 核心代码
#### 初始化
```
@property (nonatomic, strong) CADisplayLink *displayLink;    

- (void)setupDisplayLink
{
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkAction:)];
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

```

#### 触发方法
```
- (void)displayLinkAction:(CADisplayLink *)displayLink
{
    if (self.screenUpdatesBeginTime == 0.0f) {
        self.screenUpdatesBeginTime = displayLink.timestamp;
    } else {
        self.screenUpdatesCount += 1;
        
        CFTimeInterval screenUpdatesTime = self.displayLink.timestamp - self.screenUpdatesBeginTime;
        
        if (screenUpdatesTime >= 1.0) {
            CFTimeInterval updatesOverSecond = screenUpdatesTime - 1.0f;
            int framesOverSecond = updatesOverSecond / self.averageScreenUpdatesTime;
            
            self.screenUpdatesCount -= framesOverSecond;
            if (self.screenUpdatesCount < 0) {
                self.screenUpdatesCount = 0;
            }
            
            //此处做些更新操作
        }
    }
}
```

### [Demo地址](https://github.com/2856571872/LTFPSIndicator)
PS：如果有点帮助的话，希望不要吝啬你的小星星哦，谢谢 -0-

如果有谁知道获取APP占用内存的方法（非task_basic_info_data_t），希望留下宝贵的评论，谢谢0.0

简书地址：http://www.jianshu.com/p/a8e96c2bae8e  以后会不定期更新内容，点一波关注，大家一起探讨一起进步yeah！
