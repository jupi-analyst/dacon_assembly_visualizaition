getwd()
setwd('~/sh_R/open')
library(tidyverse)
library(reshape2)
library(extrafont)
library(scales)
library(ggplot2)
library(gridExtra)
loadfonts()
suggest <- read_csv('open/suggest.csv')

# 20���ǿ� �� ��ǿ��� ����, ���, ����� ������?
## 1. ������ ��ó�� �� EDA
### 1.1. ���ȹ����� ���� �ǿ� ��� ��(�� 21���ǿ� ����)
suggest %>%
  filter(AGE >= 16 & AGE != 21) %>%
  group_by(AGE, PROC_RESULT) %>%
  summarise(n = n()) %>% 
  arrange(desc(n)) %>%
  ggplot(aes(x = AGE, y = n, color = PROC_RESULT, fill = PROC_RESULT)) +
  geom_bar(stat = 'identity', position = 'dodge', color ='black') +
  theme_bw() +
  ggtitle("")
  labs(x = '16�� ~ 20��', y = '���� ��')
  


## 2000�⵵ 21����(16��)���� ���, ����, ��ȹݿ��� ���� ����� ����, 21��� �������� ��ȸ�̹Ƿ� ����
suggest %>%
  filter(AGE >= 16 & AGE != 21) %>%
  filter(PROC_RESULT == '�ӱ⸸�����'|PROC_RESULT == '�����ȹݿ����' | 
           PROC_RESULT == '��������' | PROC_RESULT == '���Ȱ���' | PROC_RESULT == '��ȹݿ����') %>%
  group_by(AGE, PROC_RESULT) %>%
  summarise(n = n()) %>% 
  arrange(desc(n)) %>%
  ggplot(aes(x = AGE, y = n, color = PROC_RESULT, fill = PROC_RESULT)) +
  geom_bar(stat = 'identity', position = 'dodge')

### 16~20���ǿ�, �� �뺰 ��ü ���Ǽ�
suggest %>%
  filter(AGE >= 16 & AGE != 21) %>%
  group_by(AGE) %>%
  summarise(���Ǽ� = n()) %>%
  ggplot(aes(x = AGE, y = ���Ǽ�)) +
  geom_bar(stat = 'identity', fill = 'skyblue', color = 'black') +
  xlab("�ǿ����") +
  ylab("���� ��") + 
  theme_minimal(base_family = 'NanumGothicExtraBold')

### 16~20���ǿ�, �� �뺰�� ��ü ���Ǽ� ������ ����
suggest  %>%
  filter(AGE >= 16, AGE != 21) %>%
  group_by(AGE) %>%
  summarise(���ȹ��Ǽ� = n()) -> age_total

### ���� �� �����(�����ȹݿ����, �ӱ⸸�����) 
### ������ ó���� ����
suggest %>%
  filter(AGE >= 16, AGE != 21) %>%
  filter(PROC_RESULT == '�ӱ⸸�����'|PROC_RESULT == '�����ȹݿ����') %>%
  group_by(AGE) %>%
  summarise(���� = n()) -> age_trash_total

trash_df <- inner_join(age_total, age_trash_total, by = 'AGE') # �� �������� ����

#### �뺰 ����
trash_df %>%
  ggplot(aes(x = AGE, y = ����)) +
  geom_bar(stat='identity', fill = "#F8766D", color = 'black') +
  geom_text(aes(label=round(����,1)), vjust=1.5, colour="white") +
  theme_bw(base_family = 'NanumGothic')

#### �뺰 ��� ����
trash_df %>%
  mutate(���_���� = (���� / ���ȹ��Ǽ�) *100) %>%
  ggplot(aes(x = AGE, y = ���_����)) +
  geom_bar(stat = 'identity', fill = "#F8766D" , color = 'black') +
  geom_text(aes(label= paste0(round(���_����,1), "%")), vjust=1.5, colour="white") +
  ggtitle("< �뺰 ��� ���� >") +
  labs(y = "������(%)", x = "�ǿ����") + 
  theme(plot.title = element_text(hjust=0.5, family = 'NanumGothicExtraBold', size = 14),
        axis.title = element_text(family = 'NanumGothicExtraBold', size = 11),
        panel.grid.major = element_line(colour = "white", size = 0.2),
        panel.grid.minor = element_blank()) +
  ylim(c(0,100))
  
  

### ����� �� ������(���� + ����)
suggest %>%
  filter(AGE >= 16, AGE != 21) %>%
  filter(PROC_RESULT == '��������' | PROC_RESULT == '���Ȱ���') %>%
  group_by(AGE) %>%
  summarise(����� = n()) -> age_success_total 

#### �뺰 �����(����+����)
success_df <- inner_join(age_total, age_success_total, by = 'AGE')
success_df %>%
  ggplot(aes(x = AGE, y = �����)) +
  geom_bar(stat='identity', fill = '#7CAE00', color = 'black') +
  geom_text(aes(label=�����), vjust=1.5, colour="black") +
  theme_bw()

