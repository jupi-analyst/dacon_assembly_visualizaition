getwd()
setwd('~/sh_R/open')
library(tidyverse)
library(extrafont)
loadfonts()
suggest <- read_csv('open/suggest.csv')

# ��Ʈ��ũ �м� ��ó��
library(tidygraph)

# 21���ǿ� ��ǥ�����ڿ� ���������� ����
sug_proposer <- suggest %>% 
  filter(AGE == 20) %>%
  group_by(RST_PROPOSER) %>%
  select(RST_PROPOSER, PUBL_PROPOSER)

# ���� �Ǽ� ���� 5�� ����
sug_proposer %>%
  group_by(RST_PROPOSER) %>%
  summarise(n = n()) %>%
  arrange(desc(n)) %>% head(5) -> df_index
df_index

# ���� 5���� ��ǥ�����ڿ� ���������� 
top5_proposer <- sug_proposer[sug_proposer$RST_PROPOSER %in% df_index$RST_PROPOSER,]
top5_proposer %>%
  group_by(RST_PROPOSER) %>%
  summarise(n = n()) %>% arrange(desc(n))

# ��ǥ�����ڿ� ������������ ���踦 ǥ���ϱ� ���� �ϳ��� ����
top10_proposer_split <- data.frame(RST_PROPOSER = top10_proposer$RST_PROPOSER, 
                                   str_split(top10_proposer$PUBL_PROPOSER, ",",  simplify = TRUE))
top10_proposer_split[top10_proposer_split == ""] <- NA
# top10_proposer_split %>%
#   group_by(RST_PROPOSER) %>%
#   summarise(n = n()) %>% arrange(desc(n))

test <- data.frame()
for(i in 1:dim(top10_proposer_split)[1]){
  print(i)
  tmp <- data.frame()
  for(j in 2:dim(top10_proposer_split)[2]){
    if(!is.na(top10_proposer_split[i, j])){
      tmp[j-1, 1] = paste0(top10_proposer_split[i, 1], ',', top10_proposer_split[i, j])
    }
  }
  test <- rbind(test, tmp)
}
# saveRDS(test, 'test.rds')
# test <- readRDS('test.rds')

proposer_net <- test
rm(test); rm(tmp)
proposer_from_to <- data.frame(str_split(proposer_net$V1, ",",  simplify = TRUE))
colnames(proposer_from_to) <- c('from','to')

# ��ǥ, ���������ں� ���� ��
proposer_network <- proposer_from_to %>%
  mutate(from = factor(from)) %>%
  group_by(from, to) %>%
  summarise(n = n()) %>% arrange(desc(n))

# # �� ��ǥ�������� ���� ��
# proposer_from_to %>%
#   mutate(from = factor(from)) %>%
#   group_by(from) %>%
#   summarise(n = n()) %>% arrange(desc(n)) %>% 
#   ggplot(aes(x = from, y = n)) +
#   geom_bar(stat='identity')


# --------------------------------------------------------------------------------------------------

# ��Ʈ��ũ �ð�ȭ
library(igraph)
library(networkD3)
library(ggraph)
library(network)
library(sna)

G <- network(proposer_network,matrix.type="edgelist")
class(G)
gplot(G, vertex.col = 2, displaylabels = TRUE, main="��������Ʈ(Edgelist)")

G <- graph_from_data_frame(proposer_network, directed = FALSE);
E(G) # ��������
V(G) # �������
plot(G)
# test <- data.frame(shortest.paths(G)) #�ִܰ��

l = layout_with_fr(G)
plot(G,
     vertex.label.dist=0,
     vertex.shape='circle',
     vertex.size = igraph::degree(G, v =V(G), mode = 'all') / 5, #���Ἲ�߽����� ���� ũ��
     edge.width = E(G)$n / mean(E(G)$n), #������ �ʿ䰡 ����
     edge.color="orange",
     edge.arrow.size=1,
     edge.curved=.3,
     vertex.label.cex = 1.2,
     main="Top5 ��ǥ������",
     layout = l) 

