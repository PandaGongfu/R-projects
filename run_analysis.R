# This script cleans and summarizes the activity data collected from samsung Galaxy

features <- read.table("features.txt")
features$labels <- as.character(features$V2)

activity <- read.table("activity_labels.txt")

# 1. combine train and test data into one data set
trainFeatureData <- read.table("./train/X_train.txt")
trainActivityData <- read.table("./train/Y_train.txt")
trainSubjectData <- read.table("./train/subject_train.txt")

testFeatureData <- read.table("./test/X_test.txt")
testActivityData <- read.table("./test/Y_test.txt")
testSubjectData <- read.table("./test/subject_test.txt")

allFeatureData <- rbind(trainFeatureData, testFeatureData)
allActivityData <- rbind(trainActivityData, testActivityData)
allSubjectData <- rbind(trainSubjectData, testSubjectData)

allData <- cbind(allFeatureData, allActivityData, allSubjectData)

# 2. Extract only features that measure mean and std
meanstdfeatures <-grep("mean\\(\\)|std\\(\\)", features$labels)
meanstdData <- subset(allFeatureData, , meanstdfeatures)

featurenames<- features$labels[meanstdfeatures]

# 3. Label activity while preserving row order
library(dplyr)
allActivityData$id <- 1:nrow(allActivityData)
allActivityLabel <- arrange(merge(allActivityData, activity, by = "V1"), id)
allActivityLabel <-rename(allActivityLabel, ActivityLabel = V2)

allSubjectData <- rename(allSubjectData, Subject = V1)

# 4. Label data set with variable names
featurenames<-sapply(featurenames, function(x) gsub("-","",x))
featurenames<-sapply(featurenames, function(x) gsub("\\(\\)","",x))

meanstData<-setNames(meanstdData, featurenames)
finalData <- cbind(meanstData, ActivityLabel = allActivityLabel$ActivityLabel, Subject = allSubjectData$Subject)

# 5. Tabulate mean by subject and activity
summaryData <- finalData %>% group_by(Subject, ActivityLabel) %>% summarize_each(funs(mean))
write.table(summaryData, "summaryData.txt", row.names=FALSE)
