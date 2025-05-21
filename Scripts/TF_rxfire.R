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

#Prescribed Fire Figures
rxfire <- read.csv("/Users/Lauren/Desktop/Task Force/Figures for Patrick/Data/rxfire_23_1.csv")
its <- read.csv("/Users/Lauren/Desktop/Task Force/Figures for Patrick/Data/ITS.broadcast.csv")

unique(rxfire$Treatment_Type)
rxfire$treatment.grouped <- rxfire$Treatment_Type
rxfire <- rxfire %>%
  mutate(treatment.grouped = recode(treatment.grouped, 'Machine Pile Burn' = "Pile Burn", 
                                    'Hand Pile Burn' = "Pile Burn", 
                                    "Broadcast Burn" = "Broadcast Burn", 
                                    "Jackpot Burn" = "Broadcast Burn", 
                                    "Fire Use" = "Fire Use", 
                                    "<Null>" = "Unknown"))

rxfire$agency.grouped <- rxfire$AGENCY

rxfire <- rxfire %>%
  mutate(agency.grouped = recode(agency.grouped, 'USDA Forest Service' = 'Federal', 
                                'California State Parks'  = 'State', 
                                'National Park Service' =  'Federal', 
                                'California Department of Forestry and Fire Protection' = 'State', 
                                'Other' = 'Other', 
                                'Local Response Area' = 'Other', 
                                'Contract County' = 'Other', 
                                'Private' = 'Other', 
                                'USDI Fish and Wildlife Service' = 'Federal', 
                                'Bureau of Land Management' = 'Federal', 
                                'Department of Defense' = 'Federal', 
                                'CCC' = 'Federal', 
                                'No Protection' = 'Other'))


require(dplyr)

rxfire$TREATED_AC <- as.numeric(rxfire$TREATED_AC)
rxfire$GIS_ACRES <- as.numeric(rxfire$GIS_ACRES)
rxfire$diff_acres <- rxfire$TREATED_AC - rxfire$GIS_ACRES

#There are a lot of 0's and NAs under the TREATED_AC column. This is because
#these are the numbers that are reported by individual agency and are not consistent
#across agency or year. For the purposes of this summary, use the GIS_ACRES - this 
#is consistent with what what done in the Year in Fire.

#Truncate to 1950 to match Year in Fire, but realized when graphing by agency that this only covers 
#state lands? Based on data presented by USFS papers, present only 1970 to present

rxfire <- rxfire %>% filter(YEAR >= 2021)
rxfire$year <- as.numeric(rxfire$YEAR)
its$year <- as.numeric(its$year)
rxfire$datasource <- "CALFIRE"
its$datasource <- "ITS"
its <- its[, c(1,3,2)]
rxfire <- rxfire %>% filter(Treatment_Type == "Broadcast Burn")

rxfire.by.year<-rxfire%>%
  group_by (year, AGENCY)%>%
  summarise (acres = sum(GIS_ACRES, na.rm = TRUE)) 
rxfire$year <- as.factor(rxfire$year)
require(tidyr)
rxfire.agency.test <- spread(rxfire.by.year,year, acres)
write.csv(rxfire.agency.test, "/Users/Lauren/Desktop/rxtest.csv")
rx <- rbind(rxfire.by.year, its)

rx$acres <- as.numeric(rx$acres)

TFcolors <- c("#231805", "#D19223", "#444620", "#737144", "#CCC4A4")

require(ggplot2)
year<-ggplot(data=rxfire.by.year, aes(x=year, y=acres)) +
  geom_bar(stat="identity", fill = c("#CCC4A4"))+
  labs (x = bquote('Year'), y = expression('Acres Treated'), title="Acres Treated with Broadcast Burns")+
  scale_y_continuous(labels = scales::comma)+
  scale_x_continuous(breaks = seq(2004, 2023, 1)) +
  TF

print (year)

ggsave(plot=year, 
       filename=file.path("Users/lauren/Desktop/broadcastburnCALFIRE.png"),
       height=4, width=8, units=c("in"))


