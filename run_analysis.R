library(reshape2)

packages <- c("data.table", "reshape2","Rcpp")
sapply(packages, require, character.only=TRUE, quietly=TRUE)
path <- getwd()
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, file.path(path, "dataFiles.zip"))
unzip(zipfile = "dataFiles.zip")

#****Loading activity labels and features****
#********************************************
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
activityLabels[,2] <- as.character(activityLabels[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

##**********************************

# Extracting the data on mean and standard deviation
featuresbis <- grep(".*mean.*|.*std.*", features[,2])
featuresbis.names <- features[featuresbis,2]
featuresbis.names = gsub('-mean', 'Mean', featuresbis.names)
featuresbis.names = gsub('-std', 'Std', featuresbis.names)
featuresbis.names <- gsub('[-()]', '', featuresbis.names)

##**********************************

#****Loading the datasets****
tr <- read.table("UCI HAR Dataset/train/X_train.txt")[featuresbis]
trActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
tr <- cbind(trSubjects, trActivities, tr)
#*****************************
tes <- read.table("UCI HAR Dataset/test/X_test.txt")[featuresbis]
tesActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
tesSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
tes <- cbind(tesSubjects, tesActivities, tes)
#********************************
#****merging datasets and add labels****
Data.all <- rbind(tr, tes)
colnames(Data.all) <- c("subject", "activity", featuresbis.names)

##***************************************
#****turning activities & subjects into factors****
#****RESUTLS****
Data.all$activity <- factor(Data.all$activity, levels = activityLabels[,1], labels = activityLabels[,2])
Data.all$subject <- as.factor(Data.all$subject)

Data.all.melted <- melt(Data.all, id = c("subject", "activity"))
Data.all.mean <- dcast(Data.all.melted, subject + activity ~ variable, mean)

write.table(Data.all.mean, "tidy.txt", row.names = FALSE, quote = FALSE)