# ���� �߽ɼ�
degree(G)
degree(G, mode = 'in')
degree(G, mode = 'out')

eccentricity(G)
eccentricity(G, mode = 'in')
eccentricity(G, mode = 'out')

central.df <- data.frame(degree = degree(G) / (length(names(v)) - 1),
                         between = betweenness(G),
                         close = closeness(G, normalized = T))
central.df %>% arrange(desc(degree))

# ��ġ �˰�����
l <- layout.fruchterman.reingold(G)
l <- layout.norm(l, ymin=-1, ymax=1, xmin=-1, xmax=1)
l <- layout.fruchterman.reingold(G)
l <- layout.kamada.kawai(G)
plot(G, layout = l)

# �Ϲݱ׷���
proposer_network %>% 
  select(-n) %>%
  as_tbl_graph(directed = FALSE) %>%
  ggraph() +
    geom_edge_link() +
    geom_node_point() +
    geom_node_text(aes(label = name))


# �����߽ɼ��� ������ �׷���
proposer_network %>%
  as_tbl_graph(directed = FALSE) %>%
  mutate(degree = centrality_degree(),
         group = group_infomap())%>%
  ggraph(layout = l) +
  geom_edge_link(color='gray50', ) +
  geom_node_point(aes(size=degree, color=factor(group))) +
  geom_node_text(aes(label=name), size=3)

# ���� ���� �׷���
proposer_network %>%
  as_tbl_graph(directed=FALSE) %>%
  activate(nodes) %>%
  mutate(eigen = centrality_eigen(),
         group = group_infomap()) %>%
  ggraph(layout= 'kk') +
  geom_edge_link(color='gray50', alpha=.2) +
  geom_node_point(aes(color=factor(group), size=eigen^2)) +
  geom_node_text(aes(label=name), size=3, repel=TRUE) +
  theme_graph() +
  theme(legend.position='none')

# ������ ���� �׷���
proposer_network %>%
  as_tbl_graph(directed=FALSE) %>%
  activate(nodes) %>%
  mutate(eig = centrality_pagerank(weights = n),
         group = group_infomap()) %>%
  ggraph(layout= 'kk') +
  geom_edge_link(aes(width = n / 2), color='gray50', alpha=.5) +
  geom_node_point(aes(color=factor(group), size=eig)) +
  geom_node_text(aes(label=name), size=3, repel=TRUE) +
  theme_graph() +
  theme(legend.position='none')

G <- graph_from_data_frame(proposer_network, directed = TRUE);
E(G) # ��������
V(G) # �������
vertex_attr(G)
edge_attr(G)

library(extrafont)
font_import()
### �߿����� ���� ���ἱ ����
G_edge_sng <- igraph::delete_edges(G, E(G)[[n >= 10]])
plot(G_edge_sng, 
     layout = l,
     vertex.size = igraph::eigen_centrality(G_edge_sng, directed = FALSE)$vector * 25,
     vertex.label = V(G_edge_sng)$name, 
     vertex.label.color = "black",
     vertex.label.cex = 0.7,
     vertex.label.family="D2Coding",
     edge.width = E(G_edge_sng)$n / 2.5,
     edge.color = 'black',
     edge.curved=TRUE,
     edge.arrow.size = .05)

proposer_network
simpleNetwork(proposer_network)
simpleNetwork(proposer_network, height="100px", width="100px",        
              Source = 1,                 # column number of source
              Target = 2,                 # column number of target
              linkDistance = 5,          # distance between node. Increase this value to have more space between nodes
              charge = -900,                # numeric value indicating either the strength of the node repulsion (negative value) or attraction (positive value)
              fontSize = 10,               # size of the node names
              fontFamily = "serif",       # font og node names
              linkColour = "#666",        # colour of edges, MUST be a common colour for the whole graph
              nodeColour = "#69b3a2",     # colour of nodes, MUST be a common colour for the whole graph
              opacity = 0.9,              # opacity of nodes. 0=transparent. 1=no transparency
              zoom = T                    # Can you zoom on the figure?
)

