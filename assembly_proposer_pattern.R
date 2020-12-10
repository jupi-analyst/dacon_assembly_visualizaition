getwd()
setwd('~/sh_R/open')
library(tidyverse)
library(reshape2)
library(scales)
library(extrafont)
library(plotly)
library(gridExtra)
loadfonts()
new_people <- read.csv('open/new_people.csv', fileEncoding = 'euc-kr')
process <- read_csv('open/process.csv')
suggest <- read_csv('open/suggest.csv')

# Ư������ȸ ���� �� 20�� ��ȸ�� ����
suggest_df <- suggest[-grep(suggest$COMMITTEE, pattern = "Ư������ȸ"),]
age20_suggest <- suggest_df %>%
  filter(AGE == 20)

# �Ұ�����ȸ�� ���ǵ� ��
age20_suggest %>%
  filter(!is.na(COMMITTEE)) %>%
  group_by(COMMITTEE) %>%
  summarise(n = n()) %>%
  arrange(desc(n)) %>%
  ggplot(aes(x = reorder(COMMITTEE, n), y= n)) +
  geom_bar(stat='identity') +
  coord_flip()


# �Ұ����� ó�����
age20_suggest %>%
  filter(!is.na(COMMITTEE)) %>%
  group_by(COMMITTEE, PROC_RESULT) %>%
  summarise(n = n()) %>%
  ggplot(aes(x = reorder(COMMITTEE, n), y= n,  fill = PROC_RESULT)) +
  geom_bar(stat='identity') +
  coord_flip() +
  theme(legend.title = element_text(size = 9),
        legend.text = element_text(size = 8))

# �Ұ����� ����
age20_suggest %>%
  filter(PROC_RESULT == '��������' | PROC_RESULT =='���Ȱ���') %>%
  group_by(COMMITTEE) %>%
  summarise(n = n()) %>%
  ggplot(aes(x = reorder(COMMITTEE, n), y= n)) +
  geom_bar(stat='identity') +
  coord_flip() +
  ggtitle("�Ұ����� ���� ��") +
  labs(x = "�Ұ���", y = "�����") +
  theme(plot.title = element_text(family = "NanumGothicExtraBold", hjust = 0.5, size =13))

# �Ұ����� ���
age20_suggest %>%
  filter(!is.na(COMMITTEE)) %>%
  filter(PROC_RESULT == '�ӱ⸸�����' | PROC_RESULT =='���' | PROC_RESULT == '�����ȹݿ����') %>%
  group_by(COMMITTEE) %>%
  summarise(n = n()) %>%
  ggplot(aes(x = reorder(COMMITTEE, n), y= n)) +
  geom_bar(stat='identity') +
  coord_flip() +
  ggtitle("�Ұ����� ���") +
  labs(x = "�Ұ���", y = "����") +
  theme(plot.title = element_text(family = "NanumGothicExtraBold", hjust = 0.5, size =13))

# �Ұ����� ��ȹݿ�
age20_suggest %>%
  filter(!is.na(COMMITTEE)) %>%
  filter(PROC_RESULT == '��ȹݿ����') %>%
  group_by(COMMITTEE) %>%
  summarise(n = n()) %>%
  ggplot(aes(x = reorder(COMMITTEE, n), y= n)) +
  geom_bar(stat='identity') +
  coord_flip() +
  ggtitle("�Ұ����� ��ȹݿ�") +
  labs(x = "�Ұ���", y = "��ȹݿ���") +
  theme(plot.title = element_text(family = "NanumGothicExtraBold", hjust = 0.5, size =13))

# ����, ���, ��ȹݿ� ����
age20_suggest %>%
  filter(!is.na(COMMITTEE)) %>% 
  filter(PROC_RESULT == '��������' | PROC_RESULT == '���Ȱ���') %>%
  group_by(COMMITTEE) %>% 
  summarise(���� = n()) -> success_df

age20_suggest %>%
  filter(!is.na(COMMITTEE)) %>% 
  filter(PROC_RESULT == '�ӱ⸸�����' | PROC_RESULT == '�����ȹݿ����' |
           PROC_RESULT == '���') %>%
  group_by(COMMITTEE) %>% 
  summarise(���= n()) -> trash_df

