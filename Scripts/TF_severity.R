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

mtbs <- read.csv("/Users/Lauren/Desktop/year_summary.csv")
unique(mtbs$severity_desc)
mtbs$severity <- mtbs$severity_desc

mtbs <- mtbs %>%
 mutate(severity = recode(severity, 'unburned_low' = "Unburned/Low", 
                                   'low' = "Low", 
                                    "moderate" = "Moderate", 
                                    "high" = "High"))

mtbs$severity <- factor(mtbs$severity, levels=c('High', 'Moderate', 'Low', 'Unburned/Low'))

mtbs <- filter(mtbs, year != 2023,  year != 2024)
mtbs <- filter(mtbs, year >=2004)

severity.plot<-ggplot(data=mtbs, aes(x=year, y=tot_acres, fill = severity)) +
  geom_bar(position="stack", stat="identity")+
  labs (x = bquote('Year'), y = expression('Acres Burned'), title = "Acres Burned by Severity Class")+
  scale_fill_manual(values = c("#D19223", "#CCC4A4", "#737144", "#444620"), 
                    name = "Burn Severity")+
  scale_y_continuous(labels = scales::comma)+
  scale_x_continuous(breaks = c(2004, 2005, 2006, 2007, 2008, 2009, 2010, 2011, 2012, 2013, 
                                2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022))+
  TF
print(severity.plot)

ggsave(plot=severity.plot, 
       filename=file.path("Users/lauren/Desktop/severity2004.png"),
       height=4, width=8, units=c("in"))

severity.by.ownership.calc <- mtbs %>%
  group_by(year, severity, agency) %>%
  summarise(acres = sum(area_ac, na.rm = TRUE), n=n())
severity.by.ownership.calc$severity <- factor(severity.by.ownership.calc$severity, levels=c('High', 'Moderate', 'Low'))

severity.by.ownership.2021 <- filter (severity.by.ownership.calc, year == 2021)
severity.by.ownership.2022 <- filter (severity.by.ownership.calc, year == 2022)

plot.2021<-ggplot(data=severity.by.ownership.2021, aes(x=agency, y=acres, fill = severity)) +
  geom_bar(position="dodge", stat="identity")+
  labs (x = bquote('Agency'), y = expression('Acres Burned'))+
  scale_fill_manual(values = c("#9F2214", "#DA9A28", "#515426", "#855914", "#5A3B00"), 
                    name = "Burn Severity")+
  scale_y_continuous(labels = scales::comma)+
  TF

plot.2022<-ggplot(data=severity.by.ownership.2022, aes(x=agency, y=acres, fill = severity)) +
  geom_bar(position="dodge", stat="identity")+
  labs (x = bquote('Agency'), y = expression('Acres Burned'))+
  scale_fill_manual(values = c("#9F2214", "#DA9A28", "#515426", "#855914", "#5A3B00"), 
                    name = "Burn Severity")+
  scale_y_continuous(labels = scales::comma)+
  TF

