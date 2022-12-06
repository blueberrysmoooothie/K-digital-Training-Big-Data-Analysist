df <- read.csv('../Kdrama_data/kdramalist.csv')

as.numeric('')
df[df$score == 'N/A','score']<- NA
df[df$Duration == 'N/A','Duration']<- NA
df[df$imdb_rating == 'N/A','imdb_rating']<- NA
df$score <- as.numeric(df$score)
df$Duration <- as.numeric(df$Duration)
df$imdb_rating <- as.numeric(df$imdb_rating)

# libraries
library(packcircles)
library(ggplot2)
library(viridis)
library(lubridate)
library(ggridges)
library(hrbrthemes)
library(plotly)


# 날짜 변환시 지역 변경
as.Date('Feb 21, 2018', format = '%b %e, %Y')
df$start.airing[1]
year
Sys.setlocale("LC_ALL", "English")

format(Sys.Date(), "%B")
year(Sys.Date())

Sys.Date()
month.abb

# 방영 시작 연도
start_year <- ifelse(!is.na(as.Date(df$start.airing, '%e-%b-%y')),
       year(as.Date(df$start.airing, '%e-%b-%y')),
       ifelse(!is.na(as.Date(df$start.airing, ' %b %e, %Y')),
              year(as.Date(df$start.airing, ' %b %e, %Y')),
              year(as.Date(df$start.airing, '%Y'))))

start_year

df$start_year <- start_year
df
# networks <- read.csv('../Kdrama_data/networks.csv')
# platforms <- read.csv('../Kdrama_data/platforms.csv')
genres <- read.csv('../Kdrama_data/genres.csv')
# str(networks)
# str(platforms)
str(genres)

unique(genres$genre)

sum(!complete.cases(genres))
genres[!complete.cases(genres),]
genres[genres$kdrama_name == 'Trio',]
df[df$drama_name == 'Trio',]

genres[genres$genre == ' life',]
df[df$drama_name == 'Aurora Princess',]

genres[genres$kdrama_name == 'Trio','genre'] <- ' life'

select_cols <- c('drama_name','score', 'imdb_rating', 'Popularity', 'Watchers', 'start_year')
names(genres)[1] <- 'drama_name'
names(genres)
genres<-merge(genres, df[,c(select_cols)], by = 'drama_name')
str(genres)


# 연도별 방영 수 - s_year가 변할 수 있도록 - 에니메이션?  transition_times
s_year = 2020
year_data = subset(genres, start_year == s_year)
year_data <- aggregate(year_data$drama_name, by = list(genre = year_data$genre), length)

names(year_data)[2]<-'count'
year_data
# Generate the layout
packing <- circleProgressiveLayout(year_data$count, sizetype='area')
packing$radius <- 0.95*packing$radius
year_data <- cbind(year_data, packing)
dat.gg <- circleLayoutVertices(packing, npoints=50)
year_data
# Plot 
p<-ggplot() + 
  geom_polygon(data = dat.gg, aes(x, y, group = id, fill=id), colour = "black", alpha = 0.6) +
  scale_fill_viridis() +
  geom_text(data = year_data, aes(x, y, size=count, label = genre), color="black") +
  theme_void() + 
  theme(legend.position="none")+ 
  coord_equal()
ggplotly(p)

# 장르별 평균 점수/ 유명도? - 특정 장르 정해서 몇개만 해보기 - 선택 창
str(genres)
select_genres <- c()
# Popularity Plot
ggplot(genres[genres$Popularity < 50000,], aes(x = Popularity, y = genre, fill = stat(x))) +
  geom_density_ridges_gradient(scale = 3, rel_min_height = 0.01) +
  scale_fill_viridis(name = "Temp. [F]", option = "C") +
  labs(title = '') +
  theme_ipsum() +
  theme(
    legend.position="none",
    panel.spacing = unit(0.1, "lines"),
    strip.text.x = element_text(size = 8)
  )

# score Plot
ggplot(genres, aes(x = score, y = genre, fill = stat(x))) +
  geom_density_ridges_gradient(scale = 3, rel_min_height = 0.01) +
  scale_fill_viridis(name = "Temp. [F]", option = "C") +
  labs(title = '') +
  theme_ipsum() +
  theme(
    legend.position="none",
    panel.spacing = unit(0.1, "lines"),
    strip.text.x = element_text(size = 8)
  ) 


# 










# libraries:
library(ggplot2)
library(gganimate)
library(babynames)
library(hrbrthemes)
library(viridis)

# Keep only 3 names
don <- data.frame(babynames)

don <- don[don$name %in% c("Ashley", "Patricia", "Helen"),]
don <- don[don$sex == 'F']

# don <- don %>% 
#   filter(don$name %in% c("Ashley", "Patricia", "Helen")) %>%
#   filter(don$sex=="F")


don$year


data.frame()

str(don)
# Plot
don %>%
  ggplot( aes(x=name, fill=name)) +
  geom_bar() +
  ggtitle("Popularity of American names in the previous 30 years") +
  theme_ipsum() +
  ylab("Number of babies born") +
  transition_states(year)

anim_save("287-smooth-animation-with-tweenr.gif")


library(nord)
ChickWeight
ggplot(ChickWeight, aes(x=Chick, y=weight, fill=Diet))+
  geom_col(show.legend=FALSE)+
  scale_fill_nord('afternoon_prarie')+
  theme_minimal()+
  transition_states(Time,
                    transition_length=1.5,
                    state_length=0.5)


str(genres)

