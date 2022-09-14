## BIKE RACK BELOW

## diffs.from.random <- unlist(mclapply(1:500, diff.from.random.rules))
##diffs.from.random <- unlist(diffs.from.random)

## library(ggplot2)
## qplot(unlist(diffs.from.random))

 d.tmp <- d
## generate a predicted list of sequences
d.tmp$QID <- unlist(lapply(sapply(observed.sequences, length), generate.sequence))

## convert into a bupaR 
event.log <- eventlog(d.tmp,
                      case_id = "lang",
                      activity_id = "QID",
                      activity_instance_id = "instance",
                      lifecycle_id = "status",
                      timestamp = "timestamp",
                      resource_id = "resource")

model.process <- process_matrix(event.log)

## this contains the QIDs plus start and end
model.steps <- unique(c(as.character(model.process$antecedent),
                        as.character(model.process$consequent)))

num.items <- length(model.steps)
              
model.matrix <- matrix(0, num.items, num.items)
colnames(model.matrix) <- model.steps
rownames(model.matrix) <- model.steps
model.matrix[as.matrix(model.process[,c("antecedent", "consequent")])] <- model.process$n
model.matrix <- model.matrix[!rownames(model.matrix) %in% c("Start", "End"),
                             !colnames(model.matrix) %in% c("Start", "End")]

model.matrix.norm <- model.matrix / rep(apply(model.matrix, 1, sum), ncol(model.matrix))

## drop the final line
model.matrix.norm[model.matrix.norm == 0] <- NA
## model.matrix.loglik <- log(model.matrix.norm)


## give me the likelihood of X_i given a pervious X
loglik.of.ab <- function (q, qid, qid.prev) {
    log(q * model.matrix.norm[qid, qid.prev] + (1 - q) * qid.prob[qid])
}

loglik.of.pathidx <- function (path.num, q) {
    qid <- rownames(model.matrix.norm)[existing.paths[path.num,"row"]]
    qid.prev <- colnames(model.matrix.norm)[existing.paths[path.num,"col"]]
    #print(paste("qid:", qid))
    #print(paste("qid.prev", qid.prev))
    #print(loglik.of.ab(q, qid, qid.prev))
    loglik.of.ab(q, qid, qid.prev)
}


existing.paths <- which(model.matrix != 0, arr.ind=TRUE)

#optimize.me <- function (x) {
#    sum(sapply(1:nrow(existing.paths), loglik.of.pathidx, q=1))
#}

sum(sapply(1:nrow(existing.paths), loglik.of.pathidx, q=0)) * -2 - sum(sapply(1:nrow(existing.paths), loglik.of.pathidx, q=0.5)) * -2



## convert edgelist to agency matrix
## 1. ensure that columns sum to 1
## 2. log the probalities in every cell matrix and them sum them up

## 3. log the observed probalities in every cell matrix and them sum them up

