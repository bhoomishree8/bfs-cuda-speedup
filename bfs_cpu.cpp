#include <iostream>
#include <vector>
#include <queue>
#include <chrono>

//BFS Function
void bfs_cpu(const std::vector<std::vector<int>>& graph, int start_node) {
    int n = graph.size();
    std::vector<int> distance(n, -1); //distance form start node
    std::queue<int> q;

    distance[start_node] = 0; // Start node has distance 0
    q.push(start_node); // Enqueue start node

    //BFS loop
    while (!q.empty()) {
        int current = q.front();
        q.pop();

        for (int neighbor : graph[current]) {
            if (distance[neighbor] == -1) { //If it hasn't been visited , update its distance and enqueue it.
                distance[neighbor] = distance[current] + 1;
                q.push(neighbor);
            }
        }
    }

    //Output the Results: it prints the distance from the start node to all nodes that were reachable.
    for (int i = 0; i < n; i++) {
        if (distance[i] != -1)
            std::cout << "Node " << i << ": Distance from start: " << distance[i] << std::endl;
    }
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

    //timing the bfs
    auto start_time = std::chrono::high_resolution_clock::now();
    bfs_cpu(graph, 0);
    auto end_time = std::chrono::high_resolution_clock::now();

    std::chrono::duration<double> elapsed = end_time - start_time;
    std::cout << "CPU BFS Time: " << elapsed.count() << " seconds\n";

    return 0;
}