#graph works

#For cleaner graph, consider only the last decade (2014-2023)
rxfire.by.year.10yrs <- rxfire.by.year %>% filter(YEAR >= 2014)

year.10yrs<-ggplot(data=rxfire.by.year.10yrs, aes(x=YEAR, y=acres)) +
  geom_bar(stat="identity", fill = c("#515426"))+
  labs (x = bquote('Year'), y = expression('Acres Treated'), title="Acres Treated with Prescribed Fire")+
  scale_y_continuous(labels = scales::comma)+
   TF

print (year.10yrs)

#Graph for prescribed fire use by treatment type
#Since 1970

rxfire.test <- rxfire %>% filter(YEAR >= 2021)
rxfire.test$Treatment_Type <- as.factor(rxfire.test$Treatment_Type)
rxfire.test$GIS_ACRES <- as.numeric(rxfire.test$GIS_ACRES)
rxfire.by.year.treat <- rxfire.test%>%
  group_by (YEAR, Treatment_Type)%>%
  summarise (acres = sum(GIS_ACRES, na.rm = TRUE), n = n()) 


rxfire.by.year.treat <- rxfire.by.year.treat %>% filter(YEAR >= 1970)

year.treat<-ggplot(data=rxfire.by.year.treat, aes(x=YEAR, y=acres, fill = treatment.grouped)) +
  geom_bar(position="stack", stat="identity")+
  labs (x = bquote('Year'), y = expression('Acres Treated'), title="Acres Treated with Prescribed Fire")+
  scale_fill_manual(values = c("#9F2214", "#DA9A28", "#515426", "#855914"), name = "Prescribed Fire Type")+
  TF

print(year.treat)
#Because of the number of null values for treatment type, avoid using this graph since
#1970. Only use the one below (last 10 years)

#Last 10 years

rxfire.by.year.treat.10yrs <- rxfire.by.year.treat %>% filter(YEAR >= 2014)

year.treat.10yrs<-ggplot(data=rxfire.by.year.treat.10yrs, aes(x=YEAR, y=acres, fill = treatment.grouped)) +
  geom_bar(position="stack", stat="identity")+
  labs (x = bquote('Year'), y = expression('Acres Treated'), title="Prescribed Fire Treatments")+
  scale_fill_manual(values = c("#9F2214", "#DA9A28", "#515426", "#855914"), name = "Prescribed Fire Type")+
  scale_y_continuous(labels = scales::comma)+
  TF

print(year.treat.10yrs)

#Graph for prescribed fire use by agency
#Since 1970

rxfire.by.year.agency<-rxfire%>%
  group_by (YEAR, agency.grouped, Treatment_Type)%>%
  summarise (acres = sum(GIS_ACRES, na.rm = TRUE), n = n()) 

rxfire.by.year.agency <- rxfire.by.year.agency %>% filter(YEAR >= 1970)

year.agency<-ggplot(data=rxfire.by.year.agency, aes(x=YEAR, y=acres, fill = agency.grouped)) +
  geom_bar(position="stack", stat="identity")+
  labs (x = bquote('Year'), y = expression('Acres Treated'), title = "Agency Use of Prescribed Fire")+
  scale_fill_manual(values = c("#9F2214", "#DA9A28", "#515426"), name = "Agency")+
  scale_y_continuous(labels = scales::comma)+
  TF


print(year.agency)

#Last 10 years

rxfire.by.year.agency.10yrs <- rxfire.by.year.agency %>% filter(YEAR >= 2014)

year.agency.10yrs<-ggplot(data=rxfire.by.year.agency.10yrs, aes(x=YEAR, y=acres, fill = agency.grouped)) +
  geom_bar(position="stack", stat="identity")+
  labs (x = bquote('Year'), y = expression('Acres Treated'), title = "Agency Use of Prescribed Fire")+
  scale_fill_manual(values = c("#9F2214", "#DA9A28", "#515426"), name = "Agency")+
  scale_y_continuous(labels = scales::comma)+
  TF
print(year.agency.10yrs)


