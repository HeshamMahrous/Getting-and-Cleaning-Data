## Create one R script called run_analysis.R that does the following:
## 1. Merges the training and the test sets to create one data set.
## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
## 3. Uses descriptive activity names to name the activities in the data set
## 4. Appropriately labels the data set with descriptive activity names.
## 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.

# Install the required libraries if not installed
if (!require("data.table")) {
  install.packages("data.table")
}

if (!require("reshape2")) {
  install.packages("reshape2")
}

require("data.table")
require("reshape2")

# Load: activity labels
activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt")[,2]

# Load: data column names
features <- read.table("./UCI HAR Dataset/features.txt")[,2]

# Extract only the measurements on the mean and standard deviation for each measurement.
extract_features <- grepl("mean|std", features)

# Load and process X_test, y_test, & subject_test data.
X_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt")

# Load and process X_test, y_test, & subject_test data.
X_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")

# Filter and Extract only mean and std features
X_test= X_test[,extract_features]
X_train= X_train[,extract_features]

# Add the labels to X_test and X_train
names(X_test) = features[extract_features]
names(X_train) = features[extract_features]

# cbind data "subject" "Activity_Label" and the data 
test_data = cbind(subject_test, y_test, X_test)
test_data[,2] = activity_labels[test_data[,2]] # change the activity ID to a discription
names(test_data)[1] = "Subject"
names(test_data)[2] = "Activity_Label"
train_data = cbind(subject_train, y_train, X_train) 
train_data[,2] = activity_labels[train_data[,2]] # change the activity ID to a discription
names(train_data)[1] = "Subject"
names(train_data)[2] = "Activity_Label"

# Merge the data together 
data = rbind(train_data, test_data)

# Create the averages for each activity
id_labels = c("Subject", "Activity_Label")
data_labels = setdiff(colnames(data), id_labels)
melt_data  = melt(data, id = id_labels, measure.vars = data_labels)
tidy_data   = dcast(melt_data, Subject + Activity_Label ~ variable, mean)

#Write the tidy table into a text file
write.table(tidy_data, file = "./tidy_data.txt" ,row.name=FALSE)
