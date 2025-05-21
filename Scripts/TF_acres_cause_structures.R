#Author: Yihong Zhu
#Date: December 2024
#Updated by Lauren Cox in May 2025

library(tidyverse)
library(readxl)
getwd()

# Load fire perimeter
firedata=read.csv(here::here("Desktop/California_Fire_Perimeters_(all).csv"))
firedata

# Load damage
damage=read.csv(here::here("Desktop/Damage_Inspection.csv"))
                      
# Theme -------------------------------------------------------------------
#windowsFonts(`Century Gothic`=windowsFont("Century Gothic"))

TF <- theme(text=element_text(size=14, family="Century Gothic"))+
  theme (axis.text.x = element_text(size=12, angle = 90))+
  theme (axis.text.y = element_text (size = 12))+
  theme (axis.title.x = element_text (size =14))+  
  theme (axis.title.y = element_text (size =14))+
  theme (legend.text = element_text(size =12))+
  theme (legend.title = element_text (size = 14))+
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"))

# TFcolors <- c("#9F2214", "#DA9A28", "#515426", "#737144", "#9C8F57", "#E9E5C3", "#5A3B00", "#855914")

TFcolors <- c("#231805", "#D19223", "#444620", "#737144", "#CCC4A4")

# Data preparation ------------------------------------------------------------
head(firedata)
unique(firedata$STATE)#Do we want only CA or ALL?
unique(firedata$CAUSE)#Cause type in geodatabase 
unique(firedata$YEAR_) %>% summary()#NA?; Can do1900-2023-->ASK 
firedata %>% filter(YEAR_==1878)
#protocal of data collection
firedata %>% filter(is.na(YEAR_))#Year not reported, exclude
summary(firedata$GIS_ACRES)#Based on data dictionary, it seems we should use this coulmn



##Cause type based on data dictionary
data.frame(cause_id=1:19,
           cause_type=c("Lightning","Equipment Use","Smoking","Campfire","Debris",
                        "Railroad","Arson","Playing with fire","Miscellaneous","Vehicle",
                        "Powerline","Firefighter Training","Non-Firefighter Training","Unknown/Unidentified","Structure",
                        "Aircraft","Volcanic","Escaped Prescribed Fire","Illegal Alien Campfire"))

# Filter to column we need
df_clean=firedata %>% filter(YEAR_>=1900 & YEAR_<=2024) %>% 
  select(YEAR_,STATE,FIRE_NAME,INC_NUM,CAUSE,GIS_ACRES, CAUSE) 
unique(df_clean$CAUSE)

unique(df_clean$FIRE_NAME)

# Figure 1. Total acres burned by wildfire by year+5year average---------------
# Calculate 10-year average for making figures
df_acres=
  df_clean %>% 
  filter(YEAR_>=1960) %>% 
  group_by(YEAR_) %>% 
  summarise(total_acres=sum(GIS_ACRES)) %>% 
  mutate(rolling_avg=zoo::rollmean(total_acres,5,fill=NA,align="right"))


fig1=df_acres %>%
  filter(YEAR_ >= 2005) %>%
  ggplot(aes(x = YEAR_)) +
  geom_col(aes(y = total_acres, fill = "Total Acres"), color = TFcolors[2]) +
  geom_line(aes(y = rolling_avg, color = "5-Year Moving Average")) +
  scale_fill_manual(name = NULL, values = TFcolors[2]) +
  scale_color_manual(name = NULL, values = TFcolors[1]) +
  scale_x_continuous(breaks = seq(2005, 2024, 1)) +
  scale_y_continuous(labels = scales::comma)+
  theme(axis.text.x = element_text(angle = 90, hjust = 1),
        legend.position = "bottom") +
  labs(
    title = "Total Acres Burned by Wildfire",
    x = "Year",
    y = "Total Acres Burned"
  ) +
  TF
print(fig1)

ggsave(plot=fig1, 
       filename=file.path("/Users/laurencox/Desktop/fig1.png"),
       height=4, width=8, units=c("in"))
#ggsave(here::here("Desktop","fig1.png"),fig1,width=10,height=6)

#Figure 2. Total acres burned by large wildfire------------------------------
#+Number of large wildfires
#+Number of megafires
df_large=
  df_clean %>% 
  filter(GIS_ACRES>10000&YEAR_>=1970) %>%
  group_by(YEAR_) %>% 
  summarise(total_acres=sum(GIS_ACRES),
            n_large=n()) 

df_mega=
  df_clean %>% 
  filter(GIS_ACRES>100000&YEAR_>=1970) %>%
  group_by(YEAR_) %>% 
  summarise(n_mega=n()) 

df_large_figure=
  left_join(df_large,df_mega,by="YEAR_")%>% 
  mutate(n_mega=ifelse(is.na(n_mega),0,n_mega))

