#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
ui <- dashboardPage(
  skin = "green",
  dashboardHeader(title = "Patient Similarity Networks",
                  titleWidth = 300),
  
  
  # SIDEBAR -----------------------------------------------------------------
  
  dashboardSidebar(
    width = 300,
    sidebarMenu(
      menuItem("Project Introduction", tabName = "introduction", icon = icon("question-circle")),
      menuItem("Networks", tabName = "network", icon = icon("project-diagram")),
      menuItem("30-day Mortality",tabName = "predictions", icon = icon("brain")),
      menuItem("Survival Analysis",tabName = "surv", icon = icon("chart-line")),
    
    
      radioButtons(inputId = "select_subgroup", 
                   label = "Select Data Subgroup: ",
                   choices = subgroups,
                   selected = "all"),
      radioButtons(inputId = "select_cluster",
                   label = "Select Cluster: ",
                   choices = clusters,
                   selected = 0),
      width = 3
    )
  ),
  
  # MAIN BODY ---------------------------------------------------------------
  dashboardBody(
    tabItems(
      
      # Introduction Tab --------------------------------------------------------
    
      tabItem(tabName = "introduction",
              h2("Project Introduction"),
              fluidRow(
                box(title = strong("Summary"), 
                    includeMarkdown("./text/intro_summary.md")
                ),
                box(title = strong("Advantages"),
                    includeMarkdown("./text/intro_advantages.md")
                )
              ),
              fluidRow(
                box(title = strong("Methodology"),
                    includeMarkdown("./text/intro_method.md")
                ),
                box(title = strong("Contents"),
                    includeMarkdown("./text/intro_contents.md")
                )
              )),
      
      # Networks Tab --------------------------------------------------------
      tabItem(tabName = "network",
              fluidRow(
                box(title = strong("Similarity Network for Subgroup"), 
                    solidHeader = T,
                    width = 6,
                    visNetworkOutput("sim_network")#,   height = 550)
                    ),
                box(title = strong("Selected Nodes Differentiators"),
                    width = 6,
                    dataTableOutput("int_num_diff"),
                    dataTableOutput("cat_num_diff"))
              ),
              fluidRow(
                box(title = strong("Cluster Differentiators (numeric)"), 
                    solidHeader = T,
                    width = 6,
                  dataTableOutput("numeric_diff")
                ),
                box(title = strong("Cluster Differentiators (categorical)"), 
                    solidHeader = T,
                    width = 6,
                    dataTableOutput("categorical_diff"),
                    style = "overflow-x: scroll;"
                )
              )),
      
      # Predictive analysis -----------------------------------------------------
      tabItem(tabName = "predictions",
              fluidRow(
                box(title = strong("Methodology:"),
                  width = 6,
                  includeMarkdown("./text/prediction_method.md")
                    ),
                box(title = strong("30 Day Mortality Result Summary"), 
                    width = 6,
                    dataTableOutput("30day_summary"),
                    dataTableOutput("mortality_summary"), align = "center"
                    )
              ),
              fluidRow(
                box(title = strong("Feature Importance Comparison"),
                    width = 12,
                    plotlyOutput("30day_features")
                    )
              )),
      
      # Survival Analysis Tab --------------------------------------------------------
      
      tabItem(tabName = "surv",
              fluidRow(
                box(title = strong("Survival Analysis Contents"),
                    width = 6,
                    includeMarkdown("./text/survival_analysis.md")
                ),
                box(title = strong("Survival Probability at a Specific Day Summary"), 
                    width = 6,
                    numericInput("num_surv", "Select Number of Days After Last Discharge:", min = 0, max = 3000, value = 365.25),
                    tableOutput("survival_summary"), 
                    tableOutput("survival_selected"), 
                    align = "center"
                )
              ),
              fluidRow(
                box(title = strong("Survival Plot and Risk"),
                    width = 6,
                    plotOutput("survival_plot")
                ),
                box(title = strong("Cumulative Hazard Ratio"),
                    width = 6,
                    tableOutput("cox_regression"),
                    plotOutput("cumhaz_plot")
                )
              ))
              
    )
  )
)

    