G<- graph_from_data_frame(proposer_network, directed = FALSE)
V(G) # 310���� ��ũ
E(G) # 146���� ���
str(V(G))

nodes <- data.frame(node = (V(G)$name)) 
size <- data.frame(size = igraph::degree(G, v =V(G), mode = 'all')); rownames(size) <- 1:dim(size)[1]
nodes <- bind_cols(nodes,size)
nodes$node <- factor(nodes$node, levels=nodes$node)
nodes$idx <- 1:dim(nodes)[1]
str(nodes)

links <- data.frame(from = as.numeric(as.factor(proposer_network$from))-1,
                    to = as.numeric(as.factor(proposer_network$to))-1,
                    width = proposer_network$n)
str(links)
forceNetwork(Nodes = nodes, Links = links,  Source = 'from', Target = 'to',
             NodeID = 'node', Group = 'node',
             zoom = TRUE, fontSize = 20,
             Nodesize = 'size',
             linkDistance = 200, radiusCalculation = JS("d.nodesize+10"),
             Value = 'width', linkWidth = JS("function(d) { return Math.sqrt(d.value) - 3; }"),
             opacity = 0.7, opacityNoHover = TRUE,
             charge=-900, fontFamily = 'NanuGothic Bold')
# n���ǿ� ���Ǽ� Top5 ��ǥ�����ڿ� ���� ���������� ��Ʈ��ũ �м�


# ---------------------------------�Լ�ȭ------------------------------
proposer_top5 <- function(age){
  sug_proposer <- suggest %>% 
    filter(AGE == age) %>%
    group_by(RST_PROPOSER) %>%
    select(RST_PROPOSER, PUBL_PROPOSER)
  
  # ���� �Ǽ� ���� 10�� ����
  sug_proposer %>%
    group_by(RST_PROPOSER) %>%
    summarise(n = n()) %>%
    arrange(desc(n)) %>% head(5) -> df_index
  
  # ���� 10���� ��ǥ�����ڿ� ���������� 
  top5_proposer <- sug_proposer[sug_proposer$RST_PROPOSER %in% df_index$RST_PROPOSER,]
  top5_proposer %>%
    group_by(RST_PROPOSER) %>%
    summarise(n = n()) %>% arrange(desc(n))
  
  # ��ǥ�����ڿ� ������������ ���踦 ǥ���ϱ� ���� �ϳ��� ����
  top5_proposer_split <- data.frame(RST_PROPOSER = top5_proposer$RST_PROPOSER, 
                                     str_split(top5_proposer$PUBL_PROPOSER, ",",  simplify = TRUE))
  top5_proposer_split[top5_proposer_split == ""] <- NA
  # top10_proposer_split %>%
  #   group_by(RST_PROPOSER) %>%
  #   summarise(n = n()) %>% arrange(desc(n))
  
  test <- data.frame()
  for(i in 1:dim(top5_proposer_split)[1]){
    print(i)
    tmp <- data.frame()
    for(j in 2:dim(top5_proposer_split)[2]){
      if(!is.na(top5_proposer_split[i, j])){
        tmp[j-1, 1] = paste0(top5_proposer_split[i, 1], ',', top5_proposer_split[i, j])
      }
    }
    test <- rbind(test, tmp)
  }
  
  proposer_net <- test
  rm(test); rm(tmp)
  proposer_from_to <- data.frame(str_split(proposer_net$V1, ",",  simplify = TRUE))
  colnames(proposer_from_to) <- c('from','to')
  
  # ��ǥ, ���������ں� ���� ��
  proposer_from_to %>%
    group_by(from, to) %>%
    summarise(n = n()) %>% arrange(desc(n))

  # �� ��ǥ�������� ���� ��
  proposer_from_to %>%
    mutate(from = factor(from)) %>%
    group_by(from) %>%
    summarise(n = n()) %>% arrange(desc(n)) %>%
    ggplot(aes(x = from, y = n)) +
    geom_bar(stat='identity')
  
  # ��ǥ, ���������ں� ���� ��
  proposer_network <- proposer_from_to %>%
    mutate(from = factor(from)) %>%
    group_by(from, to) %>%
    summarise(n = n()) %>% arrange(desc(n))
  
  # ������ �������� igraph�� ����
  G <- graph_from_data_frame(proposer_network, directed = FALSE)
  
  # ��Ʈ ������ ����
  nodes <- data.frame(node = (V(G)$name)) 
  size <- data.frame(size = igraph::degree(G, v =V(G), mode = 'all')); rownames(size) <- 1:dim(size)[1]
  nodes <- bind_cols(nodes,size)
  nodes$node <- factor(nodes$node, levels=nodes$node)
  nodes$idx <- 1:dim(nodes)[1]
  
  # ��ũ ������ ����
  links <- data.frame(from = as.numeric(as.factor(proposer_network$from))-1,
                      to = as.numeric(as.factor(proposer_network$to))-1,
                      width = proposer_network$n)
  str(links)
  
  # �ð�ȭ
  forceNetwork(Nodes = nodes, Links = links,  Source = 'from', Target = 'to',
               NodeID = 'node', Group = 'node',
               zoom = TRUE, fontSize = 20,
               Nodesize = 'size',
               linkDistance = 200, radiusCalculation = JS("d.nodesize+10"),
               Value = 'width', linkWidth = JS("function(d) { return Math.sqrt(d.value) - 3; }"),
               opacity = 0.6, opacityNoHover = TRUE,
               charge=-900, fontFamily = 'NanuGothic') -> plot
  
  return(plot)
}
proposer_top5('20')

