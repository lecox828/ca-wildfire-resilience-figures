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

#Treatment Tracker Footprint Acres Figure
footprint <- read.csv("/Users/Lauren/Desktop/footprint.csv")
as.data.frame(footprint)
require(ggplot2)
footprint.plot<-ggplot(data=footprint, aes(x=Year, y=Footprint.Acres)) +
  geom_bar(stat="identity", fill = c("#515426"))+
  labs (x = bquote('Year'), y = expression('Unique Acres Treated'), title = "Interagency Treatment Tracker Footprint Acres")+
  scale_y_continuous(labels = scales::comma)+
  TF

print (footprint.plot)

#Add horizontal line at 1M acres

footprint.plot.with.target<-ggplot(data=footprint, aes(x=Year, y=Footprint.Acres)) +
  geom_bar(stat="identity", fill = c("#515426"))+
  geom_hline(yintercept = 1000000, linetype = "dashed", color = "#9F2214")+
  labs (x = bquote('Year'), y = expression('Unique Acres Treated'), title = "Interagency Treatment Tracker Footprint Acres")+
  scale_y_continuous(labels = scales::comma)+
  TF

print (footprint.plot.with.target)

ggsave(plot=footprint.plot.with.target, 
       filename=file.path("Users/lauren/Desktop/footprint.plot.with.target.png"),
       height=4, width=8, units=c("in"))
