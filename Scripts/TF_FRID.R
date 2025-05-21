#Author: Lauren Cox
#Date: December 2024
#Updated by Lauren Cox in May 2025

#The merge messed up the Central Coast suregion. So we are going to load 
#the merged file, remove the Central Coast subregion, then reattach
#the correct Central Coast file

FRID.merged <- read.csv("/Users/Lauren/Desktop/FRID_merge_complete.csv")

FRID.merged <- FRID.merged %>% select(meanCC_FRI, meanCC_FRI_1970, Shape_Area, Acres, FRG_edited)

FRID <- FRID.merged

FRID <- filter(FRID, meanCC_FRI_1970 != -999)

FRID$Shape_Area <- as.numeric(FRID$Shape_Area)
FRID$meanCC_FRI_1970 <- as.character(FRID$meanCC_FRI_1970)
FRID <- FRID %>%
  complete(meanCC_FRI_1970, nesting(FRG_edited))
FRID$meanCC_FRI_1970 <- factor(FRID$meanCC_FRI_1970, levels=c('-3', '-2', '-1', '1', '2', '3'))

FRID.1970 <-FRID%>%
  group_by (meanCC_FRI_1970)%>%
  summarise (shape.area = sum(Shape_Area, na.rm = TRUE), Acres = sum(Acres, na.rm=TRUE), n = n(), Year = '2022') %>%
  mutate(proportion = (Acres / sum(Acres)*100))


FRID.1970.plot<-ggplot(data=FRID.1970, aes(x=Year, y=proportion, fill = meanCC_FRI_1970)) +
  geom_col()+
  geom_bar(position="fill", stat="identity")+
  geom_text(aes(label = paste0(proportion, "%")),
            position = position_stack(vjust = 0.5), 
            family="Century Gothic") +
  scale_fill_manual(values = c("#A50026", "#F67E4B","#FEDA8B","#c2e4ef","#6ea6cd","#364b9A"), 
                    name = "Condition Class")+
  labs (y = expression('Percent of Area in Condition Class'), title = "Fire Return Interval Departure Since 1970")+
  TF

ggsave(plot=FRID.1970.plot, 
       filename=file.path("Users/lauren/Desktop/FRID_statewide.png"),
       height=4, width=6, units=c("in"))

FRID <- FRID %>%
  mutate(meanCC_FRI_1970 = recode(meanCC_FRI_1970, '-3' = 'Severe', 
                                  '-2' = 'Moderate', 
                                  '-1' = "Minimal", 
                                  '1' = "Minimal", 
                                  '2' = "Moderate", 
                                  '3' = 'Severe'
  ))

FRID.1970.grouped <-FRID%>%
  group_by (meanCC_FRI_1970)%>%
  summarise (shape.area = sum(Shape_Area, na.rm = TRUE), n = n(), Year = '2022') %>%
  mutate(proportion = (shape.area / sum(shape.area)*100))

FRID.1970.grouped$meanCC_FRI_1970 <- factor(FRID.1970.grouped$meanCC_FRI_1970, levels=c('Severe', 'Moderate', 'Minimal'))

FRID.1970.grouped$proportion <-round(FRID.1970.grouped$proportion, digits = 1)

FRID.1970.grouped.plot<-ggplot(data=FRID.1970.grouped, aes(x=Year, y=proportion, fill = meanCC_FRI_1970)) +
  geom_col()+
  geom_bar(position="fill", stat="identity")+
  geom_text(aes(label = paste0(proportion, "%")),
            position = position_stack(vjust = 0.5), 
            family="Century Gothic") +
  scale_fill_manual(values = c("#D19223", "#CCC4A4", "#737144"), 
                    name = "Condition Class")+
  labs (y = expression('Percent of Area in Condition Class'), title = "Fire Return Interval Departure Since 1970")+
  TF
ggsave(plot=FRID.1970.grouped.plot, 
       filename=file.path("Users/lauren/Desktop/FRID_grouped.png"),
       height=4, width=6, units=c("in"))
