#Author: Lauren Cox
#Date: December 2024
#Updated by Lauren Cox in May 2025

#Theme for Task Force Figures
TF <- theme(text=element_text(size=14, family="Century Gothic"))+
  theme (axis.text.x = element_text(size=12, angle = 90))+
  theme (axis.text.y = element_text (size = 12))+
  theme (axis.title.x = element_text (size =14))+  
  theme (axis.title.y = element_text (size =14))+
  theme (legend.text = element_text(size =12))+
  theme (legend.title = element_text (size = 14))+
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"))

TFcolors <- c("#9F2214", "#DA9A28", "#515426", "#737144", "#9C8F57", "#E9E5C3", "#5A3B00", "#855914")

fatalities <- read.csv("/Users/Lauren/Desktop/Task Force/Figures for Patrick/Data/fatalities.csv")
unique(fatalities$Fatalities)
head(fatalities)
require(ggplot2)

fatalities$Year <- as.numeric(fatalities$Year)
fatalities$Fatalities <- as.numeric(fatalities$Fatalities)
fatality.plot<-ggplot(data=fatalities, aes(x=Year, y=Fatalities)) +
  geom_bar(stat="identity", fill = c("#9C8F57"))+
  labs (x = bquote('Year'), y = expression('Fatalities'), title="Civilan and Firefighter Fatalities Resulting from Wildfire")+
 scale_x_continuous(breaks = c(2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023, 2024)) +
   TF

ggsave(plot=fatality.plot, 
       filename=file.path("Users/lauren/Desktop/fatalities.png"),
       height=4, width=8, units=c("in"))
  