
  
  
  
  Os pacotes utulizados para realizar a maioria das analises qualitativas.



#| message: false
#| warning: false

library(devtools)       # Baixar pacote do github
library(tidytext)       # Pacote de text mining
library(tidyverse)      # Manipulação de dados
library(magrittr)       # Operador pipe
library(stringr)        # Manipulação de texto
library(rvest)          # Web scraping
library(quanteda)       # Análise Quantitativa de texto
library(quanteda.textplots)
library(quanteda.textstats)
library(qdap)           # Análise Qualitativa de texto
library(forcats)        # Manipulação de fatores
library(ggthemes)       # Temas para o ggplot2
library(lexiconPT)      # Dicionário Léxico de palavras
library(literaturaBR)



## DATA FRAME 
### Importar os datasets e transformar em um dataset único.


- Importação dos *datasets* presentes no pacote literaturaBR na data de hoje e os transformar em um dataset só:
  
  
  ```{r}
#| message: false
#| warning: false

data("alienista")
data("cortico")
data("dom_casmurro")
data("memorias_postumas_bras_cubas")
data("memorias_de_um_sargento_de_milicias")
data("ateneu")
data("escrava_isaura")
data("noite_na_taverna")

df <- bind_rows(alienista,
                cortico,
                dom_casmurro,
                memorias_postumas_bras_cubas,
                memorias_de_um_sargento_de_milicias,
                ateneu,
                escrava_isaura,
                noite_na_taverna)

```



## Estrutura geral dos Dados.


```{r}
#| message: false
#| warning: false

glimpse(df)
```


Todos os datasets fornecidos pelo pacote literaturaBR possuem a mesma estrutura, onde cada linha corresponde a um parágrafo de um livro e contêm 5 variáveis:
  
  - **book_name**: Nome original do livro;
- **chapter_name**: Nome original do capítulo do livro do parágrafo;
- **url**: Link para artigo do Wikisouce de onde o capítulo do parágrafo foi extraído;
- **paragraph_number**: Ordem do parágrafo em seu capítulo;
- **text**: Texto do parágrafo. Contem acentos e pontuação.



Para usar (parte) das funções do pacote **quanteda**, precisamos converter o dataframe dos livros em um objeto do tipo corpus.


```{r}
#| message: false
#| warning: false




df_corpus <- df %>% 
  # agrupar por livro
  group_by(book_name) %>% 
  # formatar o dataframe para que so tenha uma linha por livro
  summarise(text = paste0(text, sep = "", collapse = ". "))

dim(df_corpus)

```


Com base na função *summary*, é possível verificar a quantidade de informação básica das palavras.

- **Types**: N°de Palavras Diferentes
- **Tokens**: N°Total de Palavras
- **Sentences**: N°de Frases em cada Livro



```{r}
#| message: false
#| warning: false


meu_corpus <- quanteda::corpus(df_corpus$text, docnames = df_corpus$book_name)
summary(meu_corpus)


```





Vamos então criar uma document-feature matrix a partir desse corpus criado, tomando o cuidade de remover pontuações e stopwords:
  
  
  ```{r}
#| message: false
#| warning: false


library(quanteda)

# 1. Tokenizar o corpus removendo pontuação e símbolos
tokens_corpus <- tokens(meu_corpus, 
                        remove_punct = TRUE, 
                        remove_symbols = TRUE, 
                        remove_numbers = TRUE)

# 2. Converter para minúsculas (essencial para que 'Ele' e 'ele' sejam a mesma palavra)
tokens_corpus <- tokens_tolower(tokens_corpus)

# 3. Remover stopwords em português
tokens_clean <- tokens_remove(tokens_corpus, pattern = stopwords("portuguese"))

# 4. Criar a Document-Feature Matrix (DFM)
corpus_dfm <- dfm(tokens_clean)

# --- ANÁLISES ---

# A) As 30 palavras mais comuns no corpus INTEIRO (todos os livros somados)
top_words_geral <- topfeatures(corpus_dfm, n = 30)
print("--- 30 Palavras mais comuns no geral ---")
print(top_words_geral)

# B) As 30 palavras mais comuns de um livro ESPECÍFICO (ex: A Escrava Isaura)
# Primeiro filtramos a DFM para conter apenas o documento desejado
dfm_isaura <- dfm_subset(corpus_dfm, docnames(corpus_dfm) == "O escravo Isaura" | docnames(corpus_dfm) == "escrava_isaura") 
# Nota: Verifique o nome exato que aparece no summary(meu_corpus) para bater com o filtro

top_words_book <- topfeatures(dfm_isaura, n = 30)
print("--- 30 Palavras mais comuns em 'Escrava Isaura' ---")
print(top_words_book)

# C) Retorna a ocorrência das 15 palavras mais frequentes do dataset em cada livro
# Primeiro ordenamos a DFM pela frequência das palavras
dfm_ordenada <- dfm_sort(corpus_dfm, margin = "features")
print("--- Matriz de ocorrência (8 livros x 15 palavras mais frequentes) ---")
print(dfm_ordenada[, 1:15])



```








:::: progress
::: {.progress-bar style="width: 100%;"}
:::
  ::::
  
  
  
  