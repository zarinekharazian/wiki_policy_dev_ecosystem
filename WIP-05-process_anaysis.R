library(bupaR)

d <- read.csv("data/policy_page_links-post03.csv")
colnames(d) <- gsub("_", ".", colnames(d))
d <- d[order(d$lang, d$order.within.wiki),]

d <- d[,c("lang", "QID", "timestamp")]
d$timestamp <- as.POSIXct(d$timestamp, tz="UTC")
## d$QID.numeric <- as.numeric(as.factor(d$QID))
d$instance <- seq(1, nrow(d))
d$resource <- NA
d$status <- "added"

## convert into a bupaR 
event.log <- eventlog(d,
                      case_id = "lang",
                      activity_id = "QID",
                      activity_instance_id = "instance",
                      lifecycle_id = "status",
                      timestamp = "timestamp",
                      resource_id = "resource")


write_xes(event.log, "data/event_log.xes")

filter_activity_frequency(event.log, c(100, 150)) %>% process_map()

process_map(event.log, type = frequency("absolute"))

## create the plot 
filter_activity_frequency(event.log, c(100, 150)) %>% process_matrix() %>% plot()
plot(process_matrix(event.log, type="relative"))
#plot(precedence_matrix(event.log, type="relative"))


precedence_matrix(event.log, type="relative")

trace_explorer(event.log)
jdotted_chart(event.log, x="absolute", y="start")

### bike rack

library(fuzzymineR)
library(seqClustR)


metrics <- mine_fuzzy_model(event.log, verbose=TRUE)

viz_fuzzy_model(metrics = metrics,
                node_sig_threshold = 0.1,
                edge_sig_threshold = 0.3,
                edge_sig_to_corr_ratio = 1)


cluster <- seq_edit_distance_clustering(event.log)
#seq_markov_clustering(event.log)

## seq_markov_clustering
## seq_dtw_clustering
## seq_kmeans_clustering

## Get event log by cluster as a list.

event.log.2 <- split_event_log(event.log, 
                               cluster$cluster_assignment)

event_log_2 <- split_event_log(eventlog, 
                               cluster$cluster_assignment)


## You can visualize the clusters using fuzzymineR package.


# Process Model for Cluster 1



    

policy.sequences <- tapply(d$QID, d$lang, list)

# lapply(policy.sequences, function (x) {
#    print(paste(x, sep=",", collapse="|"))
                                        #    })

devtools::install_github("PlaypowerLabs/seqClustR")
library(tidyverse)
library(bupaR)
library(seqClustR)



