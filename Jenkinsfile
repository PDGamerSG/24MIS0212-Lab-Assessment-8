pipeline {
    agent none
    options {
        disableConcurrentBuilds()
        timeout(time: 60, unit: 'MINUTES')
    }
    stages {
        stage('Question 1 - Notice Board') {
            steps { build job: 'Assessment 8 Q1 Notice Board', wait: true, propagate: true }
        }
        stage('Question 2 - Student Feedback') {
            steps { build job: 'Assessment 8 Q2 Student Feedback', wait: true, propagate: true }
        }
        stage('Question 3 - Placement Portal') {
            steps { build job: 'Assessment 8 Q3 Placement Portal', wait: true, propagate: true }
        }
    }
}