#### �뺰 ������(����+����)
success_df %>%
  mutate(����_���� = (����� / ���ȹ��Ǽ�) *100) %>%
  ggplot(aes(x = AGE, y = ����_����)) +
  geom_bar(stat = 'identity', fill = '#7CAE00', color = 'black') +
  geom_text(aes(label= paste0(round(����_����, 1), "%")), vjust=1.5, colour="black") +
  ylim(c(0,100)) +
  theme_bw()

### ��ȹݿ� �� ��ȹݿ���
### ��ȹݿ��� ��Ⱑ �ƴ϶� �̹� ����� ���̳� ��ü�� �� �ִ� ���� �����Ƿ� �� ������ ����,�߰��Ͽ� ��ü�ϴ� ���̹Ƿ� ���� ���� �и�
suggest %>%
  filter(AGE >= 16, AGE != 21) %>%
  filter(PROC_RESULT == '��ȹݿ����') %>%
  group_by(AGE) %>%
  summarise(��ȹݿ��� = n()) -> age_alter_total 

alter_df <- inner_join(age_total, age_alter_total, by = 'AGE')
#### ��ȹݿ���
alter_df %>%
  ggplot(aes(x = AGE, y = ��ȹݿ���)) +
  geom_bar(stat='identity', fill = "#619CFF" , color = 'black') +
  geom_text(aes(label= ��ȹݿ���), vjust=1.5, colour="black") +
  theme_bw()
### ��ȹݿ���
alter_df %>%
  mutate(��ȹݿ�_���� = (��ȹݿ��� / ���ȹ��Ǽ�) *100) %>%
  ggplot(aes(x = AGE, y = ��ȹݿ�_����)) +
  geom_bar(stat = 'identity', fill = "#619CFF", color = 'black') +
  geom_text(aes(label= paste0(round(��ȹݿ�_����, 1), "%")), vjust=1.5, colour="black") +
  ylim(c(0,100)) +
  theme_bw()

### �� ����ó����� ������ ���̺�
df <- inner_join(trash_df, success_df, by = c('AGE', '���ȹ��Ǽ�'))
age_df <- inner_join(df, alter_df,  by = c('AGE', '���ȹ��Ǽ�'))
age_df %>%
  mutate(����� = ���� / ���ȹ��Ǽ�,
            ������ = ����� / ���ȹ��Ǽ�,
            ��ȹݿ��� = ��ȹݿ��� / ���ȹ��Ǽ�) -> age_df
age_df

### �� ���, ����, ��ȹݿ��� �� ���� ��
melt_age_df2 <- melt(age_df, id.vars = 'AGE', measure.vars = c('����','�����','��ȹݿ���'))
melt_age_df2 %>%
  ggplot(aes(x = AGE, y =value, fill = variable)) +
  geom_bar(stat='identity', positio = 'dodge')

melt_age_df <- melt(age_df, id.vars = 'AGE', measure.vars = c('�����','������','��ȹݿ���'))
melt_age_df %>%
  ggplot(aes(x = AGE, y = value, fill = variable)) +
  geom_bar(stat='identity', position = 'fill') +
  scale_y_continuous(labels = percent)

### 20���ǿ� �� � �ǿ��� ���, ����, ��ȹݿ��� ���� �ߴ���, �� ��ǥ�ǿ��� �������� �ǿ��� ��Ʈ��ũ �ð�ȭ
#### ��ü ������ 20���ǿ��� ���Ǹ� ����
suggest %>%
  filter(AGE == 20) -> suggest_age20

### 20���ǿ� ����ó�����
suggest_age20 %>%
  group_by(PROC_RESULT) %>%
  summarise(n = n()) %>% 
  ggplot(aes(x = reorder(PROC_RESULT, n), y= n))+
  geom_bar(stat='identity') + 
  theme_bw() +
  coord_flip()

### 20���ǿ� �� ���� TOP10
suggest_age20 %>%
  group_by(RST_PROPOSER) %>%
  summarise(n = n()) %>%
  arrange(desc(n)) %>%  head(10) %>%
  ggplot(aes(x = reorder(RST_PROPOSER, n), y = n)) +
  geom_bar(stat='identity') + 
  coord_flip() + theme_bw()

suggest_age20 %>%
  group_by(PROC_RESULT) %>%
  summarise(n = n())
### ���,����,��ȹݿ��� ����
suggest_age20 %>%
  filter(PROC_RESULT == '�ӱ⸸�����'|PROC_RESULT == '�����ȹݿ����' | 
           PROC_RESULT == '��������' | PROC_RESULT == '���Ȱ���' | PROC_RESULT == '��ȹݿ����') %>%
  select(PROC_RESULT, RST_PROPOSER, PUBL_PROPOSER) -> age20_result_proposer

## ���� �ӱ⸸�����, ��ȹ��, ����(����+����) ��Ʈ��ũ �ð�ȭ
### �ӱ⸸����⸸ ����
age20_result_proposer %>%
  filter(PROC_RESULT == '�ӱ⸸�����') -> age20_trash_df

