# Productivity-Analysis-Auxiliary-Tool

This project is a productivity measuring tool based on keystroke and mouse click. And also monitoring the application usage try to help users have better understanding of their daily work.

# Building

This is a Xcode project. It’s recommended to use Xcode to work on this project to save time for trivial settings for the environment.

## Privacy Setting

To run this project, register this application to the Security and Privacy panel in macOS system preference, this will allow this application to monitor the keystroke, mouse click on your system and allow this application to send apple events to ask for current using applications.

## Install Third-party Library

This project uses CocoaPods to manage third-party libraries. If you don’t have CocoaPods in your computer, to install CocoaPods can use the following command or use Sudo-less installation given by [official website](https://guides.cocoapods.org/using/getting-started.html)

`sudo gem install cocoapods`

Next, move to the project folder and enter the following command to install pods.

`pod install`

# How to Use

This application will start to record and can live in background until the user terminate it.

- **Time Usage Table**:  
The table on the left bottom corner will show the usage time for each application user uses.

- **Activity History**:  
The chart on the top left corner shows the history of the user’s activity in 24 hours. To choose what application activity want to get the data. Select the row in the Time Usage Table. The label text on the chart will change to the application name that the user chose.

- **Productivity Analysis**:  
The productivity analysis uses a line chart to show the growth rate of total mouse click and keypress each hour compared to last week’s or last month’s data.

# Existing Issue

- **Auto Save**:  
This project currently does not support auto save.

- **Cross-day Data**:  
The project does not auto save when the day passes(24:00 or 0:00). For example, it might generate the case that the start time for an application is 5/22 and ends on 5/23. And this will cause some problem.

- **Failed Detection**:  
Some specific application detection might fail when using this application.

- **Calculation Design**:  
This project will start detection and store the activity data when the user opens it. And it will base on the history data to compare today’s activity. This can be a problem if users just open it but work on other devices or rarely open the application.