library(shiny)
library(packcircles)
library(ggplot2)
library(viridis)
library(lubridate)
library(ggridges)
library(hrbrthemes)
library(plotly)

genres <- read.csv('../../Kdrama_data/genres.csv')
df <- read.csv('../../Kdrama_data/kdramalist.csv')

# 방영 시작 연도
start_year <-  year(dmy(df$start.airing))


df$start_year <- start_year
df[df$score == 'N/A','score']<- NA
df[df$Duration == 'N/A','Duration']<- NA
df[df$imdb_rating == 'N/A','imdb_rating']<- NA
df$score <- as.numeric(df$score)
df$Duration <- as.numeric(df$Duration)
df$imdb_rating <- as.numeric(df$imdb_rating)
genres$genre <- sub(' ','',genres$genre)
# 결측치
genres[genres$kdrama_name == 'Trio','genre'] <- 'life'

# 통합자료
select_cols <- c('drama_name','score', 'Popularity', 'Watchers', 'start_year')
names(genres)[1] <- 'drama_name'
genres<-merge(genres, df[,c(select_cols)], by = 'drama_name')
genres<-subset(genres, genres$genre != 'drama')
# genres
# unique(genres$genre)
# 페이지 구성
ui<-fluidPage(
  # 버블 그래프-------
    column(width = 4,
           h3('연도별 제작 수 비교'),
           plotlyOutput('bubblePlot_hansu'),
           
           sliderInput('yearSlider', 
                       '연도:',
                       animate = T,
                       min = min(genres$start_year, na.rm = T),
                       max = max(genres$start_year, na.rm = T),
                       value = max(genres$start_year, na.rm = T)),
           tableOutput('data_hansu')
    ),
    column(width = 6,

           # popularity
           h3('장르별 인기도 분포'),
           plotOutput('plot2_hansu'),
           
           # 평점
           # h3('장르별 평점 분포'),
           # plotOutput('plot3_hansu')
           
           #  평점/ 인기도 scatter
           h3('장르별 인기도와 평점 시각화'),
           plotOutput('scatterPlot_hansu', click = 'plot_click_hansu')
           
    ),
  # 장르 선택창
    column(width = 1,
           checkboxGroupInput('genre_choice',
                              'genre',
                              choices = unique(genres$genre),
                              selected = unique(genres$genre)[1:7])
    )

)

    


# 기능 구현
server <- function(input, output){
  # 연도별 방영 수 
  output$bubblePlot_hansu <- renderPlotly({
    s_year <- input$yearSlider
    year_data <- subset(genres, start_year == s_year)
    year_data <- aggregate(year_data$drama_name, by = list(genre = year_data$genre), length)
    
    names(year_data)[2]<-'count'
    
    # Generate the layout
    packing <- circleProgressiveLayout(year_data$count, sizetype='area')
    packing$radius <- 0.95*packing$radius
    year_data <- cbind(year_data, packing)
    dat.gg <- circleLayoutVertices(packing, npoints=50)
    
    # Plot 
    p<-ggplot() + 
      geom_polygon(data = dat.gg, aes(x, y, group = id, fill=id), colour = "black", alpha = 0.6) +
      scale_fill_viridis() +
      geom_text(data = year_data, aes(x, y, size=count, label = genre), color="black") +
      theme_void() + 
      theme(legend.position="none")+ 
      coord_equal()
    ggplotly(p)
    
  })
  # 장르별 Popularity 분포
  output$plot2_hansu <- renderPlot({
    
    select_data <- subset(genres, genres$genre %in% input$genre_choice)
    
    ggplot(select_data[select_data$Popularity < 50000,], aes(x = Popularity, y = genre, fill = stat(x))) +
      geom_density_ridges_gradient(scale = 3, rel_min_height = 0.01) +
      scale_fill_viridis( option = "C") +
      labs(title = '') +
      # theme_ipsum() +
      theme(
        legend.position="none",
        panel.spacing = unit(0.1, "lines"),
        strip.text.x = element_text(size = 8)
      )
  })
  # 장르별 score 분포
  output$plot3_hansu <- renderPlot({
    select_data <- subset(genres, genres$genre %in% input$genre_choice)
    
    ggplot(select_data, aes(x = score, y = genre, fill = stat(x))) +
      geom_density_ridges_gradient(scale = 3, rel_min_height = 0.01) +
      scale_fill_viridis(option = "C") +
      labs(title = '') +
      # theme_ipsum() +
      theme(
        legend.position="none",
        panel.spacing = unit(0.1, "lines"),
        strip.text.x = element_text(size = 8)
      ) 
  })
  
  output$scatterPlot_hansu <- renderPlot({
    select_data <- subset(genres, genres$genre %in% input$genre_choice)
    ggplot(select_data[select_data$Popularity < 50000,], aes(x = Popularity, y = score, color = genre)) +
      geom_point(size=4)
      
  })
  output$data_hansu <- renderTable({
    select_data <- subset(genres, genres$genre %in% input$genre_choice)
    req(input$plot_click_hansu)
    nearPoints(select_data, input$plot_click_hansu)
  })
  
  
}

shinyApp(ui, server)