fig2=df_large_figure %>% 
  filter(YEAR_>=2005) %>%
  ggplot(aes(x=YEAR_))+
  geom_col(aes(y = total_acres, fill = "Total Acres Burned"), color = TFcolors[2])+
  geom_line(aes(y = n_mega*100000, color = "Number of Megafires (>100k acres)"),linetype="dashed")+
  geom_line(aes(y = n_large*100000, color = "Number of Large Fires (>10k acres)"),linetype=4)+
  geom_point(aes(y = n_mega*100000, color = "Number of Megafires (>100k acres)"))+
  geom_point(aes(y = n_large*100000, color = "Number of Large Fires (>10k acres)"))+
  scale_fill_manual(name = NULL, values = TFcolors[2]) +
  scale_color_manual(name = NULL, values = TFcolors[c(4,3)]) +
  scale_x_continuous(breaks = seq(2005, 2024, 1)) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1),
        legend.position = "bottom")+
  labs(title="Total Acres Burned by Large Wildfire (>10k acres)",
       x="Year",
       y="Total Acres Burned")+
  scale_y_continuous(
    name = "Total Acres Burned",
    labels = scales::comma,
    sec.axis = sec_axis( trans=~./100000, name="Number of Fires", labels = scales::comma)
  ) +
  TF

print(fig2)
ggsave(plot=fig2, 
       filename=file.path("/Users/laurencox/Desktop/fig2.png"),
       height=4, width=9, units=c("in"))


# Figure 3. Total acres burned by cause by year---------------------------------
fig3a=df_clean %>% 
  filter(YEAR_>=2005) %>% 
  filter(CAUSE != "Volcanic")%>%
  mutate(cause_group=ifelse(CAUSE %in% c("Lightning"),"Lightning",
                     ifelse(CAUSE %in% c("Electrical Power"),"Electrical Power",
                     ifelse((CAUSE=="Unknown / Unidentified"|is.na(CAUSE)), "Undetermined",
                     "Human")))) %>%
  group_by(cause_group,YEAR_) %>% 
  summarise(total_acres=sum(GIS_ACRES)) %>%
  ggplot(aes(x=YEAR_,y=total_acres,fill=cause_group))+
  geom_col(position="stack",
           aes(y = total_acres))+
  scale_fill_manual(name = "Cause of Fire", values = TFcolors[c(5,4,3,1)]) +
  scale_x_continuous(breaks = seq(2005, 2024, 1)) +
   scale_y_continuous(labels = scales::comma)+
  theme(axis.text.x = element_text(angle = 90, hjust = 1))+
  labs(title="Total Acres Burned by Cause",
       x="Year",
       y="Total Acres Burned",
       fill="Cause Group")+
  TF
print(fig3a)
ggsave(plot=fig3a, 
       filename=file.path("/Users/laurencox/Desktop/fig3.png"),
       height=4, width=8, units=c("in"))

#ggsave(here::here("figures","fig3a.png"),fig3a,width=10,height=6)


# Figure 4. Residential Structures Damaged or Destroyed-------------------------
##data preparation
damage$Incident.Start.Date.new=as.Date(damage$Incident.Start.Date,format="%m/%d/%Y")
damage$Structure_reclass=ifelse(damage$Structure.Category %in% 
                                c("Single Residence",
                                  "Mixed Commercial/Residential",
                                  "Multiple Residence"),"Residential","Non-Residential")


df_damage=damage %>% filter(year(Incident.Start.Date.new)>=2014) %>%
  filter(X..Damage!="No Damage") %>%
  group_by(Structure_reclass,year(Incident.Start.Date.new)) %>% 
  summarise(n=n()) %>%
  print(n=Inf)


df_fire=firedata %>% filter(YEAR_ >=2015) %>%
  filter (YEAR_ != 2025)%>%
  group_by(YEAR_) %>%
  summarise(total_acres=sum(GIS_ACRES))

df_fire=left_join(df_fire,df_damage,by=c("YEAR_"="year(Incident.Start.Date.new)")) %>%
  mutate(n=ifelse(is.na(n),0,n))

#Plot
fig4=
  df_fire %>% 
  ggplot(aes(x=YEAR_,y=n, fill=Structure_reclass))+
  geom_col(position="dodge", aes(y = n))+
  geom_line(aes(y = (total_acres/200), color = "Total Acres Burned"), linetype="dashed")+
  geom_point(aes(y = (total_acres/200), color = "Total Acres Burned"))+
  scale_fill_manual(name = "Structure Type:", values = TFcolors[c(1,2)]) +
  scale_color_manual(name = NULL, values = TFcolors[3]) +
  scale_x_continuous(breaks = seq(2015, 2024, 1)) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1),
        legend.position = "bottom") +
  labs(title="Structures Damaged or Destroyed by Wildfire",
       x="Year",
       y="Number of Structures",
       fill="Structure Type")+
  scale_y_continuous(
    name = "Number of Structures",
    labels = scales::comma,
    sec.axis = sec_axis( trans=~.*200, name="Total Acres Burned",  labels = scales::comma)
  ) +
  guides(
    fill = guide_legend(override.aes = list(shape = NA)),  # Remove points inside the filled boxes
    color = guide_legend(override.aes = list(shape = 16))  # Keep the point in the line legend
  ) +
  TF
print(fig4)

ggsave(plot=fig4, 
       filename=file.path("/Users/laurencox/Desktop/fig4.png"),
       height=4, width=8, units=c("in"))
#ggsave(here::here("figures","fig4.png"),fig4,width=10,height=6)
