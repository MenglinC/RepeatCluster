library(plyr) #zhongyao
library(AnnotationHub)	
library(org.Hs.eg.db) 
library(clusterProfiler)
library(dplyr)
library(ggplot2)
library(gridExtra)
#BiocManager::install("plyr",force = TRUE)

#setwd("E://2022��٣�2022-06-2022-08��//gene//")
setwd("E://2022��٣�2022-06-2022-08��//Roadmap//")

#data<-read.table("Alu_gene-sybmbol.txt")
#data<-read.table("SVA_gene-sybmbol.txt")
#data<-read.table("L1_gene-sybmbol.txt")
#data<-read.table("LTR_gene-sybmbol.txt")
data<-read.table("brain_active_gene-symbol.txt")
data<-read.table("tissue_common_gene.txt")
interest_gene<-data$V1
f1=interest_gene
EG2Ensembl=toTable(org.Hs.egSYMBOL)	 #��ENTREZID��ENSEMBL��Ӧ�����ݴ���ñ���
#EG2Ensembl=toTable(org.Hs.eg.)
#f=f1$V2
f=f1
geneLists=data.frame(symbol=f)
results=merge(geneLists,EG2Ensembl,by='symbol',all.x=T)
#results=merge(geneLists,EG2Ensembl,by='trans_id',all.x=T)
id=na.omit(results$gene_id)  #��ȡ����NA��ENTREZID #����transid�кܶ�ƥ�䲻��


# ego3<-enrichGO(OrgDb="org.Hs.eg.db", gene = id, ont = "BP") 
# p1<-dotplot(ego3,showCategory=10,title="Enrichment GO Top10(BP)")
# p2<-barplot(ego3, showCategory=20,title="EnrichmentGO(BP)")
# p1
# p2
# ego3<-enrichGO(OrgDb="org.Hs.eg.db", gene = id, ont = "CC") 
# p1<-dotplot(ego3,showCategory=10,title="Enrichment GO Top10(BP)")
# p2<-barplot(ego3, showCategory=20,title="EnrichmentGO(BP)")
# ego3<-enrichGO(OrgDb="org.Hs.eg.db", gene = id, ont = "MF") 
# p1<-dotplot(ego3,showCategory=10,title="Enrichment GO Top10(BP)")
# p2<-barplot(ego3, showCategory=20,title="EnrichmentGO(BP)")



ego_CC <- enrichGO(gene = id,
                   OrgDb=org.Hs.eg.db,
                   keyType = "ENTREZID",
                   ont = "CC",
                   pAdjustMethod = "BH",
                   minGSSize = 1,
                   pvalueCutoff = 0.01,
                   qvalueCutoff = 0.05,
                   readable = TRUE)

ego_BP <- enrichGO(gene = id,
                   OrgDb=org.Hs.eg.db,
                   keyType = "ENTREZID",
                   ont = "BP",
                   pAdjustMethod = "BH",
                   minGSSize = 1,
                   pvalueCutoff = 0.01,
                   qvalueCutoff = 0.05,
                   readable = TRUE)


ego_MF <- enrichGO(gene = id,
                   OrgDb=org.Hs.eg.db,
                   keyType = "ENTREZID",
                   ont = "MF",
                   pAdjustMethod = "BH",
                   minGSSize = 1,
                   pvalueCutoff = 0.01,
                   qvalueCutoff = 0.05,
                   readable = TRUE)

# #LTR �ſ���ֵ
# ego_CC <- enrichGO(gene = id,
#                    OrgDb=org.Hs.eg.db,
#                    keyType = "ENTREZID",
#                    ont = "CC",
#                    pAdjustMethod = "BH",
#                    minGSSize = 1,
#                    pvalueCutoff = 0.1,
#                    qvalueCutoff = 0.1,
#                    readable = TRUE)
# 
# ego_BP <- enrichGO(gene = id,
#                    OrgDb=org.Hs.eg.db,
#                    keyType = "ENTREZID",
#                    ont = "BP",
#                    pAdjustMethod = "BH",
#                    minGSSize = 1,
#                    pvalueCutoff = 0.1,
#                    qvalueCutoff = 0.1,
#                    readable = TRUE)
# 
# ego_MF <- enrichGO(gene = id,
#                    OrgDb=org.Hs.eg.db,
#                    keyType = "ENTREZID",
#                    ont = "MF",
#                    pAdjustMethod = "BH",
#                    minGSSize = 1,
#                    pvalueCutoff = 0.1,
#                    qvalueCutoff = 0.1,
#                    readable = TRUE)



display_number = c(10, 10, 10)#���������ֱַ����ѡȡ��BP��CC��MF��ͨ·����������Լ����þ�����
ego_result_BP <- as.data.frame(ego_BP)[1:display_number[1], ]
ego_result_CC <- as.data.frame(ego_CC)[1:display_number[2], ]
ego_result_MF <- as.data.frame(ego_MF)[1:display_number[3], ]

