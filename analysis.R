# analisis

# paquetes ####
library(ggplot2)
library(tidyverse)
library(pheatmap)
library(broom)
library(skimr)
library(gtsummary)
library(ggfortify)


# cargar ddatos ####

feno=readRDS("data/feno.RDS")
exp=readRDS("data/exp.RDS")
exp_top=readRDS("data/exp_top.RDS")


# explirar datos ####

# Inspect feno and exp
dim(exp)
dim(exp_top)


# tambien podes expirar la opcion de glimpse
# glimpse(feno)
# glimpse(exp)



# en este caso vamos a usar la informaciond expresion con los gees como colunas, y vamos a sacar las columnas qe tienen todos ceros. Tambien vamos usar solo las muestras provenientes de tumor y no de tejino normal

exp=t(exp)
exp <- exp[, colSums(exp != 0) > 0]


# filtrr y quedarme solo con muetras tumor
feno=feno %>% filter(sample_type=="Primary Tumor")
# feno=feno %>% select(-sample_type, -is_ffpe)
exp=exp[rownames(feno),]
exp_top=exp_top[rownames(feno),]

# 
feno$ISUP_group=factor(feno$ISUP_group, ordered = T)

feno <- droplevels(feno)

# tabla resumen de los datos
feno %>%
  tbl_summary(
    # by = sample_type,  # opcional, si tenés una variable como "tumor vs normal"
    statistic = list(all_continuous() ~ "{mean} ({sd})",
                     all_categorical() ~ "{n} ({p}%)"),
    digits = all_continuous() ~ 2
  ) 

# agrego una columna que despues voy a usar
feno$ISUP_group_num=as.numeric(feno$ISUP_group)


# clsutering no supervisado ####
## Clustering jerarquico con heatmap ####
# vamos a usar la tabla exo_top para reducir el nro de features
# basico

pheatmap(t(exp_top), show_rownames = F, show_colnames = F, scale = "row")

# con anotacione

anotaciones=data.frame(feno %>% 
                         select(ISUP_group,
                                ISUP_group_num,
                                histological_type, 
                                clinical_T_simple, 
                                pathologic_T_simple, 
                                initial_pathologic_diagnosis_method))

pheatmap(t(exp_top),
         scale = "row",
         annotation=anotaciones, show_rownames = F, show_colnames = F)


# Visualización con PCA, aca usamos todos los datos

# visualizacion basica
pca <- prcomp(exp, scale. = TRUE)
autoplot(pca)


# visualizacion coloreada por una covariable
colnames(feno)
autoplot(pca, data = feno, colour = "ISUP_group")
autoplot(pca, data = feno, colour = "age")




## k-means clustering ####

set.seed(123)

# K-means , en este caaso 5, pero es arbitrario
km <- kmeans(exp_top, centers = 5, nstart = 25)
feno$cluster_kmeans <- factor(km$cluster)
autoplot(pca, data = feno, colour = "cluster_kmeans") # aca estoy extrapolando, ojo


## reduccion de dimensionalidad ####

# t-SNE
library(Rtsne)
set.seed(123)
tsne <- Rtsne(exp, perplexity = 30)
plot(tsne$Y)

# Visualización
plot(tsne$Y, col = km$cluster, pch = 19, main = "t-SNE + K-means")
plot(tsne$Y, col = feno$ISUP_group, pch = 19)


# ver si hay asosiacion con caracteristicas clinicas

# Por ejemplo, evaluar si hay diferencias en PSA preoperatorio entre clusters
boxplot(feno$PSA ~ feno$cluster_kmeans,
        xlab = "Cluster K-means", ylab = "PSA preop")




## Bonus ####
### determinar nro optimo de clusters ####

# Elbow method
wss <- sapply(1:10, function(k){
  kmeans(exp, centers = k, nstart = 10)$tot.withinss
})
plot(1:10, wss, type = "b", main = "Elbow Method")

# Silhouette
library(cluster)
sil <- silhouette(km$cluster, dist(mat_top))
plot(sil)



### explorando variables ####
pruebas=feno %>% select(-sample_type, -is_ffpe, -cluster_kmeans)
rta=feno$cluster_kmeans

for(i in 1:ncol(pruebas)){
  ajuste=glm(rta~pruebas[,i], data = , family = "binomial")
  print(colnames(pruebas)[i])
  print(tidy(ajuste, exponentiate = F))
}

print(summary(ajuste))

tidy(ajuste, exponentiate = F, )


# clustering supervisado y clasificacion ####


library(caret)           # ML infrastructure (data split, model train, etc.)
library(randomForest)    # Random Forest algorithm
library(pROC)            # ROC curves
library(e1071)           # Required by caret





# Supervised Learning: Predicting progression



X <- exp_top                               # expression matrix as features
y <- factor(as.numeric(feno$progression))                  # outcome variable

# ----- 3.2 Train/Test Split -----
set.seed(123)
train_index <- createDataPartition(y, p = 0.7, list = FALSE)
X_train <- X[train_index, ]
X_test  <- X[-train_index, ]
y_train <- y[train_index]
y_test  <- y[-train_index]

# ----- 3.3 Logistic Regression (if binary classification) -----
model_logit <- train(
  x = X_train,
  y = y_train,
  method = "glm",
  family = "binomial",
  trControl = trainControl(method = "cv", number = 5)
)

# Predict and evaluate
pred_logit <- predict(model_logit, newdata = X_test)
confusionMatrix(pred_logit, y_test)

# ----- 3.4 Random Forest -----
model_rf <- train(
  x = X_train,
  y = y_train,
  method = "rf",
  trControl = trainControl(method = "cv", number = 5),
  importance = TRUE
)

# Predict and evaluate
pred_rf <- predict(model_rf, newdata = X_test)
confusionMatrix(pred_rf, y_test)

# Variable importance
varImpPlot(model_rf$finalModel, main = "Random Forest - sample_type")

# ROC Curve (if binary)
if (length(levels(y_test)) == 2) {
  prob_rf <- predict(model_rf, newdata = X_test, type = "prob")[, 2]
  roc_rf <- roc(response = y_test, predictor = prob_rf)
  plot(roc_rf, col = "blue", main = "ROC Curve - Random Forest")
  auc(roc_rf)
}

# ----------------------------
# 4. Supervised Learning: Predicting ISUP Grade
# ----------------------------

# ----- 4.1 Define new target -----
y_isup <- feno$ISUP
train_index2 <- createDataPartition(y_isup, p = 0.7, list = FALSE)
X_train2 <- X[train_index2, ]
X_test2  <- X[-train_index2, ]
y_train2 <- y_isup[train_index2]
y_test2  <- y_isup[-train_index2]

# ----- 4.2 Random Forest for ISUP -----
model_rf_isup <- train(
  x = X_train2,
  y = y_train2,
  method = "rf",
  trControl = trainControl(method = "cv", number = 5),
  importance = TRUE
)

# Predict and evaluate
pred_rf_isup <- predict(model_rf_isup, newdata = X_test2)
confusionMatrix(pred_rf_isup, y_test2)

# Variable importance
varImpPlot(model_rf_isup$finalModel, main = "Random Forest - ISUP grade")

# ----------------------------
# 5. Summary Table of Sample Type vs ISUP
# ----------------------------
feno %>%
  select(sample_type, ISUP) %>%
  tbl_summary(by = sample_type) %>%
  add_p() %>%
  bold_labels()

# ----------------------------
# 6. Optional: Save models
# ----------------------------
saveRDS(model_rf, "model_rf_sample_type.rds")
saveRDS(model_rf_isup, "model_rf_isup.rds")

