## Clustering

```{r warning=FALSE, results='hide'}
source("G:/My Drive/1.3 Master/Modules/08_Data_mining/Funciones_Clust.R")
paquetes(c("factoextra","cluster","fpc", "clValid"))
```

### Clustering jerárquico

```{r warning=FALSE}
# Lista de métodos de Linkage a comparar
methods <- c("single", "complete", "average", "mcquitty", "ward.D2")
```

```{r warning=FALSE}
# Genero un bucle para recorrerla, ajustar modelos y pedir información
hclist <- list()
val.hc<-c()
for(i in seq_along(methods)) {
  hc <- hclust(dist(elec_r), method = methods[i]) 
  hclist[[i]]<-hc # Lista de modelos jerárquicos
  #Visualización
  print(fviz_dend(hc, k = 4, cex = 0.5, color_labels_by_k = T, rect = T)+ggtitle(paste('Linkage ', methods[i])))
  #Validación interna
  cl<-cutree(hc, k = 4) 
  md.val<-medidasVal(elec_r,cl,cl,methods[i])
  
  # Generar vector de vmedidas de validación
  val.hc<- rbind(val.hc,md.val)#Podemos seleccionar otras medidas en la función medidasVal()
}
names(hclist) <- rownames(val.hc)<-methods # Pongo nombres a los objetos creados
```

```{r warning=FALSE}
# Validación Interna
dotchart(val.hc[,4], #xlim = c(0.7,1),
         xlab = "wss", main = "Whithin ss",pch = 19)
dotchart(val.hc[,3], #xlim = c(0.7,1),
         xlab = "shi", main = "silhouette",pch = 19)
```

Vemos que según el Whithin ss el mejor método es el ward.D2 seguido muy de cerca del complete. En cambio, el Silhouette, el single es que mayor puntuación presenta, seguido de complete y ward.D2. Por consistencia vemos que los mejores métodos son ward.D2 y complete.

```{r warning=FALSE}
### Comparación con K-means
km.out=kmeans(elec_r,4,nstart=50)
fviz_cluster(km.out, data = elec_r,  ellipse.type = "convex", palette = "jco",repel = TRUE,
             ggtheme = theme_minimal())
```

```{r warning=FALSE}
#Calculo las medidas de validación
med.km<-medidasVal(elec_r,km.out$clus,km.out$clus,'K-means')
valT<-rbind(val.hc,med.km)
valT
```

Vemos que med.km (kmeans) consigue muy buenos resultados.

```{r warning=FALSE}
# Intentamos unir fuerzas con método híbrido 
hk.out=hkmeans(elec_r,4)
hkmeans_tree(hk.out, cex = 0.6)
fviz_cluster(hk.out, data = puntos,  ellipse.type = "convex", palette = "jco",repel = TRUE,
             ggtheme = theme_minimal())
med.hk<-medidasVal(elec_r,hk.out$cluster,hk.out$cluster,'K-means')
```

```{r warning=FALSE}
# Utilizamos el método por bootstrapping de eclus
ecl<-eclust(elec_r)

ecl$centers
med.ecl<-medidasVal(elec_r,ecl$cluster,ecl$cluster,'eclus')

valT<-rbind(valT,med.hk,med.ecl)
valT
```

```{r warning=FALSE}

```

```{r warning=FALSE}

```



## Reducción de dimensionalidad

## Gráfico de correlación (Pearson) y comunidades

```{r}
corrplot::corrplot(cor(elec_r), method="ellipse")
qgraph(cor(elec_r), layout="spring", shape="rectangle")
```

## Matriz de correlaciones ajustada (Spearman)

```{r}
(c<-RcmdrMisc::rcorr.adjust(elec_r, type="spearman",   use="complete"))
```

## Determinante de la matriz

```{r}
det(c$R$r)
```

Vemos un valor muy próximo a cero, lo cual indica un correlación cercana a la máxima.

## Gráfico de correlaciones (Spearman)

```{r}
corrplot::corrplot(c$R$r, method="ellipse")
```

## Test de esferidad de Bartlett

```{r warning=FALSE}
psych::cortest.bartlett(elec_r)
```

Rechazamos la hipótesis nula, por tanto, sabemos que el conjunto de datos se aleja de una matriz identidad indicando que existe correlación entre los datos.

## Indice de Adecuacion Muestral KMO

```{r}
psych::KMO(elec_r) 
```

## PCA

```{r}
el.pca <- princomp(elec_r, cor=T)
summary(el.pca)
```

## Gráfico de sedimentación

```{r}
screeplot(el.pca, type = 'lines')
```

```{r}
# Cargas
loadings(el.pca)
```

```{r}
# Biplot por comunidad autónoma
ggbiplot::ggbiplot(el.pca, labels=rownames(elec_r), groups=elec_r2$CCAA,
                   ellipse = TRUE, circle = TRUE) +
  theme_minimal()
```

## Análisis factorial

```{r}
(el.fa1 <- factanal(elec_r, factors=3, rotation="none", scores="regression"))
```

Vemos en el modelo cierta unicidades algo altas como la de "SCDifProv" de 0.853 o la de "PobChange" de 0.612. Si nos fijamos en el contraste de hipótesis nos muestra que con un p-valor de 0.00211 rechazamos la hipótesis nula de suficiencia con 3 factores en el modelo.

```{r}
biplot(el.fa1$scores[,1:2], loadings(el.fa1), cex=c(0.7,0.8))
```

```{r}
el.fa2 <- psych::fa(elec_r, nfactors=3, fm='wls',rotate="promax")
print(el.fa2, cut = 0.3)
```

```{r}
biplot(el.fa2$scores[,1:2], loadings(el.fa1), cex=c(0.7,0.8))
```

```{r}
psych::fa.diagram(el.fa2, simple=FALSE) # Funciona bastante bien de cara a la interpretación
```