age20_suggest %>%
  filter(!is.na(COMMITTEE)) %>% 
  filter(PROC_RESULT == '��ȹݿ����') %>%
  group_by(COMMITTEE) %>% 
  summarise(��ȹݿ� = n()) -> alter_df

# ���� �� ó������� ����
result_df <- left_join(inner_join(alter_df, success_df), trash_df)
result_df[is.na(result_df)] = 0 # NA�� 0���� ó��
result_df %>%
  mutate(��ȹݿ����� = sum(��ȹݿ�),            # �� ó����� ��ü ��
               ������� = sum(���),
               �������� = sum(����)) %>%
  group_by(COMMITTEE) %>%
  mutate(��ȹݿ��� = ��ȹݿ� / ��ȹݿ�����,    # ��ü �� �� ó�� ��� ����
              ����� = ��� / �������,
              ������ = ���� / ��������) -> result_df

count_result_df <- melt(result_df, id.vars = "COMMITTEE", measure.vars = c("����","��ȹݿ�","���"))
count_result_df %>%
  ggplot(aes(x = reorder(COMMITTEE, value), y = value, fill = variable)) +
  geom_bar(stat='identity', color = 'black', position = 'dodge') +
  coord_flip()

per_result_df <- melt(result_df, id.vars = "COMMITTEE", measure.vars = c("������","��ȹݿ���","�����"))
per_result_df %>%
  mutate(COMMITTEE = factor(COMMITTEE)) %>%
  mutate(value = value * 100) %>%
  ggplot(aes(x = fct_reorder(COMMITTEE, value), y = value, fill = variable)) +
  geom_bar(stat='identity', position = 'fill', color = 'black') +
  coord_flip() +
  scale_y_continuous(labels = percent)

# per_result_df %>% 
#   filter(variable == '������') %>%
#   group_by(COMMITTEE) %>%
#   summarise(���� = round(value * 100, 1)) %>%
#   ggplot(aes(x = "", y = ����, fill = COMMITTEE)) +
#   geom_bar(stat='identity', width = 1, color = 'white') +
#   coord_polar("y", start = 0) +
#   theme_void() +
#   ggtitle("���� ���� ����ó�� ���") +
#   labs(x = "", y = "") +
#   theme(plot.title = element_text(size = 13, hjust = 0.5, family = "NanumGothicExtraBold")) +
#   geom_text(aes(label = paste0(����, "%")), 
#             color = "white", size=3, position = position_stack(vjust = 0.5))




# �� �ǿ��� � ���ȿ� ������ ������ �ִ��� (�� ������ �� ��������ȸ�� ������ ����) ex)Ȳ��ȫ
committee_df <- data.frame(COMMITTEE = levels(as.factor(age20_suggest$COMMITTEE)))
age20_suggest %>%
  filter(RST_PROPOSER == 'Ȳ��ȫ') %>% #name
  filter(!is.na(COMMITTEE)) %>%
  group_by(RST_PROPOSER, COMMITTEE, PROC_RESULT) %>%
  summarise(n = n()) -> proposer_committee

proposer_committee_df <- full_join(proposer_committee,committee_df)
proposer_committee_df$RST_PROPOSER = 'Ȳ��ȫ' #name
na.omit(proposer_commproposer_committee_dfittee_df)

proposer_committee_df %>%
  filter(PROC_RESULT == '��������' | PROC_RESULT == '���Ȱ���') %>%
  group_by(COMMITTEE) %>%
  summarise(���� = sum(n)) -> proposer_success_df
proposer_success_df <- left_join(committee_df, proposer_success_df )

proposer_committee_df %>%
  filter(PROC_RESULT == '�ӱ⸸�����' | PROC_RESULT == '�����ȹݿ����' | PROC_RESULT == '���') %>%
  group_by(COMMITTEE) %>%
  summarise(��� = sum(n)) -> proposer_trash_df
proposer_trash_df <- left_join(committee_df, proposer_trash_df )