### �ӱ⸸����� TOP10 �ð�ȭ
age20_trash_df %>%
  group_by(RST_PROPOSER) %>%
  summarise(�ӱ⸸������ = n()) %>% 
  arrange(desc(�ӱ⸸������)) %>%
  head(10) %>% 
  ggplot(aes(x = reorder(RST_PROPOSER, �ӱ⸸������), y = �ӱ⸸������)) +
  geom_bar(stat='identity') + 
  coord_flip() + theme_bw() +
  xlab('��ǥ������')

### ��ȹݿ��� ����
age20_result_proposer %>%
  filter(PROC_RESULT == '��ȹݿ����') -> age20_alter_df

### ��ȹݿ� TOP10 �ð�ȭ
age20_alter_df %>%
  group_by(RST_PROPOSER) %>%
  summarise(n = n()) %>% 
  arrange(desc(n)) %>%
  head(10) %>% 
  ggplot(aes(x = reorder(RST_PROPOSER, n), y = n)) +
  geom_bar(stat='identity') + 
  coord_flip() + theme_bw()

### ����(����+����)�� ����
age20_result_proposer %>%
  filter(PROC_RESULT == '��������'|PROC_RESULT == '����') -> age20_success_df

### ���� TOP10 �ð�ȭ
age20_success_df %>%
  group_by(RST_PROPOSER) %>%
  summarise(n = n()) %>% 
  arrange(desc(n)) %>%
  head(10) %>% 
  ggplot(aes(x = reorder(RST_PROPOSER, n), y = n)) +
  geom_bar(stat='identity') + 
  coord_flip() + theme_bw()

### ��ȹݿ��� ���� ���� �߰� ������ ���� ���� �ߴ°�?
#### ��ü�� ���캸�⿣ �����Ͱ� ũ�� �����ؼ� TOP5�� �̾Ƽ� ���캽
age20_alter_df %>%
  group_by(RST_PROPOSER) %>%
  summarise(n = n()) %>% 
  arrange(desc(n)) %>%
  head(5) -> alter_index

top5_alter_proposer <- age20_alter_df[age20_alter_df$RST_PROPOSER %in% alter_index$RST_PROPOSER,]
top5_alter_proposer %>%
  group_by(RST_PROPOSER) %>%
  summarise(n = n()) %>% arrange(desc(n))

age20_alter_split <- data.frame(RST_PROPOSER = top5_alter_proposer $RST_PROPOSER, 
                                   str_split(top5_alter_proposer $PUBL_PROPOSER, ",",  simplify = TRUE))
age20_alter_split[age20_alter_split == ""] <- NA

tmp <- data.frame()
test <- data.frame()
for(i in 1:dim(age20_alter_split)[1]){
  print(i)
  tmp <- data.frame()
  for(j in 2:dim(age20_alter_split)[2]){
    if(!is.na(age20_alter_split[i, j])){
      tmp[j-1, 1] = paste0(age20_alter_split[i, 1], ',', age20_alter_split[i, j])
    }
  }
  test <- rbind(test, tmp)
}
# View(test)
age20_alter_net <- test
alter_from_to <- data.frame(str_split(age20_alter_net$V1, ",",  simplify = TRUE))
colnames(alter_from_to) <- c('from','to')

alter_from_to %>%
  group_by(from, to) %>%
  summarise(n = n()) %>%
  arrange(desc(n)) -> alter_network

library(igraph)
library(networkD3)
library(ggraph)
library(network)
library(sna)
G <- graph_from_data_frame(alter_network, directed = FALSE);
E(G) # ��������
V(G) # �������
l = layout_with_fr(G) # layout
plot(G,
     vertex.label.dist=0,
     vertex.shape='circle',
     vertex.size = igraph::degree(G, v =V(G), mode = 'all') / 3, #���Ἲ�߽����� ���� ũ�� (�����ʿ�)
     edge.width = E(G)$n / mean(E(G)$n), #������ �ʿ䰡 ����
     edge.color="orange",
     edge.arrow.size=1,
     edge.curved=.3,
     vertex.label.cex = .5,
     main="Top5 ��ȹݿ� - ��ǥ������",
     layout = l) 

nodes <- data.frame(node = (V(G)$name)) 
size <- data.frame(size = igraph::degree(G, v =V(G), mode = 'all')); 
rownames(size) <- 1:dim(size)[1]
nodes <- bind_cols(nodes,size)
nodes$node <- factor(nodes$node, levels=nodes$node)
nodes$idx <- 1:dim(nodes)[1]

# ��ũ ������ ����
links <- data.frame(from = as.numeric(as.factor(alter_network$from))-1,
                    to = as.numeric(as.factor(alter_network$to))-1,
                    width = alter_network$n)
str(links)

# �ð�ȭ
forceNetwork(Nodes = nodes, Links = links,  Source = 'from', Target = 'to',
             NodeID = 'node', Group = 'node',
             zoom = TRUE, fontSize = 20,
             Nodesize = 'size',
             linkDistance = 200, 
             radiusCalculation = JS("d.nodesize + 30 "),
             Value = 'width', 
             linkWidth = JS("function(d) { return Math.sqrt(d.value); }"),
             opacity = 0.8, opacityNoHover = TRUE,
             charge=-900, fontFamily = 'NanumGothic Bold')

