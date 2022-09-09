# MUBI - Lendo Dados Unimed
# Objetivo: Comparar Sintético x Analítico 
# Cliente: Mubi 
# Autor: Marcello Filgueiras

library(tidyverse)


# 1) ANALÍTICOS --------------------------------------------------------------


# Importando Dados --------------------------------------------------------
library(readxl)

#Todos da pasta "data_raw/unimed" eram .xls que geraram "error Unable to Open File"
# Salvei na mão o ".xls" para ".xlsx" . Issue comum do read_xl, pois é um erro do arquivo, não do .xls

#xls_fail <- read_excel("data_raw/unimed/xls_analitico_1830.xls")


#analitico_1830 <- read_excel("data_raw/analitico/analitico_1830.xlsx",
 #                            col_names = FALSE)

nome_colunas= c("N_Doc",
                "Código",
                "Usuário",
                "Data",
                "Procedimento",
                "Tabela",
                "Descrição do Procedimento",
                "quantidade",
                "Filme",
                "Custo",
                "Honorario",
                "Valor")

#Função para ler Pasta Inteira de Excels





leitora_xlsx_analitico<-function(diretorio){
  
  arquivos_xlsx<- base::list.files(diretorio,
                                   pattern = "\\.xlsx$", 
                                   full.names = TRUE)

  
  
  tibble::tibble(origem =arquivos_xlsx,
                 df = purrr::map(arquivos_xlsx,
                          ~readxl::read_excel(.x,
                                            col_names = c("N_Doc",
                                                          "Codigo",
                                                          "Usuario",
                                                          "Data",
                                                          "Procedimento",
                                                          "Tabela",
                                                          "Descricao do Procedimento",
                                                          "quantidade",
                                                          "Filme",
                                                          "Custo",
                                                          "Honorario",
                                                          "Valor")
                                            ))
  )
}


docs_analitico <- leitora_xlsx_analitico(diretorio = "data_raw/analitico")


# Tidying -----------------------------------------------------------------


docs_analitico_df<- docs_analitico%>%
  tidyr::unnest(df)%>%
  janitor::clean_names()%>%
  dplyr::mutate(origem= stringr::str_extract(origem, "\\d+" ),
                n_doc= stringr::str_to_lower(n_doc))%>%
  tidyr::drop_na(n_doc)


#Anotações de contabildiade dentro das colunas do Excel prejudicavam uso de fórmulas.
#esse vetor cria uma regex para tirar as linhas com essas anaotações
regex_filtro<- paste("executante",
                     "nº lote",
                     "nº doc",
                     "total",
                     sep = "|")

docs_analitico_df_filtrado<- docs_analitico_df%>%
  dplyr::filter(!str_detect(n_doc, regex_filtro))

#Fazer Tibble depois ou dentro da Função Map?  



# 2) SINTÉTICOS --------------------------------------------------------------


# Importando Dados --------------------------------------------------------


leitora_xlsx_sintetico<-function(diretorio){
  
  arquivos_xlsx<- base::list.files(diretorio,
                                   pattern = "\\.xlsx$", 
                                   full.names = TRUE)
  
  
  
  tibble::tibble(origem =arquivos_xlsx,
                 df = map(arquivos_xlsx,
                          ~readxl::read_excel(.x,
                                              col_names = c("primeira",
                                                            "segunda")
                          ))
  )
}


docs_sintetico<- leitora_xlsx_sintetico(diretorio = "data_raw/sintetico")



# Tidying -----------------------------------------------------------------


docs_sintetico_df <- docs_sintetico %>%
  tidyr::unnest(df) %>%
  janitor::clean_names() %>%
  dplyr::mutate(origem= stringr::str_extract(origem, "\\d+" )) %>%
  tidyr::drop_na(primeira)


docs_sintetico_df_wide<- docs_sintetico_df %>%
          dplyr::group_by(origem) %>%
          tidyr::pivot_wider(names_from = primeira,
                             values_from = segunda)%>%
  dplyr::rename("codigo_estbl"= 2,
                "data_pagamento"= 3) %>%
  janitor::clean_names() %>%
  dplyr::mutate(codigo_estbl = str_extract(codigo_estbl, "\\d+"),
                data_pagamento= str_remove(data_pagamento,"(?i)pago: ")
                %>% lubridate::dmy()
                ) %>%
  dplyr::select(origem,
                data_pagamento,
                total_creditos,
                total_debitos,
                total_liquido)



as_tibble(docs_sintetico_df_wide)

#                across(.cols= total_creditos:total_liquido,
 #                      .fns = as.double(.cols,
  #                                       )))



#y <- as.character("0.912345678")
#as.numeric(y)


# Exporting - Base de dados -----------------------------------------------

#Exportando pq a cliente gosta de Excel e já tem fórmulas prontas.
library(writexl)
library(xlsx)


writexl::write_xlsx(list(Analitico = docs_analitico_df_filtrado,
                         Sintetico = docs_sintetico_df_wide),
                    "exports/med_iot_compilado.xlsx")
