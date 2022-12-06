#  자료 불러오기
rm(list= ls())
Price <- read.csv('./bakery/Bakery price.csv', na.strings = c(''))
Sales <- read.csv('./bakery/Bakery Sales.csv', na.strings = c(''))

str(Price)
str(Sales)

names(Price)
names(Sales)


tail(Sales)
Sales<-Sales[1:2420,]
str(Sales)


library('VIM')
aggr(Sales[,1:4], prop = F,numbers = T)

# 가격 자료 정리
Price
Price$Name
Price$Name[Price$Name== 'valina latte'] <- 'vanila latte'

menus <- Price$Name

saled_menus <- names(Sales)[-(1:4)]



# 결제 기록에서 메뉴와 다른 이름
saled_menus
saled_menus[! saled_menus %in% menus]
saled_menus <- gsub('[.]',' ' ,saled_menus)
saled_menus[ !(saled_menus %in% menus)]
menus


# 없는 메뉴는 임의로 추가
Price[dim(Price)[1]+1,] <- c('americano', 4000)
Price[dim(Price)[1]+1,] <- c('caffe latte', 4500)
Price[dim(Price)[1]+1,] <- c('croque monsieur',4000 )
Price[dim(Price)[1]+1,] <- c('mad garlic', 3000)
Price[dim(Price)[1]+1,] <- c('milk tea', 4500)
Price
saled_menus[ !(saled_menus %in% Price$Name)]
names(Sales)[-(1:4)]<-saled_menus


options(scipen=999)
color_list = colors()


# 요일별 주문 횟수
table(Sales$day.of.week)
barplot(table(Sales$day.of.week), col = color_list[1:7 *10])

# 요일별 판매 금액 평균
week_mean <- aggregate(Sales$total, by = list(day.of.week = Sales$day.of.week), FUN = mean)
week_mean
barplot(week_mean$x, names.arg = week_mean$day.of.week,
        main = '요일별 판매 금액 평균', col = color_list[1:7 *10])

# 상품별 판매 수
menu_sales_count <- apply(Sales[,-(1:4)], MARGIN = 2, FUN = sum, na.rm = T)
menu_sales_count

barplot(menu_sales_count, 
        col = color_list[1:length(menu_sales_count) *10],
        angle=90,las=2)


# 음료, 제빵/ 제과 류 구분
drinks = c('americano', 'caffe latte', 'cacao deep','milk tea','lemon ade','vanila latte','berry ade' )
bakery= names(menu_sales_count)[!(names(menu_sales_count) %in% drinks)]
drinks
bakery

barplot(menu_sales_count[c(drinks)], 
        col = color_list[1:length(drinks) *10],
        angle=90,las=2)

barplot(menu_sales_count[c(bakery)], 
        col = color_list[1:length(bakery) *10],
        angle=90,las=2)


# 커피
coffee <- c('americano', 'caffe latte','vanila latte')
barplot(menu_sales_count[c(coffee)], 
        col = color_list[1:length(coffee) *10],
        angle=90,las=2)


# 월별 매출 합계
# as.Date(Sales$datetime)
month_sales <- aggregate(Sales$total, by = list(yearMonth = strftime(Sales$datetime, "%Y_%m")), FUN = sum)
month_sales
barplot(month_sales$x, names.arg = month_sales$yearMonth,
        main = '월별 판매 금액 평균', col = color_list[1:7 *10])
