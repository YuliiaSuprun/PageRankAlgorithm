# PageRankAlgorithm
This repository contains two algorithms implemented in SQL.
Both algorithms use the dataset of physics papers (look at nodes.sql and edges.sql) that cite each other. I treat papers as nodes in a directed graph. If paper p1 cites paper p2, then the graph contains an edge (p1, p2). 
1) cc.sql contains the code that computes the connected components in the given dataset of papers. It prints the connected components that have more than 4 and less than 11 ellements in them.
2) pagerank.sql implements the famous Page Rank Algorithm and prints 10 most "popular" papers (i.e., papers with highest page rank).
