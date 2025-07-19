# BFS-CUDA-SPEEDUP

**Speedup Analysis of Breadth-First Search (BFS) using CPU and CUDA-based GPU Acceleration**

This project explores how CUDA-enabled GPU acceleration can significantly enhance the performance  of Breadth-First Search (BFS) compared to a traditional CPU implementation.

##  Overview
- **Dataset used for both CPU and GPU versions:**
  - A randomly generated **undirected graph**
  - **1,000,000 nodes**
  - **10,000,000 edges**
  - FOR CPU-Sequential traversal: One node at a time, no concurrency.
  - FOR GPU-	Graph is converted to CSR format (edges, offsets) for efficient memory access on GPU. Parallelism introduced using a CUDA kernel
  - Thread per block =256 threads
-The **aim** is to demonstrate how **parallel execution using CUDA** can significantly improve the runtime of graph traversal algorithms on large-scale datasets.

##  Necessary Tools / Packages
- **C++ Compiler (g++)**  
  For compiling and running the CPU-based BFS code.
- **CUDA Toolkit**  
  Provides the necessary compiler (`nvcc`), libraries, and runtime environment to develop and execute CUDA programs.
- **NVIDIA GPU with CUDA support**  
  Required to run and test the GPU-based BFS implementation.
- **Standard C++ Libraries**  
  Includes STL components such as `vector`, `queue`, and `chrono` for graph representation and timing.

##  How to Run the Project (on Google Colab)

This project was developed and executed on **Google Colab**, which supports **CUDA-enabled GPUs** with minimal setup.

---

### CPU Version (C++)
1. Add a new code cell in Colab and paste the CPU code (`bfs_cpu.cpp`)
2. Compile and run using:
```bash
!g++ bfs_cpu.cpp -o bfs_cpu
!./bfs_cpu
```
### GPU Version 
1. Paste the CUDA code (bfs_gpu.cu) in another code cell
2. Compile and run using:
```bash
!nvcc bfs_gpu.cu -o bfs_gpu
!./bfs_gpu
```

##  Result
The BFS algorithm was tested on a graph with **1 million nodes** and **10 million edges** on both CPU and GPU.

| Platform | Runtime (seconds) |
|----------|------------------:|
| CPU      | 24.847            |
| GPU (CUDA) | 0.048713         |

##  Conclusion

- CUDA-based BFS is ~510× faster than the CPU version.
- Parallelism enables efficient large-scale graph traversal.
- This work reinforces the importance of leveraging parallelism for time-critical applications.
