# GooglyPuff
 - GCD tutorial by Raywenderlich. 
    - https://www.raywenderlich.com/28540615-grand-central-dispatch-tutorial-for-swift-5-part-1-2
 - GooglyPuff overlays googly eyes on detected faces using Core Image’s face detection API.

## Concurrency
 - In iOS, a process or application consists of one or more threads. 
 - The operating system scheduler manages the threads independently of each other. 
 - Each thread can execute concurrently, but it’s up to the system to decide if, when and how it happens.
    
    ![Feed Loading Feature](Images/Concurrency_vs_Parallelism.png)
    
 - Single-core devices achieve concurrency through a method called time-slicing. They run one thread, perform a context switch, then run another thread.
 - Multi-core devices, on the other hand, execute multiple threads at the same time via parallelism.
 
 - GCD is built on top of threads. Under the hood, it manages a shared thread pool. With GCD, you add blocks of code or work items to dispatch queues and GCD decides which thread to execute them on.
 
 - It’s important to note that parallelism requires concurrency, but concurrency doesn’t guarantee parallelism.
 
 
 ## Queues
  - GCD operates on dispatch queues through a class aptly named `DispatchQueue`
  - You submit units of work to this queue, and GCD executes them in a FIFO order (first in, first out), guaranteeing that the first task submitted is the first one started.
  - Dispatch queues are thread-safe
  
  - Queues can be either serial or concurrent. 
  - Serial queues guarantee that only one task runs at any given time. 
  - GCD controls the execution timing.
  
  ![Feed Loading Feature](Images/Serial-Queue-Swift.png)
  
  - Concurrent queues allow multiple tasks to run at the same time. 
  - The queue guarantees tasks start in the order you add them. 
  - Tasks can finish in any order, and you have no knowledge of the time it will take for the next task to start, nor the number of tasks running at any given time.
  
  ![Feed Loading Feature](Images/Concurrent-Queue-Swift.png)
  
  
## Queue Types
 1. Main queue: Runs on the main thread and is a serial queue.
 2. Global queues: Concurrent queues shared by the whole system. Four such queues exist, each with different priorities: high, default, low and background. The background priority queue has the lowest priority and is throttled in any I/O activity to minimize negative system impact.
 3. Custom queues: Queues you create that can be serial or concurrent. Requests in these queues end up in one of the global queues.
 
 - When sending tasks to the global concurrent queues, you don’t specify the priority directly. Instead, you specify a quality of service (QoS) class property. 
 - The QoS classes are:
 1. User-interactive: This represents tasks that must complete immediately to provide a nice user experience. Use it for UI updates, event handling and small workloads that require low latency. The total amount of work done in this class during the execution of your app should be small. This should run on the main thread.
 2. User-initiated: The user initiates these asynchronous tasks from the UI. Use them when the user is waiting for immediate results and for tasks required to continue user interaction. They execute in the high-priority global queue.
 3. Utility: This represents long-running tasks, typically with a user-visible progress indicator. Use it for computations, I/O, networking, continuous data feeds and similar tasks. This class is designed to be energy efficient. This gets mapped into the low-priority global queue.
 4. Background: This represents tasks the user isn’t directly aware of. Use it for prefetching, maintenance and other tasks that don’t require user interaction and aren’t time-sensitive. This gets mapped into the background priority global queue.
 
 
## Scheduling Synchronous vs. Asynchronous Functions
 - With GCD, you can dispatch a task either synchronously or asynchronously.

 - A synchronous function returns control to the caller after the task completes. You can schedule a unit of work synchronously by calling `DispatchQueue.sync(execute:)`.
 - An asynchronous function returns immediately, ordering the task to start but not waiting for it to complete. Thus, an asynchronous function doesn’t block the current thread of execution from proceeding to the next function. You can schedule a unit of work asynchronously by calling `DispatchQueue.async(execute:)`.

## Managing Tasks
 - Each task you submit to a DispatchQueue is a DispatchWorkItem. 
 - You can configure the behavior of a DispatchWorkItem, such as its QoS class or whether to spawn a new detached thread.
 
 