proposer_committee_df %>%
  filter(PROC_RESULT == '��ȹݿ����') %>%
  group_by(COMMITTEE) %>%
  summarise(��ȹݿ� = sum(n)) -> proposer_alter_df
proposer_alter_df <- left_join(committee_df, proposer_alter_df )



proposer_committee_result <- inner_join(inner_join(proposer_success_df, proposer_trash_df, by ='COMMITTEE'), proposer_alter_df, by = 'COMMITTEE')
proposer_committee_result[is.na(proposer_committee_result)] = 0 # NA�� 0���� ����

### -----------------------------------------------------�����׷��� ----------------------------------------------
# ��ü ������ ���ϱ����� ����
result_totalSum <- sum(proposer_committee_result$���� + proposer_committee_result$��� + proposer_committee_result$��ȹݿ�)
# ��ü ���ǹ��� ó�� �����
proposer_committee_result %>%
  group_by(COMMITTEE) %>%
  mutate(������ = ���� / result_totalSum,
            ����� = ��� / result_totalSum,
            ��ȹݿ��� = ��ȹݿ� / result_totalSum) %>%
  melt(id.vars = 'COMMITTEE', measure.vars = c('������', '�����', '��ȹݿ���')) -> melt_proposer_comm_result_ratio


## ���� �ڵ�� ��ü
melt_proposer_comm_result_ratio %>%
  group_by(variable) %>%
  summarise(���� = round(sum(value) * 100, 1)) %>%
  ggplot(aes(x = "", y = ����, fill = variable)) +
  geom_bar(stat='identity', width = 1, color = 'white') +
  coord_polar("y", start = 0) +
  theme_void() +
  ggtitle("Ȳ��ȫ�ǿ�, ���� ���� ó�� ���") +
  labs(x = "", y = "") +
  theme(plot.title = element_text(size = 13, hjust = 0.5, family = "NanumGothicExtraBold")) +
  geom_text(aes(label = paste0(����, "%")),
            color = "white", size=3, position = position_stack(vjust = 0.5))

# ���� �ǿ���, �Ұ����� ó����� ex) Ȳ��ȫ�ǿ��� ������ǰ�ؾ��������ȸ������ ó�� ���
age20_suggest %>%
  filter(RST_PROPOSER =='Ȳ��ȫ') %>%
  group_by(COMMITTEE) %>%
  summarise(n = n()) %>%
  arrange(desc(n)) %>%
  head(5) -> top5_index

proposer_committee_result %>%
  filter(COMMITTEE %in% top5_index$COMMITTEE) %>%
  group_by(COMMITTEE) %>%
  mutate(������ = ���� / sum(����,���,��ȹݿ�),
            ����� = ��� / sum(����,���,��ȹݿ�),
            ��ȹݿ��� = ��ȹݿ� / sum(����,���,��ȹݿ�)) -> proposer_committee_result_ratio
tmp <- list()
for(i in 1:5) {
  tmp[[i]] <- data.frame(melt(proposer_committee_result_ratio[i, ],
       id.vars = 'COMMITTEE', 
       measure.vars = c('������', '�����', '��ȹݿ���')))
}

tmp[[1]] %>%
  group_by(COMMITTEE,variable) %>%
  summarise(���� = round(sum(value) * 100, 1)) %>%
  ggplot(aes(x = "", y = ����, fill = variable)) +
  geom_bar(stat='identity', width = 1, color = 'white') +
  coord_polar("y", start = 0) +
  theme_void() +
  ggtitle(paste0("Ȳ��ȫ�ǿ�,",tmp[[1]]$COMMITTEE, "\n ���� ���� ó�� �����")) +
  labs(x = "", y = "") +
  theme(plot.title = element_text(size = 13, hjust = 0.5, family = "NanumGothicExtraBold")) +
  geom_text(aes(label = paste0(����, "%")),
            color = "white", size=3, position = position_stack(vjust = 0.5)) -> p1 