# ��ǥ������ �������� ���������� ��(BAR)
suggest_network_count <- function(name){
  # 21���ǿ� ��ǥ�����ڿ� ���������� ����
  sug_proposer <- suggest %>% 
    filter(AGE == 21) %>%
    group_by(RST_PROPOSER) %>%
    select(RST_PROPOSER, PUBL_PROPOSER)
  
  # ã�� �ִ� ��ǥ������ �μ�
  sug_proposer %>%
    filter(RST_PROPOSER == name) -> proposer_tmp
  
  # ���������ڸ� �Ѹ��� �и�
  proposer_tmp_split <- data.frame(RST_PROPOSER = proposer_tmp$RST_PROPOSER, 
                                   str_split(proposer_tmp$PUBL_PROPOSER, ",",  simplify = TRUE))
  proposer_tmp_split[proposer_tmp_split == ""] <- NA
  # top10_proposer_split %>%
  #   group_by(RST_PROPOSER) %>%
  #   summarise(n = n()) %>% arrange(desc(n))
  
  tmp <- data.frame()
  test <- data.frame()
  for(i in 1:dim(proposer_tmp_split)[1]){
    tmp <- data.frame()
    for(j in 2:dim(proposer_tmp_split)[2]){
      if(!is.na(proposer_tmp_split[i, j])){
        tmp[j-1, 1] = paste0(proposer_tmp_split[i, 1], ',', proposer_tmp_split[i, j])
      }
    }
    test <- rbind(test, tmp)
  }
  RST_proposer <- test
  rm(test); rm(tmp)
  RST_proposer <- data.frame(str_split(RST_proposer$V1, ",",  simplify = TRUE))
  colnames(RST_proposer) <- c('from','to')
  
  RST_proposer %>%
    mutate(from = factor(from)) %>%
    group_by(from, to) %>%
    summarise(n = n()) %>% 
    arrange(desc(n)) -> RST_proposer_network
  
  RST_proposer_network %>%
    filter(n >= 5) %>%
    ggplot(aes(x = reorder(paste(from, '-', to), n) , y = n)) +
    geom_bar(stat= 'identity',fill='steelblue') +
    coord_flip() +
    theme_bw() +
    ylab('���Ǽ�') +
    xlab('��ǥ-����') +
    theme(axis.title=element_text(size=15, face ='bold'))
}
suggest_network_count('����ȣ')