##����������ժȡ�Ĳ���ͨ·������ϳ����ݿ�
go_enrich_df <- data.frame(
  ID=c(ego_result_BP$ID, ego_result_CC$ID, ego_result_MF$ID),                         Description=c(ego_result_BP$Description,ego_result_CC$Description,ego_result_MF$Description),
  GeneNumber=c(ego_result_BP$Count, ego_result_CC$Count, ego_result_MF$Count),
  type=factor(c(rep("biological process", display_number[1]), 
                rep("cellular component", display_number[2]),
                rep("molecular function", display_number[3])), 
              levels=c("biological process", "cellular component","molecular function" )))

##ͨ·������̫���ˣ���ѡȡ��ͨ·��ǰ���������Ϊͨ·������
# for(i in 1:nrow(go_enrich_df)){
#   description_splite=strsplit(go_enrich_df$Description[i],split = " ")
#   description_collapse=paste(description_splite[[1]][1:8],collapse = " ") #�����5����ָ5�����ʵ���˼�������Լ�����
#   go_enrich_df$Description[i]=description_collapse
#   go_enrich_df$Description=gsub(pattern = "NA","",go_enrich_df$Description)
# }

##��ʼ����GO��״ͼ
###���ŵ���״ͼ
# go_enrich_df$type_order=factor(rev(as.integer(rownames(go_enrich_df))),labels=rev(go_enrich_df$Description))#��һ���Ǳ���ģ�Ϊ�������Ӱ�˳����ʾ�������ں���
# COLS <- c("#66C3A5", "#8DA1CB", "#FD8D62")#�趨��ɫ
# 
# ggplot(data=go_enrich_df, aes(x=type_order,y=GeneNumber, fill=type)) + #������ȡֵ
#   geom_bar(stat="identity", width=0.8) + #��״ͼ�Ŀ��ȣ������Լ�����
#   scale_fill_manual(values = COLS) + ###��ɫ
#   coord_flip() + ##��һ��������״ͼ����������ӵĻ���״ͼ�����ŵ�
#   xlab("GO term") + 
#   ylab("Gene_Number") + 
#   labs(title = "The Most Enriched GO Terms")+
#   theme_bw()

###���ŵ���״ͼ 
go_enrich_df$type_order=factor(rev(as.integer(rownames(go_enrich_df))),labels=rev(go_enrich_df$Description))
library(RColorBrewer)
COLS<-brewer.pal(name="Dark2",3)
#COLS <- c("#FF82AB", "#B3EE3A", "#D8BFD8")
go_enrich_df_2<-na.omit(go_enrich_df)

ggplot(data=go_enrich_df_2, aes(x=type_order,y=GeneNumber, fill=type)) + 
  geom_bar(stat="identity", width=0.8) + 
  scale_fill_manual(values = COLS) + 
  theme_bw() + 
  ylab("")+
  xlab("")+
  theme(axis.text.x=element_text(face = "bold", color="gray50",angle = 70,vjust = 1, hjust = 1 ))+
  coord_flip()+
  labs(title="Tissue Common Geneset Functional Enrichment")+
  theme(plot.title=element_text(hjust=0.5))


p1<-ggplot(data=go_enrich_df_2, aes(x=type_order,y=GeneNumber, fill=type)) + 
    geom_bar(stat="identity", width=0.8) + 
    scale_fill_manual(values = COLS) + 
    theme_bw() + 
    ylab("")+
    xlab("")+
    theme(axis.text.x=element_text(face = "bold", color="gray50",angle = 70,vjust = 1, hjust = 1 ))+
    coord_flip()+
    theme(legend.position = 'none')

p2<-ggplot(data=go_enrich_df_2, aes(x=type_order,y=GeneNumber, fill=type)) + 
  geom_bar(stat="identity", width=0.8) + 
  scale_fill_manual(values = COLS) + 
  theme_bw() + 
  ylab("")+
  xlab("")+
  theme(axis.text.x=element_text(face = "bold", color="gray50",angle = 70,vjust = 1, hjust = 1 ))+
  coord_flip()+
  theme(legend.position = 'none')

library(RColorBrewer)
colors<-brewer.pal(name="Dark2",3)
colors

p3<-ggplot(data=go_enrich_df_2, aes(x=type_order,y=GeneNumber, fill=type)) + 
  geom_bar(stat="identity", width=0.8) + 
  scale_fill_manual(values = colors) + 
  theme_bw() + 
  xlab("Go terms")+
  ylab("gene number")+
  theme(axis.text.x=element_text(face = "bold", color="gray50",angle = 70,vjust = 1, hjust = 1 ))+
  coord_flip()


p4<-ggplot(data=go_enrich_df_2, aes(x=type_order,y=GeneNumber, fill=type)) + 
  geom_bar(stat="identity", width=0.8) + 
  scale_fill_manual(values = COLS) + 
  theme_bw() + 
  ylab("")+
  xlab("")+
  theme(axis.text.x=element_text(face = "bold", color="gray50",angle = 70,vjust = 1, hjust = 1 ))+
  coord_flip()+
  theme(legend.position = 'none')


p5 <- cowplot::plot_grid(p1, p2,p4,p3,ncol = 2,nrow=2,labels = c("Alu","SVA","LTR","L1"))#��p1-p4�ķ�ͼ��ϳ�һ��ͼ�����������������У���ǩ�ֱ�ΪA��B��C��D����LETTERS[1:4] ��Ϊ��ȡ26����дӢ����ĸ��ǰ�ĸ�:A��B��C��D��
p5