tmp[[2]] %>%
  group_by(COMMITTEE,variable) %>%
  summarise(���� = round(sum(value) * 100, 1)) %>%
  ggplot(aes(x = "", y = ����, fill = variable)) +
  geom_bar(stat='identity', width = 1, color = 'white') +
  coord_polar("y", start = 0) +
  theme_void() +
  ggtitle(paste0("Ȳ��ȫ�ǿ�,",tmp[[2]]$COMMITTEE, "\n ���� ���� ó�� �����")) +
  labs(x = "", y = "") +
  theme(plot.title = element_text(size = 13, hjust = 0.5, family = "NanumGothicExtraBold")) +
  geom_text(aes(label = paste0(����, "%")),
            color = "white", size=3, position = position_stack(vjust = 0.5)) -> p2

tmp[[3]] %>%
  group_by(COMMITTEE,variable) %>%
  summarise(���� = round(sum(value) * 100, 1)) %>%
  ggplot(aes(x = "", y = ����, fill = variable)) +
  geom_bar(stat='identity', width = 1, color = 'white') +
  coord_polar("y", start = 0) +
  theme_void() +
  ggtitle(paste0("Ȳ��ȫ�ǿ�,",tmp[[3]]$COMMITTEE, "\n ���� ���� ó�� �����")) +
  labs(x = "", y = "") +
  theme(plot.title = element_text(size = 13, hjust = 0.5, family = "NanumGothicExtraBold")) +
  geom_text(aes(label = paste0(����, "%")),
            color = "white", size=3, position = position_stack(vjust = 0.5)) -> p3

tmp[[4]] %>%
  group_by(COMMITTEE,variable) %>%
  summarise(���� = round(sum(value) * 100, 1)) %>%
  ggplot(aes(x = "", y = ����, fill = variable)) +
  geom_bar(stat='identity', width = 1, color = 'white') +
  coord_polar("y", start = 0) +
  theme_void() +
  ggtitle(paste0("Ȳ��ȫ�ǿ�,",tmp[[4]]$COMMITTEE, "\n ���� ���� ó�� �����")) +
  labs(x = "", y = "") +
  theme(plot.title = element_text(size = 13, hjust = 0.5, family = "NanumGothicExtraBold")) +
  geom_text(aes(label = paste0(����, "%")),
            color = "white", size=3, position = position_stack(vjust = 0.5)) -> p4

tmp[[5]] %>%
  group_by(COMMITTEE,variable) %>%
  summarise(���� = round(sum(value) * 100, 1)) %>%
  ggplot(aes(x = "", y = ����, fill = variable)) +
  geom_bar(stat='identity', width = 1, color = 'white') +
  coord_polar("y", start = 0) +
  theme_void() +
  ggtitle(paste0("Ȳ��ȫ�ǿ�,",tmp[[5]]$COMMITTEE, "\n ���� ���� ó�� �����")) +
  labs(x = "", y = "") +
  theme(plot.title = element_text(size = 13, hjust = 0.5, family = "NanumGothicExtraBold")) +
  geom_text(aes(label = paste0(����, "%")),
            color = "white", size=3, position = position_stack(vjust = 0.5)) -> p5

# melt(proposer_committee_result_ratio, 
#      id.vars = 'COMMITTEE', measure.vars = c('������', '�����', '��ȹݿ���')) -> proposer_committee_ratio

grid.arrange(p1,p2,p3,p4,p5, nrow = 3, ncol = 2)

tmp
## �Ʒ��ڵ�� ��ü
proposer_committee_ratio %>%
  group_by(variable) %>%
  summarise(���� = round(sum(value) * 100, 1)) %>%
  ggplot(aes(x = "", y = ����, fill = variable)) +
  geom_bar(stat='identity', width = 1, color = 'white') +
  coord_polar("y", start = 0) +
  theme_void() +
  ggtitle("Ȳ��ȫ�ǿ�, ������ǰ�ؾ��������ȸ \n���� ���� ���� ó�� �����") +      ## {name}, {committee}
  labs(x = "", y = "") +
  theme(plot.title = element_text(size = 13, hjust = 0.5, family = "NanumGothicExtraBold")) +
  geom_text(aes(label = paste0(����, "%")),
            color = "white", size=3, position = position_stack(vjust = 0.5))