# ���ͷ�Ƽ�� ��Ʈ��ũ
suggest_network <- function(name) {
  # 21���ǿ� ��ǥ�����ڿ� ���������� ����
  sug_proposer <- suggest %>% 
    filter(AGE == 21) %>%
    group_by(RST_PROPOSER) %>%
    select(RST_PROPOSER, PUBL_PROPOSER)
  
  # ã�� �ִ� ��ǥ������ �μ�
  sug_proposer %>%
    filter(RST_PROPOSER == name) -> proposer_tmp
  
  # ���������ڸ� �Ѹ��� �и�
  proposer_tmp_split <- data.frame(RST_PROPOSER = proposer_tmp$RST_PROPOSER, 
                                     str_split(proposer_tmp$PUBL_PROPOSER, ",",  simplify = TRUE))
  proposer_tmp_split[proposer_tmp_split == ""] <- NA
  # top10_proposer_split %>%
  #   group_by(RST_PROPOSER) %>%
  #   summarise(n = n()) %>% arrange(desc(n))
  
  tmp <- data.frame()
  test <- data.frame()
  for(i in 1:dim(proposer_tmp_split)[1]){
    tmp <- data.frame()
    for(j in 2:dim(proposer_tmp_split)[2]){
      if(!is.na(proposer_tmp_split[i, j])){
        tmp[j-1, 1] = paste0(proposer_tmp_split[i, 1], ',', proposer_tmp_split[i, j])
      }
    }
    test <- rbind(test, tmp)
  }
  RST_proposer <- test
  rm(test); rm(tmp)
  RST_proposer <- data.frame(str_split(RST_proposer$V1, ",",  simplify = TRUE))
  colnames(RST_proposer) <- c('from','to')
  
  RST_proposer %>%
    mutate(from = factor(from)) %>%
    group_by(from, to) %>%
    summarise(n = n()) %>% 
    arrange(desc(n)) -> RST_proposer_network

  G <- graph_from_data_frame(RST_proposer_network, directed = FALSE);
  # G_edge_sng <- igraph::delete_edges(G, E(G)[[n >= 10]]) # n���̻� ���������� �����
  l = layout_with_fr(G)
  
  ## ���� ��Ʈ��ũ �׷���
  # plot(G,
  #      vertex.label.dist=0,
  #      vertex.shape='circle',
  #      vertex.size = igraph::degree(G, v =V(G), mode = 'all') / 1.7, #���Ἲ�߽����� ���� ũ��
  #      edge.width = E(G)$n / mean(E(G)$n), #������ �ʿ䰡 ����
  #      edge.color="orange",
  #      edge.arrow.size=1,
  #      edge.curved=.3,
  #      vertex.label.cex = 1.2,
  #      main=paste0(name,'�� ����������'),
  #      layout = l) -> plot
  
  # ��Ʈ ������ ����
  nodes <- data.frame(node = (V(G)$name)) 
  size <- data.frame(size = igraph::degree(G, v =V(G), mode = 'all')); rownames(size) <- 1:dim(size)[1]
  nodes <- bind_cols(nodes,size)
  nodes$node <- factor(nodes$node, levels=nodes$node)
  nodes$idx <- 1:dim(nodes)[1]
  
  # ��ũ ������ ����
  links <- data.frame(from = as.numeric(as.factor(RST_proposer_network$from))-1,
                      to = as.numeric(as.factor(RST_proposer_network$to))-1,
                      width = RST_proposer_network$n)
  str(links)
  
  # ���� ��Ʈ��ũ �ð�ȭ
  forceNetwork(Nodes = nodes, Links = links,  Source = 'from', Target = 'to',
               NodeID = 'node', Group = 'node',
               zoom = TRUE, fontSize = 20,
               Nodesize = 'size',
               linkDistance = 200, radiusCalculation = JS("d.nodesize+10"),
               linkColour = c("gray"),
               Value = 'width', linkWidth = JS("function(d) { return Math.sqrt(d.value) - 4; }"),
               opacity = 0.6, opacityNoHover = TRUE,
               charge=-900, fontFamily = 'NanuGothic') -> plot
  
  
  return(plot)
}
suggest_network('����ȣ')