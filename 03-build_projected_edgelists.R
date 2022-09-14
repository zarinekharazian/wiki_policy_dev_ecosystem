## Network Objects

library(reshape2)
library(igraph)

# Two-mode Networks
edge <- read.csv("data/edge_list.csv")
e <- edge[c(1,2)]

# I am building adjacency matrices here so that I can read the weights more easily
tb <- as.data.frame(table(e))
bi.adj0 <- dcast(tb, QID ~ lang,, value.var = "Freq")
bi.adj0[is.na(bi.adj0)] <- 0
bi.adj0[,order(colnames(bi.adj0))]
bi.adj <- bi.adj0[,-1]
rownames(bi.adj) <- bi.adj0[,1]

## Projection, p2p
p2p.adj=as.matrix(bi.adj) %*% t(bi.adj)
diag(p2p.adj) <- 0  ## removing self-loops

p2p.g <- graph_from_adjacency_matrix(p2p.adj, mode="undirected", weighted=T)
## E(p2p.g)$weight

## plot.sociomatrix(p2p.adj,cex.lab = 0.2,font.lab=2)
edge.p2p  <- get.data.frame(p2p.g)
colnames(edge.p2p) = c("Source","Target","Weight")
write.csv(edge.p2p,"data/edge_list-policy2policy.csv")

## Projection, w2w
w2w.adj= t(bi.adj) %*% as.matrix(bi.adj)
diag(w2w.adj) <- 0  ## removing self-loops

w2w.g <- graph_from_adjacency_matrix(w2w.adj, mode="undirected", weighted=T)
E(w2w.g)$weight

# edge.w2w = get.edgelist(w2w.g), attr="weight")
edge.w2w  <- get.data.frame(w2w.g)
colnames(edge.w2w) = c("Source","Target","Weight")
write.csv(edge.w2w,"data/edge_list-wiki2wiki.csv",row.names=FALSE)