### --------------------------------------------------------------------------------------
###  ------------------------------------------------------���ͷ�Ƽ��׷���
library(plotly)
proposer_committee_result %>%
  group_by(COMMITTEE) %>%
  melt(id.vars = 'COMMITTEE', measure.vars = c('����', '���', '��ȹݿ�')) -> melt_proposer_comm_result_count

melt_proposer_comm_result_count %>%
  group_by(variable) %>%
  summarise(value = sum(value)) %>% 
  plot_ly(labels = ~variable, values = ~value, type = 'pie', 
          textinfo='label+percent')%>%
  layout(title = 'Ȳ��ȫ�ǿ�, ������ ��ü ���� ó�� �����',
         xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
         yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))

# �� �ǿ��� ���帹�� ������ �Ұ����� ���� TOP5���� ó������� ��ü������ ��Ÿ����
age20_suggest %>%
  filter(RST_PROPOSER =='Ȳ��ȫ') %>%
  group_by(COMMITTEE) %>%
  summarise(n = n()) %>%
  arrange(desc(n)) %>%
  head(5) -> top5_index

melt_proposer_comm_result_count %>%
  filter(COMMITTEE %in% top5_index$COMMITTEE) -> top5_result_df
top5_result_df %>%
  ggplot(aes(x = fct_reorder(COMMITTEE, value), y = value, fill = variable)) +
  geom_bar(stat='identity', position = 'dodge', color = 'black') +
  coord_flip()

# top5_result_df %>%
#   filter(COMMITTEE == '������ǰ�ؾ��������ȸ') %>%
#   plot_ly(labels = ~variable, values = ~value, type = 'pie',
#           textinfo='label+percent') %>%
#   layout(title = 'Ȳ��ȫ�ǿ�, ������ǰ�ؾ��������ȸ \n���� ���� ���� ó�� �����',
#          xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
#          yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))


fig <- plot_ly(textinfo = 'label + percent', 
               textposition = 'inside',
               insidetextfont = list(color = 'white'),
               marker = list(line = list(color ='white', width = 1)))
fig <- fig %>% add_pie(data = top5_result_df %>% filter(COMMITTEE == COMMITTEE[1]), 
                       labels = ~variable, values = ~value, name = "", domain = list(row = 0, column = 0))
fig <- fig %>% add_pie(data = top5_result_df %>% filter(COMMITTEE == COMMITTEE[2]), 
                        labels = ~variable, values = ~value, name = "", domain = list(row = 0, column = 1))
fig <- fig %>% add_pie(data = top5_result_df %>% filter(COMMITTEE == COMMITTEE[3]), 
                       labels = ~variable, values = ~value, name = "", domain = list(row = 1, column = 0))
fig <- fig %>% add_pie(data = top5_result_df %>% filter(COMMITTEE == COMMITTEE[4]), 
                       labels = ~variable, values = ~value, name = "", domain = list(row = 1, column = 1))
fig <- fig %>% add_pie(data = top5_result_df %>% filter(COMMITTEE == COMMITTEE[5]), 
                       labels = ~variable, values = ~value, name = "", domain = list(row = 2, column = 0))
fig <- fig %>% layout(title = "Ȳ��ȫ�ǿ� ������ ���Ȱ��� TOP5 �Ұ���, ���� ó�����", showlegend = T,
                      grid=list(rows=3, columns=2),
                      xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
                      yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))

fig

