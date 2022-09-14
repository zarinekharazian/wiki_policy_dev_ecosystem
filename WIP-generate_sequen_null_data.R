library(bupaR)
library(parallel)
library(igraph)

set.seed(34)

d <- read.csv("data/policy_page_links-post03.csv")
d <- d[,c("lang", "QID", "timestamp")]
d$timestamp <- as.POSIXct(d$timestamp, tz="UTC")

## this sort is very important for the rest to work
d <- d[order(d$lang, d$timestamp),]

## d$QID.numeric <- as.numeric(as.factor(d$QID))
d$instance <- seq(1, nrow(d))
d$resource <- NA
d$status <- "added"

qid.prob <- sort(table(d$QID) / sum(table(d$QID)), decreasing=TRUE)

## get the list of sequence lengths to generate
observed.sequences <- tapply(d$QID, d$lang, list)

build.event.log <- function (policy.df) {
    ## convert into a bupaR 
    event.log <- eventlog(policy.df,
                          case_id = "lang",
                          activity_id = "QID",
                          activity_instance_id = "instance",
                          lifecycle_id = "status",
                          timestamp = "timestamp",
                          resource_id = "resource")
    
    pm.tmp <- process_matrix(event.log, type=frequency("absolute-case"))

    return(pm.tmp)
}

observed.process <- build.event.log(d)

## generate a random world and then return the difference between the
## observed matrix and ours

generate.random.world <- function (gen.seq.fun, run) {
    d.tmp <- d
    ## generate a predicted list of sequences
    d.tmp$QID <- unlist(lapply(sapply(observed.sequences, length), gen.seq.fun))

    if (! missing(run)) {
        print(paste("starting run", run))
    }
    build.event.log(d.tmp)
}

gen.seq.popularity.weighted <- function (seq.length) {
    sample(names(qid.prob), seq.length, replace=FALSE, prob=qid.prob)
}


sims.pop.weighted <- mclapply(1:1000, function (run) { generate.random.world(gen.seq.popularity.weighted, run=run) })


event.log.to.matrix <- function (pm.tmp) {

    ## drop the start and end nodes.. i think think shouldn't matter
    pm.tmp <- pm.tmp[!pm.tmp$antecedent %in% c("Start", "End"),]
    pm.tmp <- pm.tmp[!pm.tmp$consequent %in% c("Start", "End"),]

    num.items <- length(qid.prob)
              
    pm.matrix <- matrix(0, num.items, num.items)
    colnames(pm.matrix) <- names(qid.prob)
    rownames(pm.matrix) <- names(qid.prob)

    pm.matrix[as.matrix(pm.tmp[,c("antecedent", "consequent")])] <- pm.tmp$n_cases

    return(pm.matrix)
}

diff.from.random.rules <- function (model.pm, observed.pm) {

    model.graph <- graph_from_adjacency_matrix(event.log.to.matrix(model.pm),
                                               mode="directed", weighted=TRUE)
    
    observed.graph <- graph_from_adjacency_matrix(event.log.to.matrix(observed.pm),
                                                  mode="directed", weighted=TRUE)

    data.frame(degree=mean(degree(model.graph)) - mean(degree(observed.graph)),
               mean.density=mean(edge_density(model.graph)) - mean(edge_density(observed.graph)),
               mean.distance=mean_distance(model.graph) - mean_distance(observed.graph),
               clustering=transitivity(model.graph) - transitivity(observed.graph))
}


diff.from.obs <- do.call("rbind", lapply(sims.pop.weighted, diff.from.random.rules, observed=observed.process))


## recursive function to build dataset. this is the simple markov model version, i think. we just know the probability of the next step given the previous one
gen.seq.path.prob <- function (seq.length=0, cur.seq=c()) {
    if (length(cur.seq) != seq.length) {
        if (length(cur.seq) == 0) {
            qid.prev  <- "Start"
        } else {
            qid.prev <- cur.seq[length(cur.seq)]
        }
        avail.qids <- names(qid.prob)[!names(qid.prob) %in% cur.seq]
        qid.prob.new <- qid.prob[avail.qids] / sum(qid.prob[avail.qids])
        cur.seq.new <- c(cur.seq, sample(avail.qids, 1, prob=qid.prob.new))
        return( gen.seq.recusive(seq.length, cur.seq.new) )
    } else {
        return( cur.seq )
    }
}

sims.pop.path <- mclapply(1:100, function (run) { generate.random.world(gen.seq.popularity.weighted, run=run) })


diff.from.obs <- do.call("rbind", lapply(sims.pop.path, diff.from.random.rules, observed=observed.process))


## visualiz data
library(tidyr)
library(ggplot2)

##
quantile.df <- function (x) {
    quantile(x, probs=c(0.025, 0.975))
}

q.95 <- as.data.frame(do.call("cbind", lapply(diff.from.obs, quantile.df)))
q.95 <- gather(q.95)

grid.tmp <- gather(diff.from.obs)

## png("diff_from_model_to_observed.png", width=1280, height=800)
ggplot(grid.tmp) + aes(value) +
    geom_vline(data=q.95,
               aes(xintercept=value), color = "red") +
    geom_vline(data=data.frame(key=colnames(diff.from.obs), value=0),
               aes(xintercept=value), color="black") +
    geom_histogram() + 
    facet_wrap(~key, scales = 'free_x') +
    theme_bw()
## dev.off()        

