#include <iostream>
#include <vector>
#include <cuda_runtime.h>
#include <chrono>

#define INF 1e9

__global__ void bfs_gpu(int* edges, int* offsets, int* distances, int* changed, int num_nodes) {
    int tid = blockIdx.x * blockDim.x + threadIdx.x;
    if (tid >= num_nodes || distances[tid] == INF) return;

    int start = offsets[tid];
    int end = offsets[tid + 1];

    for (int i = start; i < end; i++) {
        int neighbor = edges[i];
        if (atomicMin(&distances[neighbor], distances[tid] + 1) > distances[tid] + 1) {
            *changed = 1;
        }
    }
}

void bfs_cuda(const std::vector<std::vector<int>>& graph, int start_node) {
    int num_nodes = graph.size();

    std::vector<int> edges;
    std::vector<int> offsets(num_nodes + 1, 0);

    for (int i = 0; i < num_nodes; ++i) {
        offsets[i + 1] = offsets[i] + graph[i].size();
        edges.insert(edges.end(), graph[i].begin(), graph[i].end());
    }

    int* d_edges;
    int* d_offsets;
    int* d_distances;
    int* d_changed;

    std::vector<int> distances(num_nodes, INF);
    distances[start_node] = 0;

    cudaMalloc(&d_edges, edges.size() * sizeof(int));
    cudaMalloc(&d_offsets, offsets.size() * sizeof(int));
    cudaMalloc(&d_distances, num_nodes * sizeof(int));
    cudaMalloc(&d_changed, sizeof(int));

    cudaMemcpy(d_edges, edges.data(), edges.size() * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_offsets, offsets.data(), offsets.size() * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_distances, distances.data(), num_nodes * sizeof(int), cudaMemcpyHostToDevice);

    dim3 threadsPerBlock(256); //each block contains 256 threads
    dim3 blocksPerGrid((num_nodes + threadsPerBlock.x - 1) / threadsPerBlock.x);

    auto start_time = std::chrono::high_resolution_clock::now();

    while (true) {
        int h_changed = 0;
        cudaMemcpy(d_changed, &h_changed, sizeof(int), cudaMemcpyHostToDevice);

        bfs_gpu<<<blocksPerGrid, threadsPerBlock>>>(d_edges, d_offsets, d_distances, d_changed, num_nodes);
        cudaDeviceSynchronize();

        cudaMemcpy(&h_changed, d_changed, sizeof(int), cudaMemcpyDeviceToHost);
        if (!h_changed) break;
    }

    auto end_time = std::chrono::high_resolution_clock::now();

    cudaMemcpy(distances.data(), d_distances, num_nodes * sizeof(int), cudaMemcpyDeviceToHost);

    for (int i = 0; i < num_nodes; i++) {
        if (distances[i] != INF)
            std::cout << "Node " << i << ": Distance from start: " << distances[i] << std::endl;
    }

    std::chrono::duration<double> elapsed = end_time - start_time;
    std::cout << "GPU BFS Time: " << elapsed.count() << " seconds\n";

    cudaFree(d_edges);
    cudaFree(d_offsets);
    cudaFree(d_distances);
    cudaFree(d_changed);
}

int main() {
    int num_nodes = 1000000;
    int num_edges = 10000000;
    std::vector<std::vector<int>> graph(num_nodes);

    srand(42);
    for (int i = 0; i < num_edges; i++) {
        int u = rand() % num_nodes;
        int v = rand() % num_nodes;
        if (u != v) {
            graph[u].push_back(v);
            graph[v].push_back(u);
        }
    }

    bfs_cuda(graph, 0);
    return 0;
}
