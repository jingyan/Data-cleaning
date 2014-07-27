## This script would merge test and train datasets and produce 2 datasets:
## 1. mean/std values for each feature
## 2. mean for each subject and activity
## Working directory should be set to "UCI HAR Dataset" folder with the data files.

mergeFile <- function(testFileName){
        trainFileName <- gsub("test","train",testFileName)
        mergedFileName <- gsub("test","merged",testFileName)
        train<- read.csv(trainFileName, sep="",header=FALSE)
        test<- read.csv(testFileName,sep="",header=FALSE)
        merged <- rbind(train,test)
        dir.create(dirname(mergedFileName))
        write.table(merged,file=mergedFileName,row.names = FALSE,col.names = FALSE)
}

mergeDataset <- function(){
        filesToProcess <- dir(path="test/.",pattern = "*.test\\.txt$",recursive=TRUE)
        testFiles <- paste0("test/",filesToProcess)
        lapply(testFiles,mergeFile)
}

extractMeanStd <-function(){
        subject <- read.csv("merged/subject_merged.txt",sep="",header=FALSE)
        colnames(subject) <- c("subject")
        
        activity_labels <- read.csv("activity_labels.txt",sep="",header=FALSE)
        activity_raw <- read.csv("merged/Y_merged.txt",sep="",header=FALSE)
        activity <- merge(activity_raw,activity_labels,by.x="V1",by.y="V1")
        colnames(activity) <- c("activity-code","activity")
        
        features <- read.csv("features.txt",sep="",header=FALSE)
        set <- read.csv("merged/X_merged.txt",sep="",header=FALSE)
        colnames(set) <- gsub("()","",features[,2],fixed=TRUE)

        columns <- c(grep("std()",features$V2,fixed=TRUE),grep("mean()",features$V2,fixed=TRUE))
        target <- cbind(subject,activity,set[,columns])
        write.table(target,file="dataset1.txt",row.names = FALSE,col.names = TRUE)
}

getTidySetForAverage <- function(){
        data <- read.table("dataset1.txt",header=TRUE)
        data <- data[,-2]
        mean_data <- aggregate(.~subject + activity, data=data, mean)
        write.table(mean_data,file="dataset2.txt",row.names = FALSE,col.names = TRUE)
}

## merge train and test dataset
mergeDataset()
## build dataset 1 for step4
extractMeanStd()
## build dataset 2 for step5
getTidySetForAverage()

