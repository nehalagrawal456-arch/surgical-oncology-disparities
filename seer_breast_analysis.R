# LIST.FILES("~", PATTERN = "SEER")
library(tidyverse)
seer <- read_tsv("~/seerreastraw.txt", col_types = cols(.default = "c"))
glimpse(seer)
names(seer) <- c("surgery", "county_type","age","race","marital","year")
count(seer, surgery, sort = TRUE)
seer$code <- as.numeric(seer$surgery)
seer$surgery_group <- case_when(seer$code == 0 ~ "No surgery",seer$code >= 20 & seer$code<= 24 ~ "breast-conserving" , seer$code >=30 &seer$code <= 80 ~" Mastectomy",TRUE ~ "other/unknown")
count(seer, surgery_group)
seer$surgery_group <- str_to_sentence(str_trim(seer$surgery_group))
seer2<- seer %>% filter (surgery_group %in% c("Breast-conserving", "Mastectomy"), !str_detect(county_type, "Unknown"))
seer2$mastectomy <- ifelse(seer2$surgery_group =="Mastectomy",1,0)
seer2 %>% group_by(county_type) %>% summarise(women = n(), mastectomy_pct = round(100* mean(mastectomy),1))
seer2 %>% group_by(county_type) %>% summarise(pct = 100 * mean(mastectomy)) %>% ggplot(aes(x = county_type, y = pct)) + geom_col() +coord_flip()
seer2$year <- as.numeric(seer2$year)

seer3 <- seer2 %>%
  filter(!str_detect(race, regex("unknown", ignore_case = TRUE)),
         !str_detect(marital, regex("unknown", ignore_case = TRUE)),
         !str_detect(age, regex("unknown", ignore_case = TRUE)))

seer3$age_num <- as.numeric(str_extract(seer3$age, "[0-9]+"))
seer3$age_group <- cut(seer3$age_num,
                       breaks = c(0, 39, 49, 59, 69, 79, 120),
                       labels = c("under 40", "40-49", "50-59", "60-69", "70-79", "80+"))

seer3$county_type <- fct_infreq(seer3$county_type)

model <- glm(mastectomy ~ county_type + age_group + race + marital + year,
             data = seer3, family = binomial)

res <- data.frame(group = names(coef(model)),
                  ratio = exp(coef(model)),
                  low = exp(confint.default(model)[, 1]),
                  high = exp(confint.default(model)[, 2]))
res$ratio <- round(res$ratio, 2)
res$low <- round(res$low, 2)
res$high <- round(res$high, 2)
res
plot_data <- res %>%
  filter(str_detect(group, "county_type")) %>%
  mutate(group = str_wrap(str_remove(group, "county_type"), 30))

ggplot(plot_data, aes(x = ratio, y = group, xmin = low, xmax = high)) +
  geom_pointrange() +
  geom_vline(xintercept = 1, linetype = "dashed") +
  labs(title = "Mastectomy odds by county type, breast cancer 2004-2022",
       x = "Odds compared with large-city counties (1 = no difference)",
       y = "") +
  theme_minimal()

ggsave("county_chart.png", width = 9, height = 4)
seer3$area <- ifelse(str_detect(seer3$county_type, "^Nonmetropolitan"),
                     "Rural", "Urban and small metro")

trend <- seer3 %>%
  group_by(year, area) %>%
  summarise(pct = 100 * mean(mastectomy), .groups = "drop")

ggplot(trend, aes(x = year, y = pct, colour = area)) +
  geom_line(linewidth = 1) +
  geom_point() +
  labs(title = "Mastectomy rate by year, rural vs other counties",
       x = "Year of diagnosis",
       y = "Women having a mastectomy (%)",
       colour = "") +
  theme_minimal()

ggsave("trend_chart.png", width = 8, height = 4)
seer3$area <- factor(seer3$area, levels = c("Urban and small metro", "Rural"))

race_results <- seer3 %>%
  group_by(race) %>%
  group_modify(function(d, key) {
    m <- glm(mastectomy ~ area + age_group + marital + year,
             data = d, family = binomial)
    ci <- confint.default(m)["areaRural", ]
    data.frame(ratio = round(exp(as.numeric(coef(m)["areaRural"])), 2),
               low = round(exp(ci[1]), 2),
               high = round(exp(ci[2]), 2),
               women = nrow(d))
  })

race_results

ggplot(race_results, aes(x = ratio, y = race, xmin = low, xmax = high)) +
  geom_pointrange() +
  geom_vline(xintercept = 1, linetype = "dashed") +
  labs(title = "Rural vs other counties: mastectomy odds by race",
       x = "Odds in rural counties vs other counties (1 = no difference)",
       y = "") +
  theme_minimal()

ggsave("race_chart.png", width = 8, height = 4)