# ������ ���� �� ��ó�� �Լ�
each_proposer <- function(age, name) {
  # n���ǿ� ����, Ư��������
  suggest_df <- suggest[-grep(suggest$COMMITTEE, pattern = "Ư������ȸ"),]
  age_suggest <- suggest_df %>%
    filter(AGE == age)
  
  # �Ұ�����ȸ ����
  committee_df <- data.frame(COMMITTEE = levels(as.factor(age_suggest$COMMITTEE)))
  
  # 
  age_suggest %>%
    filter(RST_PROPOSER == name) %>% #name
    filter(!is.na(COMMITTEE)) %>%
    group_by(RST_PROPOSER, COMMITTEE, PROC_RESULT) %>%
    summarise(n = n()) -> proposer_committee
  
  # �Ұ����� Ư�������� ���ǹ��� ���� �Ұ����� ����
  proposer_committee_df <- full_join(proposer_committee,committee_df)
  proposer_committee_df$RST_PROPOSER = name #name
  na.omit(proposer_committee_df)
  
  # ���� ó�� ����Ǹ� ����
  proposer_committee_df %>%
    filter(PROC_RESULT == '��������' | PROC_RESULT == '���Ȱ���') %>%
    group_by(COMMITTEE) %>%
    summarise(���� = sum(n)) -> proposer_success_df
  proposer_success_df <- left_join(committee_df, proposer_success_df )
  
  # ���� ó�� ���Ǹ� ����
  proposer_committee_df %>%
    filter(PROC_RESULT == '�ӱ⸸�����' | PROC_RESULT == '�����ȹݿ����' | PROC_RESULT == '���') %>%
    group_by(COMMITTEE) %>%
    summarise(��� = sum(n)) -> proposer_trash_df
  proposer_trash_df <- left_join(committee_df, proposer_trash_df )
  
  # ���� ó�� ��ȹݿ��Ǹ� ����
  proposer_committee_df %>%
    filter(PROC_RESULT == '��ȹݿ����') %>%
    group_by(COMMITTEE) %>%
    summarise(��ȹݿ� = sum(n)) -> proposer_alter_df
  proposer_alter_df <- left_join(committee_df, proposer_alter_df )
  
  # ���� ó������ ��� ����
  proposer_committee_result <- inner_join(inner_join(proposer_success_df, proposer_trash_df, by ='COMMITTEE'), proposer_alter_df, by = 'COMMITTEE')
  proposer_committee_result[is.na(proposer_committee_result)] = 0 # NA�� 0���� ����
  
  # ��ó�� �Լ����� ���� �����͸� �ð�ȭ�� ���� metl��Ŵ
  proposer_committee_result%>%
    group_by(COMMITTEE) %>%
    melt(id.vars = 'COMMITTEE', measure.vars = c('����', '���', '��ȹݿ�')) -> melt_proposer_comm_result_count
  
  melt_proposer_comm_result_count %>%
    group_by(variable) %>%
    summarise(value = sum(value)) %>% 
    plot_ly(labels = ~variable, values = ~value, type = 'pie', 
            textinfo='label+percent')%>%
    layout(title = paste0(name, '�ǿ��� ������ ���� ��ü ó�� �����'),
           xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
           yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
  
  # �ǿ� ���ǹ��� ���� top5 �Ұ��� ����
  age20_suggest %>%
    filter(RST_PROPOSER == name) %>%
    group_by(COMMITTEE) %>%
    summarise(n = n()) %>%
    arrange(desc(n)) %>%
    head(5) -> top5_index
  
  # �ð�ȭ�� ���� melt
  melt_proposer_comm_result_count %>%
    filter(COMMITTEE %in% top5_index$COMMITTEE) -> top5_result_df
  
  # �Ұ��� TOP5 ���ͷ�Ƽ�� �ð�ȭ 
  fig <- plot_ly(textinfo = 'label + percent', 
                 textposition = 'inside',
                 insidetextfont = list(color = 'white'),
                 marker = list(line = list(color ='white', width = 1)))
  fig <- fig %>% add_pie(data = top5_result_df %>% filter(COMMITTEE == COMMITTEE[1]), 
                         labels = ~variable, values = ~value, name = "", domain = list(row = 0, column = 0))
  fig <- fig %>% add_pie(data = top5_result_df %>% filter(COMMITTEE == COMMITTEE[2]), 
                         labels = ~variable, values = ~value, name = "", domain = list(row = 0, column = 1))
  fig <- fig %>% add_pie(data = top5_result_df %>% filter(COMMITTEE == COMMITTEE[3]), 
                         labels = ~variable, values = ~value, name = "", domain = list(row = 1, column = 0))
  fig <- fig %>% add_pie(data = top5_result_df %>% filter(COMMITTEE == COMMITTEE[4]), 
                         labels = ~variable, values = ~value, name = "", domain = list(row = 1, column = 1))
  fig <- fig %>% add_pie(data = top5_result_df %>% filter(COMMITTEE == COMMITTEE[5]), 
                         labels = ~variable, values = ~value, name = "", domain = list(row = 2, column = 0))
  fig <- fig %>% layout(title = paste0(name,"�ǿ� ������ ���Ȱ��� TOP5 �Ұ����� ���� ó�����"), 
                        showlegend = T,
                        grid=list(rows=3, columns=2),
                        xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
                        yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
  fig
}
each_proposer(20, 'Ȳ��ȫ')

top5_total <- function(age, name){
  # n���ǿ� ����, Ư��������
  suggest_df <- suggest[-grep(suggest$COMMITTEE, pattern = "Ư������ȸ"),]
  age_suggest <- suggest_df %>%
    filter(AGE == age)
  
  # �Ұ�����ȸ ����
  committee_df <- data.frame(COMMITTEE = levels(as.factor(age_suggest$COMMITTEE)))
  
  # 
  age_suggest %>%
    filter(RST_PROPOSER == '�ڱ���') %>% #name
    filter(!is.na(COMMITTEE)) %>%
    group_by(RST_PROPOSER, COMMITTEE, PROC_RESULT) %>%
    summarise(n = n()) -> proposer_committee
  
  # �Ұ����� Ư�������� ���ǹ��� ���� �Ұ����� ����
  proposer_committee_df <- full_join(proposer_committee,committee_df)
  proposer_committee_df$RST_PROPOSER = name  #name
  na.omit(proposer_committee_df)
  
  # ���� ó�� ����Ǹ� ����
  proposer_committee_df %>%
    filter(PROC_RESULT == '��������' | PROC_RESULT == '���Ȱ���') %>%
    group_by(COMMITTEE) %>%
    summarise(���� = sum(n)) -> proposer_success_df
  proposer_success_df <- left_join(committee_df, proposer_success_df )
  
  # ���� ó�� ���Ǹ� ����
  proposer_committee_df %>%
    filter(PROC_RESULT == '�ӱ⸸�����' | PROC_RESULT == '�����ȹݿ����' | PROC_RESULT == '���') %>%
    group_by(COMMITTEE) %>%
    summarise(��� = sum(n)) -> proposer_trash_df
  proposer_trash_df <- left_join(committee_df, proposer_trash_df )
  
  # ���� ó�� ��ȹݿ��Ǹ� ����
  proposer_committee_df %>%
    filter(PROC_RESULT == '��ȹݿ����') %>%
    group_by(COMMITTEE) %>%
    summarise(��ȹݿ� = sum(n)) -> proposer_alter_df
  proposer_alter_df <- left_join(committee_df, proposer_alter_df )
  
  # ���� ó������ ��� ����
  proposer_committee_result <- inner_join(inner_join(proposer_success_df, proposer_trash_df, by ='COMMITTEE'), proposer_alter_df, by = 'COMMITTEE')
  proposer_committee_result[is.na(proposer_committee_result)] = 0 # NA�� 0���� ����
  
  # ��ó�� �Լ����� ���� �����͸� �ð�ȭ�� ���� metl��Ŵ
  proposer_committee_result%>%
    group_by(COMMITTEE) %>%
    melt(id.vars = 'COMMITTEE', measure.vars = c('����', '���', '��ȹݿ�')) -> melt_proposer_comm_result_count
  
  age_suggest %>%
    filter(RST_PROPOSER == '�ڱ���') %>%
    filter(!is.na(COMMITTEE)) %>%
    group_by(COMMITTEE) %>%
    summarise(n = n()) %>%
    arrange(desc(n)) %>%
    head(5) -> top5_index
  
  melt_proposer_comm_result_count %>%
    filter(COMMITTEE %in% top5_index$COMMITTEE) -> top5_result_df
  
  top5_result_df %>%
    ggplot(aes(x = fct_reorder(COMMITTEE, value), y = value, fill = variable)) +
    geom_bar(stat='identity', position = 'dodge', color = 'black') +
    coord_flip() -> p2
  p2
  return(p2)
}
top5_total(20, '�ڱ���')